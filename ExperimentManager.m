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
	datasetName
	d
	maxM
	lambda
	forceRunMethods
	runAllMethods
	jobname
	autoSave
	loocvID
	updateCache
	results
    data
end % END of properties

properties (Access = private)
	save_file_name = [];
	fh_runFlag = @(method) true; % Return flag indicating if should run method.
end % END of properties

methods

function EM = ExperimentManager ( datasetName, options )
% Initialization
	%% Process options
	if ~exist('options', 'var'); options = []; end;
	[	EM.d,               ...
		EM.maxM,            ...
		EM.lambda,          ...
		EM.forceRunMethods, ...
		EM.runAllMethods,   ...
		EM.jobname,         ...
		EM.autoSave,        ...
		EM.loocvID,         ...
		EM.updateCache,     ...
		] = process_options (options, ...
		'd',               2,         ...
		'maxM',            10,        ...
		'lambda',          1e-3,      ...
		'forceRunMethods', {},        ...
		'runAllMethods',   false,     ...
		'jobname',         [],	      ... 
		'autoSave',        true,      ...
		'loocvID',         0,         ...
		'updateCache',     0);

	if isempty(EM.jobname)
		EM.jobname = experiment.getjob.name(datasetName, EM.d);
	end

	EM.datasetName = datasetName;
end

function setup (EM)
% Setup experiment:
%	get data
%	preprocess data
	%% ////// process data //////
	global TEMP_DIR

	EM.save_file_name = fullfile(TEMP_DIR, EM.jobname);

	% Prepare subspace data
	data.options.datasetName = EM.datasetName;
	data.options.d           = EM.d;
	data.options.maxM        = EM.maxM;
	data.options.updateCache = EM.updateCache;
	data.options.loocvID     = EM.loocvID;
	EM.data = PreprocessorProvider.ssm_preprocessor(data);

	%% /////// learn models ///////
	EM.results = experiment.getjob.result(EM.jobname);
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
	allMethods = ModelProvider.getModelNames();
	method_options.maxM = EM.maxM;
    
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

	[preprocessor, classifier, modelParam] = ModelProvider.getModelByName(method, method_options);

	% Build model selector
	modelSelector = ModelSelector (EM.data, preprocessor, classifier, modelParam);
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

function outputResults (EM)
	%% //////// output ////////
	% Display table results.
	display_table_results(EM.results);

	% //// AutoSave ////
	EM.save2file (EM);
	if ~EM.autoSave
		disp(' [SAVE] Results are NOT saved to any file.');
	end
	disp([' --- Finish @' datestr(datetime('now')) ' --- ']);
end

end % END of methods

methods (Access = private)

function save2file (EM)
	% //// AutoSave ////
	if EM.autoSave
		EM.results.(method).date = datestr(datetime('now'));
        results = EM.results;
		save(EM.save_file_name, 'results');
		disp(['[SAVE] Auto save results to ' EM.save_file_name]);
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

