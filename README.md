# MatExManager
A matlab experiment manager.

## Usage

1. Prepare your classifier implementation in `ClassifierProvider`.
2. Prepare your preprocessor implementation in `PreprocessorProvider` which preprocesses raw data into expected format. For example, you can extract features from image data, compute kernel matrixes from vectors and etc.
3. Prepare your parameter space in `ModelParamProvider`.
4. Ensemble your models inside  `ModelProvider`. A typical `ModelProvider` must be implemented with two static methods.
5. Run all methods provided in `ModelProvider`:
```matlab
EM = ExperimentManager ( datasetName, options ); % Init with data set and options.
EM.setup(); % set up 
EM.runAll(); % Run all required methods.
results = EM.outputResults();
```


## Classes

### ModelProvider

This 

```matlab
% demo of `ModelProvider`
classdef ModelProvider

methods (Static) % methods should be static

function modelNames = getModelNames ()
% A method provides model names.
    modelNames =  {'svm_rbf', % SVM classifier with RBF kernel
    }; 
end

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

end

end
```

### PreprocessorProvider

### ClassifierProvider

### ModelParamProvider




