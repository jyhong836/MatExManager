function [ test_err, train_err, W ] = svm_none_mock ( trK, trY, teK, teY, options )
% SVM_NONE Kernel SVM classifier without corruption.
%
%	[ test_err, train_err ] = svm_none ( trK, training_label, teK, testing_label, struct('C', C) );
%
% INPUT:
%	trK, teK - Matrix of kernel.
%	trY, teY - Vector of labels.
% OUTPUT:
%	test_err, train_err - Classification error rate.
%
% See also libsvm's reference:
%	https://github.com/cjlin1/libsvm/blob/master/README
%	
% Author: Junyuan Hong, 2016-11-30, jyhong836@gmail.com

if ~exist('options', 'var'); options = []; end;
[C] = process_options (options, 'C', 1);

% Train SVM model.
opinion = ['-s 0 -c ' num2str(C) ' -t 4 -q'];
% -s 0: C-SVM
% -t 4: use precomputed kernel
model = svmtrain(trY, [(1:length(trY))' trK], opinion);
if nargout > 1
	[pred_Y, accuracy, prob] = svmpredict(trY, [(1:length(trY))' trK], model, '-b 0 -q'); % '-q' means quite mode
	% disp(find(pred_Y~=trY)');
	train_err = 1 - accuracy(1)/100;
end

% Validate
teK = teK';
[pred_Y, accuracy, prob] = svmpredict(teY, [(1:length(teY))' teK], model, '-b 0 -q');
% disp(find(pred_Y~=teY)');
test_err = 1 - accuracy(1)/100;

W = model;

end
