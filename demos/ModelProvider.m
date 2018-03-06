% demo of `ModelProvider`
classdef ModelProvider

properties
	names
end

methods

function MP = ModelProvider ()
	InfoSystem.say('Using default model provider.')
end

function modelNames = get.names (MP)
	modelNames =  {'svm_rbf', % SVM classifier with RBF kernel
	}; 
end

function [preprocessor, classifier, modelParam] = getModelByName ( MP, name, options )
% A method provides real models by name.
% INPUT:
%   name - The name of model.
%   options - The option to be provided to `ModelParamProvider`, see `ModelParamProvider.m` for details.

	% Prepare
	switch name
		case 'svm_rbf'
			modelParam   = ModelParamProvider.svm_rbf(options);
			classifier   = @ClassifierProvider.svm;
			preprocessor = @(data, options)PreprocessorProvider.kernel_preprocessor(data, options, 'rbf');
		otherwise
			error(['Unknown model name: ' name]);
	end
end

end

end
