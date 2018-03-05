classdef DemoDataProvider < DataProvider

methods
function obj = DemoDataProvider (varargin)
	obj@DataProvider(varargin{:});
end
end

methods (Access = protected)

function [X, test_X, Y, test_Y] = process_data (DP, ds)
	X      = ds.training;
	test_X = ds.testing;
	Y      = ds.training_label;
	test_Y = ds.testing_label;
end

end

end
