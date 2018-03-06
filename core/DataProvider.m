classdef DataProvider < handle

properties (GetAccess = public, SetAccess = protected)
	% datasetName
	X      % train data
	test_X % test data
	Y      % train label
	test_Y % test label
	options
    names
end

methods 
	function dataNames = get.names (obj)
		dataNames = {'PreWine'};
	end
end

methods %(Sealed)

function DP = DataProvider (options)
	% DP.datasetName = datasetName;
	% if exist('options', 'var'); DP.options = options; else; DP.options = []; end;
end

function data = load (DP, name, options)
% Load data from mat files.
	hasLoaded = false; % TODO check if loaded
	if ~hasLoaded
		if ~exist('options', 'var'); options = []; end;
		loaded = DP.load_from_file(name);
		[data.X, data.test_X, data.Y, data.test_Y] = DP.process_data(loaded, options);
	end
end

end % END: methods

methods (Access = protected)

function loaded = load_from_file (DP, name)
% Load from file and return data in struct 'loaded'.
% 	dataname = DP.datasetName;
	global DATA_DIR % TODO don't use global variable.
	loaded = load(fullfile(DATA_DIR, name));
end

function [X, test_X, Y, test_Y] = process_data (DP, loaded, options)
% 	loaded - Loaded data struct.
	X      = loaded.training;
	test_X = loaded.testing;
	Y      = loaded.training_label;
	test_Y = loaded.testing_label;
end

end % END: methods

end % END: class
