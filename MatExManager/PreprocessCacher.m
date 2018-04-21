classdef PreprocessCacher < handle
% Preprocessing cacher: Cache the preprocessed data.
%	The caching relies on the preprocessor.
%
% Example:
%
% Author: Junyuan Hong, 2017-04-07, jyhong836@gmail.com

properties
	updateCache % 0: not update cache; -1: force updating ??; <=-2: updating all cache.
end

methods

function self = PreprocessCacher (options)
	updateCache = 0;
end

function cachefile = doCache ( cacheData, cacheName, descrip )
% INPUT:
% 	cacheData - A function yields data to be cached.
%		[ X, test_X, Y, test_Y ] = cacheData();
%	cacheName - Cache name
%	descrip - Description will be saved in cache.

	if ~exist('updateCache', 'var') || isempty(updateCache)
		updateCache = 0;
	end

	[cachefile, foundCache] = check_cache(cacheName);

	doCache = ~foundCache;

	if updateCache<=-2
		disp('[CACHE] Force updating cache.');
		doCache = true;
	end

	if doCache
		disp('Caching...');
		[ X, test_X, Y, test_Y ] = cacheData();

		descrip.date = datetime('now');
		descrip.arch = computer('arch');

		save(cachefile, 'X', 'Y', 'test_X', 'test_Y', 'descrip');
		disp(['[CACHE] Saved to ' cachefile]);
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
		disp(['[CACHE] Found cachefile: ' cachefile]);
		foundCache = true;
	else
	end
end

