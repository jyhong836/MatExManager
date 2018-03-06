classdef Experiment < handle

properties
	result
    runned
    str
end

properties (GetAccess=public, SetAccess=private)
	dataName
	modelName
	dataOptions
	modelOptions
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
