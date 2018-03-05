classdef PreprocessorProvider
% Author: Junyuan Hong, 2017-12-05, jyhong836@gmail.com

methods (Static)

function newdata = kernel_preprocessor (data, options, kernelType)
% cell array of subspaces -> kernel matrix.

	if ~exist('options', 'var'); options = []; end;
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

end

end

