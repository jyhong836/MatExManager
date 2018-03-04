% demo of `ModelProvider`
classdef ModelProvider

methods (Static)

function modelNames = getModelNames ()
	modelNames =  {'svm_rbf', % SVM classifier with RBF kernel
	}; 
end

function [preprocessor, classifier, modelParam] = getModelByName ( name, options )
% A method provides real models by name.
% INPUT:
%   name - The name of model.
%   options - The option to be provided to `ModelParamProvider`, see `ModelParamProvider.m` for details.

	% Prepare
	switch name
		case 'svm_rbf'
			modelParam   = ModelParamProvider.svm_rbf(options);
			classifier   = @ClassifierProvider.svm;
			preprocessor = @(data)PreprocessorProvider.kernel_preprocessor(data, 'rbf');
		otherwise
			error(['Unknown model name: ' name]);
	end
end

end

end
