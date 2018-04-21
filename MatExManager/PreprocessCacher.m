classdef PreprocessCacher < handle
% Preprocessing cacher: Cache the preprocessed data.
%	The caching relies on the preprocessor.
%
% Example:
%	PC = PreprocessCacher();
%	cahceName = 'aaa';
%	descrip.d = 1;
%	preprocessor = @(data, options) PC.preprocessorWrapper(realPreprocessor, data, options, cacheName, descrip);
%
% See also: DemoDataProvider
%
% Author: Junyuan Hong, 2017-04-07, jyhong836@gmail.com

properties
	updateCache % 0: not update cache; -1: force updating ??; <=-2: updating all cache.
end

methods

function self = PreprocessCacher (options)
	self.updateCache = 0;
end

function newdata = preprocessorWrapper (self, preprocessor, data, options, cacheName, descrip)
% Wrap preprocessor with cacher.
	cachefile = self.run ( @() preprocessor(data, options), cacheName, descrip );
	newdata = load(cachefile);
end

function cachefile = run ( self, getCacheData, cacheName, descrip )
% INPUT:
% 	getCacheData - A function yields data to be cached.
%		[ X, test_X, Y, test_Y ] = getCacheData();
%	cacheName - Cache name
%	descrip - Description will be saved in cache.
% OUTPUT:
%	cachefile - Cache file name.

	[cachefile, foundCache] = check_cache(cacheName);

	doCache = ~foundCache;

	if self.updateCache<=-2
		InfoSystem.say('[CACHE] Force updating cache.');
		doCache = true;
	end

	if doCache
		InfoSystem.say('Caching...');
		data = getCacheData();
		X      = data.X;
		test_X = data.test_X;
		Y      = data.Y;
		test_Y = data.test_Y;

		descrip.date = datetime('now');
		descrip.arch = computer('arch');

		save(cachefile, 'X', 'Y', 'test_X', 'test_Y', 'descrip');
		InfoSystem.say(['[CACHE] Saved to ' cachefile]);
	end
end

end % END: methods

end % END: class

function [cachefile, foundCache] = check_cache(cacheName)
% Check if cache file exist and its datas.
	global CACHE_DIR
	foundCache = false;

	cachefile = fullfile(CACHE_DIR, cacheName);
	if exist(cachefile, 'file')
		InfoSystem.say(['[CACHE] Found cachefile: ' cachefile]);
		foundCache = true;
	else
	end
end

