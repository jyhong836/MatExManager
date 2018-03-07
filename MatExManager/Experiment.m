classdef Experiment < handle
% Experiment class.
%
% Author: Junyuan Hong, 2018-03-06, jyhong836@gmail.com

properties
	result
end

properties (GetAccess=public, SetAccess=private)
	dataName
	modelName
	dataOptions
	modelOptions
    runned
    str
    resultStr
end

methods

function obj = Experiment (dataName, modelName, dataOptions, modelOptions)
	obj.dataName     = dataName;
	obj.modelName    = modelName;
	obj.dataOptions  = dataOptions;
	obj.modelOptions = modelOptions;
	obj.result       = [];
end

function flag = get.runned (obj)
	flag = ~isempty(obj.result);
end

function str = get.str (obj)
	str = ['EX(' obj.dataName ', ' obj.modelName ')'];
end

end

end
