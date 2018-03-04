% demo of `ModelProvider`
classdef ModelProvider

methods (Static)

function modelNames = getModelNames ()
	modelNames =  {'svm_rbf',
	}; 
end

function [preprocessor, classifier, modelParam] = getModelByName ( name, options )

	% Prepare
	switch name
		case 'svm_rbf'
			modelParam   = ModelParamProvider.dg_gau(options);
			classifier   = @ClassifierProvider.svm;
			preprocessor = @(data)PreprocessorProvider.kernel_preprocessor(data, 'rbf');
		otherwise
			error(['Unknown model name: ' name]);
	end
end

end

end
