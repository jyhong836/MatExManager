classdef DemoDataProvider < DataProvider

methods
function obj = DemoDataProvider (varargin)
	obj@DataProvider(varargin{:});
end
end

methods (Access = protected)

function names = getNames (obj)
	names = {'PreWine'};
end

function loaded = load_from_file (DP, dataname)
% Load from file and return data in struct 'loaded'.
%	You can customize the function to adapt your file format.
	% dataname = DP.datasetName;
	global DATA_DIR % TODO don't use global variable.
	loaded = load(fullfile(DATA_DIR, dataname));
end

function [X, test_X, Y, test_Y] = process_data (DP, ds, options)
% You can customize the function to adapt your data format.
%	For example, you can slice the data dimension.
	X      = ds.training;
	test_X = ds.testing;
	Y      = ds.training_label;
	test_Y = ds.testing_label;
end

end

end
