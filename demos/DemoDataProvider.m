classdef DemoDataProvider < DataProvider
% Demo for data provider
%
% Author: Junyuan Hong, 2018-03-06, jyhong836@gmail.com

methods
function self = DemoDataProvider (options)
	preprocessor = @PreprocessorProvider.data_preprocessor;
	self@DataProvider(preprocessor, options);
end
end

methods (Access = protected)

function names = getNames (self)
	names = {'PreWine'};
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
