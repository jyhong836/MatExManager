classdef ModelParamProvider
% Author: Junyuan Hong, 2017-12-05, jyhong836@gmail.com

methods (Static)

function [ modelParam ] = svm_rbf ( options )
	modelOptions  = struct('verbose', 1); % Model options.
	selectLastOne = false; % select last parameter pack if there are more than one parameter packs yielding identical validation error rates.

	Cs  = power(10, -4:5); % Define parameter range.
	gam = power(10, 0:-1:-4);

	modelParam = ModelParam({'C', Cs, 'gam', gam}, ... % parameter space. Format: {'name', range, 'name', range, ...}
                            modelOptions, selectLastOne, ... % optional settings.
                            logical([0,1])); % Define which parameter will trigger preprocessing, i.e., calling `preprocessor`.
end

end

end
