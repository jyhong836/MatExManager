classdef ClassifierProvider
% Author: Junyuan Hong, 2017-12-05, jyhong836@gmail.com

methods (Static)

function [ W, test_err, train_err ] = svm (data)

	options = [];
	if isfield(data, 'options'); options = data.options; end;
	[C, verbose] = process_options (options, 'C', 1, 'verbose', 0);

	[ test_err, train_err, W ] = svm_none ( data.X.K, data.Y, data.test_X.K, data.test_Y, struct('C', C) );

	trN = size(data.X.K, 1);
	hit_num = train_err * trN;
    InfoSystem.say (['  Train error: ' num2str(train_err) ...
            ' (' num2str(hit_num) '/' num2str(trN) ')'], verbose, 1);
	teN = size(data.test_X.K, 2);
	hit_num = test_err * teN;
    InfoSystem.say (['  Test  error: ' num2str(test_err) ...
            ' (' num2str(hit_num) '/' num2str(teN) ')'], verbose, 1);
end

end

end
