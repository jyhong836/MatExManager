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
%     data
    modelProvider
    dataProvider
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
		] = process_options (options, ...
		'forceRunMethods', {},        ...
		'runAllMethods',   false,     ...
		'jobname',         'default_job', ... 
		'autoSave',        true);

% 	if isempty(EM.jobname)
% 		EM.jobname = experiment.getjob.name(datasetName, EM.d);
% 	end

	EM.dataProvider  = dataProvider;
	EM.modelProvider = modelProvider;
end

function setup (EM)
% Setup experiment:
%	get data
%	preprocess data
	%% ////// process data //////
	global TEMP_DIR

	EM.save_file_name = fullfile(TEMP_DIR, EM.jobname);

	% import data
    EM.dataProvider.load();

	%% /////// learn models ///////
% 	EM.results = experiment.getjob.result(EM.jobname);
	if isempty(EM.forceRunMethods)
		disp('No method is required. EXIT');
		return;
	end
	disp('Force run methods:');
	disp(EM.forceRunMethods);
	if EM.runAllMethods
		disp(' All methods not run will be run.');
	end

	EM.fh_runFlag = @(method) any(strcmp(method, EM.forceRunMethods)) || (EM.runAllMethods && (isempty(EM.results) || ~isfield(EM.results, method)));
end

function runAll ( EM )
% Run all required methods.
	allMethods = EM.modelProvider.getModelNames();
	method_options.maxM = 123; % EM.maxM; % TODO fix this.
    
	for im = 1:length(allMethods)
		method = allMethods{im};
		if EM.fh_runFlag(method)
			EM.runWithMethod (method, method_options);
		end
	end
end

function runWithMethod (EM, method, method_options)
% Run specific method
	disp(['------- RUN ' method ' -------']);

	[preprocessor, classifier, modelParam] = EM.modelProvider.getModelByName(method, method_options);

	% Build model selector
	modelSelector = ModelSelector (EM.dataProvider, preprocessor, classifier, modelParam);
	modelSelector.verbose = 1;

	% Select model
	modelSelector.selectModel();

	% Evaludate model
	modelSelector.evaluateModel();

	% Gather result
	EM.results.(method) = modelSelector.getReport();

	% method_options = datasetName, d, maxM, 
	% EM.results.(method) = experiment.method.(method) ( data, method_options );
	
	EM.save2file();
	disp(['---- FIN ' method '@' datestr(datetime('now')) ' ----']);
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
		if exist('method', 'var') && ~isempty(method)
			EM.results.(method).date = datestr(datetime('now'));
		end
        results = EM.results;
		save(EM.save_file_name, 'results');
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

