classdef DataProvider < handle
% Data provider.
%	To provide data, subclass this and implement abstract methods.
%
% Author: Junyuan Hong, 2018-03-06, jyhong836@gmail.com

properties (GetAccess = public, SetAccess = protected)
    names   % all data names
    % doCache % Cache data to speed up data processing.
end

methods 
	function dataNames = get.names (obj)
		dataNames = obj.getNames();
	end
end

properties (Access = private)
	loadedData % Array of loaded data.
end

% /////////// Abstract methods to be implemented. /////////
methods (Abstract, Access = protected)

	names = getNames (obj)
	% Return a cell array of data names.

	loaded = load_from_file (obj, name)
	% Load from file and return data in struct 'loaded'.

	[X, test_X, Y, test_Y] = process_data (obj, loaded, options)
	% 	loaded - Loaded data struct.

end % END: methods

methods %(Sealed)

function obj = DataProvider ()
end

function data = load (DP, name, options)
% Load data from mat files if has not been loaded.
%	data - A struct contains data:
%		X, test_X - Data which could be (cell) array or kernel matrix.
%		Y, test_Y - Labels which should be (cell) array.
%		name - Data name as input.
%		options - Data options as input.
	data = DP.searchLoadedData(name, options);
	if isempty(data) % not found data
		disp(['Load data ''' name ''' from file.']);
		if ~exist('options', 'var'); options = []; end;
		loaded = DP.load_from_file(name);
		[data.X, data.test_X, data.Y, data.test_Y] = DP.process_data(loaded, options);
		data.name = name;
		data.options = options;

		DP.loadedData = [DP.loadedData; data];
	end
end

function data = searchLoadedData (DP, name, options)
% Search loaded data
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
% Check if two data is the same. 
%	Only when name and options are the same, data will be identified as the same.
	flag = strcmp(name1, name2) && isequaln(options1, options2);
end

end % END: methods

end % END: class