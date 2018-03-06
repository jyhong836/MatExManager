classdef ExperimentManager < handle
% Experiment manager
%	Setup, run experiments and get results.
%
% Example:
%	EM = ExperimentManager ( datasetName, options );
%	EM.setup();
%	EM.runAll(); % Run all required methods.
%	EM.runWithMethod(method, method_options); % Run single method.
%	EM.outputResults();
%	
% Author: Junyuan Hong, 2017-12-14, jyhong836@gmail.com

properties (GetAccess = public, SetAccess = private)
	forceRunMethods
	runAllMethods
	jobname
	autoSave
	loocvID
	updateCache
	results
    verbose
%     data
    modelProvider
    dataProvider
    experiments
end % END of properties

properties (Access = private)
	save_file_name = [];
	fh_runFlag = @(method) true; % Return flag indicating if should run method.
end % END of properties

methods

function EM = ExperimentManager ( dataProvider, modelProvider, options )
% Initialization
	%% Process options
	if ~exist('options', 'var'); options = []; end;
	[	EM.forceRunMethods, ...
		EM.runAllMethods,   ...
		EM.jobname,         ...
		EM.autoSave,        ...
		EM.verbose,         ...
		EM.experiments,     ...
		] = process_options (options, ...
		'forceRunMethods', {},        ...
		'runAllMethods',   false,     ...
		'jobname',         'default_job', ... 
		'autoSave',        true,          ...
		'verbose',         1,             ...
		'experiments',     []);

% 	if isempty(EM.jobname)
% 		EM.jobname = experiment.getjob.name(datasetName, EM.d);
% 	end

	EM.dataProvider  = dataProvider;
	EM.modelProvider = modelProvider;

	global TEMP_DIR

	EM.save_file_name = fullfile(TEMP_DIR, EM.jobname);
end

function setupExperiments (EM, dataNames, modelNames)
% Generate experiment instances
	runAllData    = ~exist('dataNames', 'var')  || isempty(dataNames);
	runAllMethods = ~exist('modelNames', 'var') || isempty(modelNames);

	% runFlag = @(data, model) ;

	% generate experiments
	InfoSystem.say('Generating experiments...', EM.verbose, 1);

	allMethods  = EM.modelProvider.names();
	allDatasets = EM.dataProvider.names();

	method_options.maxM = 123; % EM.maxM; % TODO fix this.
	data_options.verbose = EM.verbose;
    
	for im = 1:length(allMethods)
		method = allMethods{im};
		for id = 1:length(allDatasets)
			data = allDatasets{id};
			if (runAllData    || any(strcmp(data, dataNames)) ) ... 
			&& (runAllMethods || any(strcmp(model, modelNames)))
				EM.experiments = [EM.experiments, Experiment(data, method, data_options, method_options)];
			end
		end
	end
end

function runAll (EM)
	for ii = length(EM.experiments)
		ex = EM.experiments(ii);
		if ~ex.runned
			ex.result = EM.runWith(ex);
			
			EM.save2file(); % TODO save to file
			disp(['---- FIN ' ex.str '@' datestr(datetime('now')) ' ----']);
		else
			disp(['WARN: ' ex.str ' has been runned.']);
		end
	end
end


function result = runWith (EM, experiment)
% Run specific method and return result
	disp(['------- RUN ' experiment.str ' -------']);

	[preprocessor, classifier, modelParam] = EM.modelProvider.getModelByName(experiment.modelName, experiment.modelOptions);

	% Build model selector
	modelSelector = ModelSelector (EM.dataProvider.load(experiment.dataName, experiment.dataOptions), preprocessor, classifier, modelParam);
	modelSelector.verbose = 1;

	% Select model
	modelSelector.selectModel();

	% Evaludate model
	modelSelector.evaluateModel();

	% Get result
	result = modelSelector.getReport();
end

function results = outputResults (EM)
	%% //////// output ////////
	% Display table results.
	display_table_results(EM.results);

	results = EM.results;

	% //// AutoSave ////
	EM.save2file ();
	if ~EM.autoSave
		disp(' [SAVE] Results are NOT saved to any file.');
	end
	disp([' --- Finish @' datestr(datetime('now')) ' --- ']);
end

end % END of methods

methods (Access = private)

function save2file (EM, method)
	% //// AutoSave ////
	if EM.autoSave
		% if exist('method', 'var') && ~isempty(method)
		% 	EM.results.(method).date = datestr(datetime('now'));
		% end
        experiments = EM.experiments;
		save(EM.save_file_name, 'experiments');
		disp(['[SAVE] Auto save results to ''' EM.save_file_name '''']);
	end
end

end % END of methods (Access = private)

end


% //////// functions /////////
function display_table_results(results)
% display_table_results: Display the table of all results
	if isempty(results); return; end
	fldnames = fieldnames(results)';
	Test_error = [];
	Train_error = [];
	for ii=1:length(fldnames)
		fn = fldnames{ii};
		Test_error  = [ Test_error; results.(fn).test_err];
		Train_error = [Train_error; results.(fn).train_err];
	end
	table_res = table(Test_error, Train_error, ...
		'RowNames', fldnames);
	disp(table_res);
end

