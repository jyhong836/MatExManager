classdef DemoModelProvider < ModelProvider

methods

function MP = DemoModelProvider ()
	InfoSystem.say('Customized model provider.')
end

function names = getNames (MP)
	names =  {'svm_rbf', % SVM classifier with RBF kernel
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
			modelParam = ModelParam({'C',   power(10, 0:4), ...  % classifier param
	                                 'gam', power(10, 0:-2:-4)}); % kernel param
			classifier   = @svm;
			preprocessor = @rbf_kernel_pre;
		otherwise
			error(['Unknown model name: ' name]);
	end
end

end

end


function [ W, test_err, train_err ] = svm (data)
	% process classifier options.
	if isfield(data, 'options'); options = data.options; else; options = []; end;
	[C] = process_options (options, 'C', 1);

	[ test_err, train_err, W ] = svm_none ( data.X.K, data.Y, data.test_X.K, data.test_Y, ...
		                                   struct('C', C) );
end

function newdata = rbf_kernel_pre (data, options)
% cell array of subspaces -> kernel matrix.
	% process kernel options
	if ~exist('options', 'var'); options = []; end;
	[gam] = process_options (options, 'gam', 1000);

	% Kernel function handler
	ker_fh = @(x1, x2) exp(-gam* sum((x1 - x2).^2));

	% compute kernel
	[ newdata.X, newdata.test_X, newdata.Y, newdata.test_Y ] = ...
		compute_kernel ( ker_fh, data );
end
