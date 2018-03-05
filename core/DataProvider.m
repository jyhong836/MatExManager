classdef DataProvider < handle

properties (GetAccess = public, SetAccess = protected)
	datasetName
	X      % train data
	test_X % test data
	Y      % train label
	test_Y % test label
	options
end

methods

function DP = DataProvider (datasetName, options)
	DP.datasetName = datasetName;
	if exist('options', 'var'); DP.options = options; else; DP.options = []; end;
end

function load (DP)
% Load data from mat files.
	loaded = DP.load_from_file();
	[DP.X, DP.test_X, DP.Y, DP.test_Y] = DP.process_data(loaded);
end

end % END: methods

methods (Access = protected)

function loaded = load_from_file (DP)
% Load from file and return data in struct 'loaded'.
	dataname = DP.datasetName;
	global DATA_DIR % TODO don't use global variable.
	loaded = load(fullfile(DATA_DIR, dataname));
end

function [X, test_X, Y, test_Y] = process_data (DP, loaded)
% 	loaded - Loaded data struct.
	X      = loaded.training;
	test_X = loaded.testing;
	Y      = loaded.training_label;
	test_Y = loaded.testing_label;
end

end % END: methods

end % END: class
