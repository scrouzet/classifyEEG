function [X] = shuffle(X)
% Not the fastest, but convenient way to shuffle
% If matrix, shuffle rows
% we_transposed_it=0;

% if isrow(X), 
%     X = X';
%     we_transposed_it = 1;
% end

X = X(randperm(size(X,1)), :);

% if we_transposed_it==1,
%     X = X'; 
% end

end

