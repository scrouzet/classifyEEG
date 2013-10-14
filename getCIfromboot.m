function [ci] = getCIfromboot(X,alpha)
% typically used after a bootstrap to get the CI (Confidence Intervals)

% set the limit depending on the size of the original matrix
limits = round(sort([ alpha*size(X,1) (1-alpha)*size(X,1) ]));

% order the vector
X = sort(X,1);

% get the CI
ci = [X(limits(1),:) ; X(limits(2),:)];