% @Author: Junyuan Hong
% @Date:   2017-12-14
% @Last Modified by:   Junyuan Hong
% @Last Modified time: 2018-03-06

init;

% % ////////// full demo with steps /////////
% allMethods = ModelProvider.getModelNames();
% method_options.param1 = 0;

% for im = 1:length(allMethods)
% 	method = allMethods{im};

% 	[preprocessor, classifier, modelParam] = ModelProvider.getModelByName(method, method_options);

% 	% Build model selector
% 	modelSelector = ModelSelector (data, preprocessor, classifier, modelParam);
% 	modelSelector.verbose = 1;

% 	% Select model
% 	modelSelector.selectModel();

% 	% Evaludate model
% 	modelSelector.evaluateModel();

% 	% Gather result
% 	results.(method) = modelSelector.getReport();
% end


% //////////// demo with data set ////////
% datasetName = 'PreWine';
options = [];

% EM = ExperimentManager ( datasetName, options ); % Use default model provider
EM = ExperimentManager ( DemoDataProvider(options), DemoModelProvider() ); % Use customized model provider.
EM.setupExperiments();
EM.run(); % Run all required methods.
results = EM.outputResults();
