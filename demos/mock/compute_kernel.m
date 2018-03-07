function [ X, test_X, Y, test_Y ] = compute_kernel ( ker_fh, data )
% Compute kernel matrix.

X.K      = compute_kernel_(data.X, [], ker_fh);
test_X.K = compute_kernel_(data.X, data.test_X, ker_fh);
Y        = data.Y;
test_Y   = data.test_Y;

end

% ------------

function K = compute_kernel_ (models1, models2, ker)

if ~exist('ker', 'var') || isempty(ker)
	ker = @(x1, x2) x1'*x2;
end

USE_PAR_KER = false;
ignore_diag = false;
isSquareKernel = ~exist('models2','var') || isempty(models2);
N1 = length(models1);
if ~isSquareKernel
	N2 = length(models2);
	K = zeros(N1, N2);
	if USE_PAR_KER % parallel kernel computation
	parfor i=1:N1
		m1 = models1{i};
		for j=1:N2
			K(i, j) = ker(m1, models2{j});
		end
	end
	else % not parallel kernel computation
	for i=1:N1
		m1 = models1{i};
		for j=1:N2
			K(i, j) = ker(m1, models2{j});
		end
	end
	end
else
	K = zeros(N1, N1);
	for i=1:N1
		m1 = models1{i};
		for j=1:i-1
			K(i, j) = ker(m1, models1{j});
		end
	end
	K = K + K';
	% diag
	if ~ignore_diag
		for i=1:N1
			K(i, i) = ker(models1{i}, models1{i});
		end
	end
end

end
