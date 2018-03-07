classdef ModelProvider < handle
% Model provider.
%	To provide models, subclass this and implement abstract methods.
%
% Author: Junyuan Hong, 2018-03-06, jyhong836@gmail.com

properties
	names
end

methods

function MP = ModelProvider ()
	InfoSystem.say('Using default model provider.')
end

function modelNames = get.names (MP)
	modelNames = MP.getNames;
end

end

methods (Abstract)

names = getNames (MP)

[preprocessor, classifier, modelParam] = getModelByName ( MP, name, options )
% A method provides real models by name.
% INPUT:
%   name - The name of model.
%   options - The option to be provided to `ModelParamProvider`, see `ModelParamProvider.m` for details.

end

end
