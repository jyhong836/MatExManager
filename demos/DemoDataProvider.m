classdef DemoDataProvider < DataProvider
% Demo for data provider
%
% Author: Junyuan Hong, 2018-03-06, jyhong836@gmail.com

methods
function self = DemoDataProvider (options)
	self@DataProvider(options);
end
end

methods (Access = protected)

function names = getNames (self)
	names = {'PreWine'};
end

function preprocessor = getPreprocessor (self, name, options)
	switch name
		case 'aaa'
			;
		otherwise
			InfoSystem.say('Use default preprocessor with cacher.');
			data_preprocessor = @PreprocessorProvider.data_preprocessor;
			descrip = options; % Could be more concise when logging.
			PC = PreprocessCacher();
			preprocessor = @(data, options) PC.preprocessorWrapper(data_preprocessor, data, options, ['cache_' name], descrip); % can ecnode options in cache name.
	end
end

function loaded = load_from_file (self, dataname)
% Load from file and return data in struct 'loaded'.
%	You can customize the function to adapt your file format.
	% dataname = self.datasetName;
	global DATA_DIR % TODO: don't use global variable. 
	%	1. The folder name should be only
	% 	2. name change should be flexible for different work env.
	loaded = load(fullfile(DATA_DIR, dataname));
end

end

end
