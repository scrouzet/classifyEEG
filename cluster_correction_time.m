function [sigtime] = cluster_correction_time(sigtime, n)
% assess bins in time when significant differences are stable for n consecutive bins
% This function is based on a trick using strfind() which has revealed to
% be the fastest/more practical way to do it.
%
% Input:
%   sigtime: vector of 0s and 1s
%   n: number of consecutive 1s required (size of the island of 1s)
% 
% Output:
%   sigtime: vector of 0s and 1s containing only the n-sized island of 1s
%
% seb.crouzet@gmail.com

startIndex = strfind(sigtime, ones(1,n));

sigtime = zeros(1,length(sigtime));
if ~isempty(startIndex)
    indices = unique( bsxfun(@plus, startIndex', 0:n-1) )';
    sigtime(indices) = 1;
end