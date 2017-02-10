function [X] = get_and_shape_X(X,t,intwin)
% X = is the same shape as an EEG.data from EEGlab
% t = the time point of interest
% intwin = how many timepoints back in time should we integrate

% Get X for the timepoints
if t>=intwin,
    X = squeeze(X(:,t-intwin:t,:));
elseif t<intwin,
    X = squeeze(X(:,1:t,:));    
end
% Reshape it appropriately
if t==1,
    X = X';
else X = reshape(X,[size(X,1)*size(X,2) size(X,3)])';
end
