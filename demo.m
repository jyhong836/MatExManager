% @Author: Junyuan Hong
% @Date:   2017-12-14
% @Last Modified by:   Junyuan Hong
% @Last Modified time: 2017-12-14

init;

allMethods = ModelProvider.getModelNames();
method_options.param1 = 0;

for im = 1:length(allMethods)
	method = allMethods{im};

	[preprocessor, classifier, modelParam] = ModelProvider.getModelByName(method, method_options);

	% Build model selector
	modelSelector = ModelSelector (data, preprocessor, classifier, modelParam);
	modelSelector.verbose = 1;

	% Select model
	modelSelector.selectModel();

	% Evaludate model
	modelSelector.evaluateModel();

	% Gather result
	results.(method) = modelSelector.getReport();
end
