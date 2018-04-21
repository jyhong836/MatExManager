% @Author: Junyuan Hong
% @Date:   2017-12-14
% @Last Modified by:   Junyuan Hong
% @Last Modified time: 2018-04-21

% Add path: elements of MatExManager
addpath(genpath('./MatExManager/'));

global DATA_DIR TEMP_DIR CACHE_DIR
TEMP_DIR = './demos/temp/'; % Store output or other temp files.
DATA_DIR = './demos/temp/'; % Store data.
CACHE_DIR = fullfile(TEMP_DIR, 'cache'); % For caching files.

if ~exist(TEMP_DIR, 'dir')
	disp(['Not found temp dir. Creating: ' TEMP_DIR]);
	mkdir(TEMP_DIR);
end
if ~exist(CACHE_DIR, 'dir')
	disp(['Not found cache dir. Creating: ' CACHE_DIR]);
	mkdir(CACHE_DIR);
end
if ~exist(DATA_DIR, 'dir')
	error(['Not found cache dir: ' DATA_DIR]);
	mkdir(DATA_DIR);
end
