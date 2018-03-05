classdef ModelParam < handle
% Provide access to model parameter space.
%	NOTE: the accessed model parameter includes model options.
%	
% Author: Junyuan Hong, 2017-12-04, jyhong836@gmail.com

properties (GetAccess = public, SetAccess = private)
	paramNames       = {};   % Cell array of parameter names.
	paramSpace       = [];   % Numeric matrix of parameter space, where each row is a list of parameters.
	paramRanges      = {};   % Cell array of parameter ranges.
	bestIdxs         = [];   % List of indexs of best parameter.
	bestResult       = [];   % Result for the best parameters.
	validationErrors = [];   % Array of validation errors.
	valErrorList     = [];
	trainErrorList   = [];
	idx              =  0;   % Current parameter index.
	selectLastOne    = true; % Select last best parameter if there are more than one best parameters.
	modelOptions     = [];   % Options for model (classifier), which could include or not include parameters.
    preprocTrigger   = [];   % Logical vector (mask) indicating if preprocessor should be invoked when parameter is changed.
end

properties (Access = ?ModelSelector)
	verbose = 0; % The level of verbose
%     reprocessData    = false; % Require reprocessing data, because parameter was triggered.
end

methods

function MP = ModelParam (paramPairs, modelOptions, selectLastOne, preprocTrigger)
% Initialization
%	modelOptions  - Options for classifiers/models.
%	selectLastOne - Select last best parameter if there are more than one best parameters.
%	pair inputs:
%		paramName  - Parameter names.
%		paramRange - Numeric array of parameter, in normal order.
%	preprocTrigger - A logicial array indicating which parameter will triger data reprocessing.
%	NOTE: if you want a parameter not to be changed frequently, put it in the later.
	MP.initParamSpace(paramPairs);
	if exist('modelOptions', 'var') && ~isempty(modelOptions)
		MP.modelOptions = modelOptions;
	end
	if exist('selectLastOne', 'var') && ~isempty(selectLastOne)
		MP.selectLastOne = selectLastOne;
	end
	if exist('preprocTrigger', 'var') && ~isempty(preprocTrigger)
		MP.preprocTrigger = preprocTrigger;
	end
end

function initParamSpace (MP, paramPairs)
% Init parameter space with (name, range) pair for parameters.
	assert(mod(length(paramPairs), 2)==0, 'Input must be parameter (name, value) pair.');
	nParam = length(paramPairs)/2;
	paramSpace = [];
	paramNames = cell(1, nParam);
	for i = 1:nParam
		idx = (i-1)*2+1;
		paramNames{i}  = paramPairs{idx};
		paramRange     = paramPairs{idx+1};

		% update parameter space
		paramRange = fliplr(paramRange); % reverse the range direction.
		paramRanges{i} = paramRange;
		if isempty(paramSpace)
			paramSpace = reshape(paramRange, [],1);
		else
			newSpace = repmat(reshape(paramRange, 1, []), size(paramSpace, 1), 1);
			paramSpace = [repmat(paramSpace, [length(paramRange), 1]), newSpace(:)];
		end
	end

	MP.paramNames  = paramNames;
	MP.paramSpace  = paramSpace;
    MP.paramRanges = paramRanges;

	MP.idx = size(paramSpace, 1);
    MP.bestIdxs = [];

	MP.validationErrors = zeros(size(paramSpace, 1), 1);
	MP.valErrorList     = zeros(size(paramSpace, 1), 1);
	MP.trainErrorList   = zeros(size(paramSpace, 1), 1);
end

function [paramStruct, reprocessData] = top (MP)
% Get parameter at top
	InfoSystem.say (['[MP] (' num2str(size(MP.paramSpace,1) - MP.idx+1) '/' num2str(size(MP.paramSpace,1)) ')'], MP.verbose, 1);

	paramStruct = MP.paramAtIndex(MP.idx);
	reprocessData = true;
	if MP.idx < size(MP.paramSpace, 1) && MP.compareParam(MP.idx, MP.idx + 1, MP.preprocTrigger)
		reprocessData = false;
	end

	if reprocessData; InfoSystem.say ('Require reprocessing data.', MP.verbose, 1); end;
