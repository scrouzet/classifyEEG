function [sigtime] = selectivitySuccessiveBins(sigtime, n)
% assess bins in time when significant differences are stable for n consecutive bins
%
% Input:
%   sigtime: vector of 0s and 1s
%   n: number of consecutive 1s required
%
% seb.crouzet@gmail.com

mycount = 0;
sigtime(1:n) = 0; % in any case, this is baseline but it's just to have a simpler loop after
for t = 1:length(sigtime)
    if sigtime(t) == 1
        mycount = mycount+1;
    elseif sigtime(t) == 0 && mycount<n && t>n
        sigtime(t-n : t-1) = 0;
        mycount = 0;
    end
end