function [ newdata.X, newdata.test_X, newdata.Y, newdata.test_Y ] = compute_kernel ( ker_fh, data )
% Compute kernel matrix.

newdata.X = random(10);
newdata.test_X = random(10);
newdata.Y = data.Y;
newdata.test_Y = data.test_Y;

end
