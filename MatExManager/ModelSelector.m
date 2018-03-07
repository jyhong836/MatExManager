classdef ModelSelector < handle
% Model selector
%
% Example:
%	[ W, test_err(icv), train_err(icv) ] = classifier (data(icv));
%	MP = ModelParam (paramPairs, modelOptions, selectLastOne, paramTrigger);
%	MS = ModelSelector (data, preprocessor, classifier, MP);
%	MS.selectModel();
%	result = MS.evaluateModel();
%	report = MS.getReport();
%
% Author: Junyuan Hong, 2017-12-04, jyhong836@gmail.com

properties (Access = public)
	verbose = 1; % The level of verbose
end

properties (GetAccess = public, SetAccess = private)
	CVMethod     = 'Kfold'; % Method of cross-validation (CV)
	CVParam      = 10;      % CV parameter
	result       = [];      % result
end

properties (Access = private)
	dataProvider  = [];           % data
	preprocessor = @(data) data; % Function called before creating CV sets.
	classifier   = @(data) data; % Classifier
	modelParam   = [];           % See ModelParam.
	TestSet      = [];           % Set storing test set (not data).
	cvdata       = [];           % Preprocessed CV data.
	predata      = [];           % Preprocessed data.
end % END: properties

methods

function MS = ModelSelector (dataProvider, preprocessor, classifier, modelParam)
	MS.dataProvider = dataProvider;
	MS.preprocessor = preprocessor;
	MS.classifier   = classifier;
	MS.modelParam   = modelParam;
end

function selectModel (MS)
% Select model by cross evaluating on parts of the data set.
	MS.createCVSet();
	while MS.modelParam.hasNext()
		[param, reprocessData] = MS.modelParam.top();
		if reprocessData
			MS.prepareData(param, true);
		end

		[validationError, trainError ] = MS.evaluate (MS.cvdata, param);

		MS.modelParam.pop(validationError, trainError);
	end
end

function result = evaluateModel (MS)
% Evaluate model on test set.
	InfoSystem.say ('[BEST] Evaludate selected model.', MS.verbose, 1);
	param = MS.modelParam.getBestParam();
	MS.prepareData(param, false);
	[result.test_err, result.train_err, result.W] = MS.evaluate(MS.predata, param);
	MS.result = result;
	MS.modelParam.putBestResult (result.test_err, result.train_err);
end

function report = getReport (MS, level)
%	level - The level of report.
	if ~exist('level', 'var') || isempty(level); level = 1; end;
	report = MS.modelParam.getBestParam(0);
	assert(~isempty(MS.result), 'Model selection has not been run yet.');
	report.test_err = MS.result.test_err;
	report.train_err = MS.result.train_err;
	if level > 1
		report.W = W;
		report.verrs = MS.modelParam.validationErrors;
	end
end

function set.verbose (MS, v)
	MS.verbose = v;
	MS.modelParam.verbose = v;
end

end % END: methods

methods (Access = private)

function prepareData (MS, options, doCV)
% Preprocess data and data options.
	MS.predata = MS.preprocessor(MS.dataProvider, options);
	if doCV
		MS.cvdata  = MS.createCVData(MS.predata);
	end
end

function [ test_err, train_err, W ] = evaluate (MS, data, param)
% Evaluate for CV or non-CV data.
	ncv       = length(data);
	test_err  = zeros(1, ncv);
	train_err = zeros(1, ncv);
	if ncv > 1 && MS.verbose < 2
		param.verbose = 0;
	end
	for icv = 1:ncv
		data(icv).options = param;
		[ W, test_err(icv), train_err(icv) ] = MS.classifier (data(icv));
	end
end

function cvdata = createCVData (MS, data)
% Create cross-validation set with given data.
	assert(~isempty(MS.TestSet), 'Test set is not set yet. Call createCVSet first.');
	switch MS.CVMethod
		case 'Kfold'
			for k=1:MS.CVParam
				[cvdata(k).X, cvdata(k).Y, cvdata(k).test_X, cvdata(k).test_Y] ...
                    = MS.trte_part(data.X, data.Y, MS.TestSet~=k, MS.TestSet==k);
				% tds(k).options = ds.options;
			end
		otherwise
			error(['Unknown CV method: ' method]);
	end
end

function createCVSet (MS)
% Create Train/Test indicators who are boolean arrays.
	disp(['[' MS.CVMethod '] Creating ' num2str(MS.CVParam) ' validation sets.']);
	MS.TestSet = crossvalind(MS.CVMethod, MS.dataProvider.Y, MS.CVParam);
end

function [train_X, train_Y, test_X, test_Y] = trte_part(MS, X, Y, Train, Test)
% Slice the data set (X, Y) according to Train/Test who are boolean arrays.
	if iscell(X) % cell array
		train_X = X(Train);
		test_X  = X(Test);
	else % kernel matrix
		train_X.K     = X.K(Train, Train);
		test_X.K      = X.K(Train, Test);
	end
	train_Y = Y(Train);
	test_Y  = Y(Test);
end

end % END: methods (Access = private)

end % END: class
