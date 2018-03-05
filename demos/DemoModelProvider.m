classdef DemoModelProvider

methods

function MP = ModelProvider ()
	InfoSystem.say('Customized model provider.')
end

function modelNames = getModelNames (MP)
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
			modelParam   = svm_rbf_param(options);
			classifier   = @svm;
			preprocessor = @(data)kernel_preprocessor(data, 'rbf');
		otherwise
			error(['Unknown model name: ' name]);
	end
end

end

end


function [ W, test_err, train_err ] = svm (data)

	options = [];
	if isfield(data, 'options'); options = data.options; end;
	[C, verbose] = process_options (options, 'C', 1, 'verbose', 0);

	[ test_err, train_err, W ] = svm_none ( data.X.K, data.Y, data.test_X.K, data.test_Y, struct('C', C) );
	
end

function newdata = kernel_preprocessor (data, kernelType)
% cell array of subspaces -> kernel matrix.

	options = [];
	if isfield(data, 'options'); options = data.options; end;
	[gam] = process_options (options, 'gam', 1000);

	% Kernel function handler
	switch lower(kernelType)
		case 'rbf'
			ker_fh = @(x1, x2) exp(-gam* sum((x1 - x2).^2));
	end

	% compute kernel
	start_time = cputime();
	fprintf(' Computing kernel...');
	[ newdata.X, newdata.test_X, newdata.Y, newdata.test_Y ] = ...
		compute_kernel ( ker_fh, data );
	disp([' cputime: ' num2str(cputime()-start_time)]);

end

function [ modelParam ] = svm_rbf_param ( options )
	modelOptions  = struct('verbose', 1); % Model options.
	selectLastOne = false; % select last parameter pack if there are more than one parameter packs yielding identical validation error rates.

	Cs  = power(10, -4:5); % Define parameter range.
	gam = power(10, 0:-1:-4);

	modelParam = ModelParam({'C', Cs, 'gam', gam}, ... % parameter space. Format: {'name', range, 'name', range, ...}
                            modelOptions, selectLastOne, ... % optional settings.
                            logical([0,1])); % Define which parameter will trigger preprocessing, i.e., calling `preprocessor`.
end
