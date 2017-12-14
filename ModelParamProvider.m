classdef ModelParamProvider
% Author: Junyuan Hong, 2017-12-05, jyhong836@gmail.com

methods (Static)

function [ modelParam ] = svm_rbf ( options )
	modelOptions  = struct('verbose', 1);
	selectLastOne = false;

	Cs  = power(10, -4:5);
	gam = power(10, 0:-1:-4);

	modelParam = ModelParam({'C', Cs, 'gam', gam}, modelOptions, selectLastOne, logical([0,1]));
end

end

end
