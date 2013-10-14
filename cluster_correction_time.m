function [sigtime] = selectivitySuccessiveBins(sigtime, n)
% assess bins in time when significant differences are stable for n consecutive bins
%
% Input:
%   sigtime: vector of 0s and 1s
%   n: number of consecutive 1s required
%
% seb.crouzet@gmail.com

for t = 1:length(sigtime)
     
    % special case for the beginning of the vector
    if t < n
        if sigtime(t) == 1
            if sum(sigtime(t:t+n)) < n
                sigtime(t) = 0;
            end
        end
        
    % special case for the end of the vector
    elseif t > length(sigtime)-n
        if sigtime(t) == 1
            if sum(sigtime(t-n:t)) < n
                sigtime(t) = 0;
            end
        end
        
    % regular case
    elseif sigtime(t) == 1
        if sum(sigtime(t-(n-1):t+(n-1))) < n
            sigtime(t) = 0;
        end
    end
  
end