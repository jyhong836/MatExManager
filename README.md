# MatExManager
A matlab experiment manager.

## Usage

1. Prepare your classifier implementation in [`ClassifierProvider`](#modelprovider).
2. Prepare your preprocessor implementation in [`PreprocessorProvider`](#preprocessorprovider) which preprocesses raw data into expected format. For example, you can extract features from image data, compute kernel matrixes from vectors and etc.
3. Prepare your parameter space in [`ModelParamProvider`](#modelparamprovider).
4. Ensemble your models inside  [`ModelProvider`](#modelprovider). A typical `ModelProvider` must be implemented with two static methods.
5. Run all methods provided in `ModelProvider` or see more in [demo](/demo.m):
```matlab
EM = ExperimentManager ( datasetName, options ); % Init with data set and options.
EM.setup(); % set up 
EM.runAll(); % Run all required methods.
results = EM.outputResults(); % Get formatted results.
```


## Classes

### PreprocessorProvider

This class provides sets of preprocessors for feature extraction, kernel computing and etc. An example computing kernel matrixes:
```matlab
function newdata = kernel_preprocessor (data, kernelType)
% cell array of data vectors -> kernel matrix.

	% Kernel function handler
	switch lower(kernelType)
		case 'rbf'
			ker_fh = @(x1, x2) exp(-gam* sum((x1 - x2).^2));
	end

	% compute kernel
	start_time = cputime();
	fprintf(' Computing kernel...');
	[ newdata.X, newdata.test_X, newdata.Y, newdata.test_Y ] = ...
		compute_kernel ( ker_fh, data );
	disp([' cputime: ' num2str(cputime()-start_time)]);

end
```

### ClassifierProvider

An example of SVM:
```matlab
function [ W, test_err, train_err ] = svm (data)
	options = [];
	if isfield(data, 'options'); options = data.options; end;
	% extract options
	[C, verbose] = process_options (options, 'C', 1, 'verbose', 0);

	[ test_err, train_err, W ] = svm_none ( data.X.K, data.Y, data.test_X.K, data.test_Y, struct('C', C) );
end
```

### ModelParamProvider

This class provide static methods to return `ModelParam` objects which enclose the whole parameter space for model selection. A simple demo:
```matlab
function [ modelParam ] = svm_rbf ( options )
        % Create a ModelParam with parameter space. Format: {'name', range, 'name', range, ...}
	modelParam = ModelParam({'C', power(10, -4:5), ... 
	                         'gam', power(10, 0:-1:-4)}); 
end
```


### ModelProvider

This class implement two static methods inside: `getModelNames` and `getModelByName`. You can modify the file, [ModelProvider.m](/ModelProvider.m), to add your own models.

First, add string names of your models.
```matlab
function modelNames = getModelNames ()
% A method provides model names.
    modelNames =  {'svm_rbf', % SVM classifier with RBF kernel
    }; 
end
```

Second, enclose the elements of models.
```matlab
function [preprocessor, classifier, modelParam] = getModelByName ( name, options )
% A method provides real models by name.
% INPUT:
%   name - The name.
%   options - The option to be provided to `ModelParamProvider`, see `ModelParamProvider.m` for details.

    % Prepare
    switch name
        case 'svm_rbf'
            modelParam   = ModelParamProvider.dg_gau(options); % A `ModelParam` object, see `ModelParamProvider` for details.
            classifier   = @ClassifierProvider.svm; % A classifier handler.
            preprocessor = @(data)PreprocessorProvider.kernel_preprocessor(data, 'rbf'); % A preprocessor, see `PreprocessorProvider` for example.
        otherwise
            error(['Unknown model name: ' name]);
    end
end
```
The three output should be formatted:
+ `preprocessor` (function handler): `newdata = fun (data)` where struct `newdata` should contain three fields: `X`, `Y`, `test_X`, `test_Y` as training data&label, testing datta&label.
+ `classifier` (function handler): `[ W, test_err, train_err ] = fun (data)` where 
  - `data` is struct with fields like: `data.X.K, data.Y, data.test_X.K, data.test_Y, data.options`;
  - `W` is model, e.g. matrix of classifier coeficients.
  - `test_err`, `train_err`: test/train error rate on the test set.
+ `modelParam` (`ModelParam` object): See [`ModelProvider`](#modelprovider) for how to generate a model parameter space easily.

