classdef DataProvider < handle

properties (GetAccess = public, SetAccess = protected)
    names
end

properties (Access = protected)
	loadedData
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
	data = DP.findLoaded(name, options); % TODO check if loaded
	if isempty(data)
		disp(['Load data ''' name ''' from file.']);
		if ~exist('options', 'var'); options = []; end;
		loaded = DP.load_from_file(name);
		[data.X, data.test_X, data.Y, data.test_Y] = DP.process_data(loaded, options);
		data.name = name;
		data.options = options;

		loadedData = [loadedData; data];
	end
end

function data = findLoaded (DP, name, options)
	data = [];
	for ii = 1:length(DP.loadedData)
		data = DP.loadedData(ii);
		if DP.isEqualData(name, options, data.name, data.options)
			disp('Found loaded data.');
			return;
		end
	end
end

function flag = isEqualData (DP, name1, options1, name2, options2)
	flag = strcmp(name1, name2) && isequaln(options1, options2);
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