end

function pop (MP, valError, trError)
% Update the validation error, and pop the last parameter.
	if length(valError) > 1
		curValError = mean(valError);
		MP.valErrorList(MP.idx, 1:length(valError)) = valError;
		MP.trainErrorList(MP.idx, 1:length(trError)) = trError;
	else
		curValError = valError;
	end

	MP.validationErrors(MP.idx) = curValError;
    if length(MP.bestIdxs) < 1
        MP.bestIdxs = MP.idx;
    elseif curValError < MP.validationErrors(MP.bestIdxs(end))
    	MP.bestIdxs = MP.idx;
    elseif curValError == MP.validationErrors(MP.bestIdxs(end))
		MP.bestIdxs(end+1) = MP.idx;
	end
	InfoSystem.say ([' mean error: ' num2str(curValError)], MP.verbose, 1);
	MP.idx = MP.idx - 1;
end

function putBestResult (MP, valError, trError)
	MP.bestResult.test_err = valError;
	MP.bestResult.train_err = trError;
	% InfoSystem.say ([' Train error: ' num2str(trError)], MP.verbose, 1);
	% InfoSystem.say ([' Test  error: ' num2str(valError)], MP.verbose, 1);
end

function ret = hasNext (MP)
% Check if next parameter exists.
	ret = MP.idx > 0;
end

function paramStruct = getBestParam (MP, verbose)
% Get the best parameter in struct.
	if ~exist('verbose', 'var') || isempty(verbose); verbose = MP.verbose; end;
	assert(length(MP.bestIdxs) >= 1, 'No best parameter is available now. Maybe parameter is not selected yet.');
	InfoSystem.say ([' select last best: ' num2str(MP.selectLastOne)], verbose, 1);
	InfoSystem.say ([' # of best param: ' num2str(length(MP.bestIdxs)) '/' num2str(size(MP.paramSpace,1))], verbose, 1);
	if MP.selectLastOne
		idx = MP.bestIdxs(end);
	else
		idx = MP.bestIdxs(1);
	end
	paramStruct = MP.paramAtIndex(idx, verbose);
	InfoSystem.say ([' Best val error: ' num2str(MP.validationErrors(idx))], verbose, 1);
end

function paramStruct = paramAtIndex (MP, idx, verbose)
% Get parameter at index including options.
	if ~exist('verbose', 'var') || isempty(verbose); verbose = MP.verbose; end;
	paramStruct = MP.modelOptions;
	for i = 1:length(MP.paramNames)
		name = MP.paramNames{i};
		paramStruct.(name) = MP.paramSpace(idx, i);
		InfoSystem.say ([' # ' name ' : ' num2str(paramStruct.(name))], verbose, 1);
	end
end

function equal = compareParam (MP, idx1, idx2, mask)
% Compare two parameter vector.
%	Return true if equal.
	if ~exist('mask', 'var') || isempty(mask)
		equal = all((MP.paramSpace(idx1, :) - MP.paramSpace(idx2, :))==0);
	else
		assert(islogical(mask), 'Mask has to be logical array.');
		equal = all((MP.paramSpace(idx1, mask) - MP.paramSpace(idx2, mask))==0);
	end

end

function Z = plotParamErrorSurface (MP)
% Plot the error v.s. param surface
	assert(length(MP.paramNames)==2, 'More than 2 dimension.');
    sz = [length(MP.paramRanges{1}),length(MP.paramRanges{2})];
    X = reshape(MP.paramSpace(:, 1), sz);
    Y = reshape(MP.paramSpace(:, 2), sz);
	Z = reshape(MP.validationErrors, sz);
	mesh(X, Y, Z);
	xlabel(MP.paramNames{1});
	ylabel(MP.paramNames{2});
	zlabel('Evaluation error');
end

end % END: methods

end % END: class
