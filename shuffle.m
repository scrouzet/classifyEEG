function [X] = shuffle(X)
% Not the fastest, but convenient way to shuffle
% If matrix, shuffle rows

if isrow(X), X = X'; end

X = X(randperm(size(X,1)), :);

end

