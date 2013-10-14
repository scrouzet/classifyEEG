function [Y] = makeYconsistent(Y)
% make a binary vector Y to be made of [1 and 2], and not [1 and 0] or [1 and -1]
% This is better because will require minor change to do multi-class classification
%
% seb.crouzet@gmail.com

% if labels are 0 and 1, transform to 1 and 2
if all(unique(Y)==[0;1])
    Y(Y==0)=2;
end

% if labels are 1 and -1, transform to 1 and 2
if all(unique(Y)==[-1;1])
    Y(Y==-1)=2;
end