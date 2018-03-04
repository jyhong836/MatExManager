classdef PreprocessorProvider
% Author: Junyuan Hong, 2017-12-05, jyhong836@gmail.com

methods (Static)

function data = import_data (data)
% Import data from mat file which should include formatted fields.
	dataname = data.options.datasetName;
	global DATA_DIR
	ds = load(fullfile(DATA_DIR, dataname));
	data.X      = ds.training;
	data.test_X = ds.testing;
	data.Y      = ds.training_label;
	data.test_Y = ds.testing_label;
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

end

end

