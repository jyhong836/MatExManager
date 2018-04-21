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
	function dataNames = get.names (self)
		dataNames = self.getNames();
	end
end

properties (Access = private)
	loadedData % Array of loaded data.
end

% /////////// Abstract methods to be implemented. /////////
methods (Abstract, Access = protected)

	names = getNames (self)
	% Return a cell array of data names.

	preprocessor = getPreprocessor (self, name)

	loaded = load_from_file (self, name)
	% Load from file and return data in struct 'loaded'.

end % END: methods

methods %(Sealed)

function self = DataProvider (options)
end

function data = load (self, name, options)
% Load data from mat files if has not been loaded.
%	data - A struct contains data:
%		X, test_X - Data which could be (cell) array or kernel matrix.
%		Y, test_Y - Labels which should be (cell) array.
%		name - Data name as input.
%		options - Data options as input.
	data = self.searchLoadedData(name, options);
	if isempty(data) % not found data
		disp(['Load data ''' name ''' from file.']);
		if ~exist('options', 'var'); options = []; end;
		loaded = self.load_from_file(name);

		preprocessor = self.getPreprocessor(name, options);
		data = self.preprocessor(loaded, options);

		assert(all(isfield(data, {'X', 'test_X', 'Y', 'test_Y'})), 'Preprocessed data missing required fields: X, test_X, Y, test_Y');
		data.name = name;
		data.options = options;

		self.loadedData = [self.loadedData; data];
	end
end

function data = searchLoadedData (self, name, options)
% Search loaded data
	data = [];
	for ii = 1:length(self.loadedData)
		data = self.loadedData(ii);
		if self.isEqualData(name, options, data.name, data.options)
			disp('Found loaded data.');
			return;
		end
	end
end

function flag = isEqualData (self, name1, options1, name2, options2)
% Check if two data is the same. 
%	Only when name and options are the same, data will be identified as the same.
	flag = strcmp(name1, name2) && isequaln(options1, options2);
end

end % END: methods

end % END: class
