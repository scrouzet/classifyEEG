function [Xnew, param] = feature_selection_ttest(X, Y, res, param)
% Dimensionality reduction using basic t-test
% This would discard any feature that is only "multivariatly" informative
% Might not be a problem in neuroimaging (this is used a lot in fMRI)
%
% seb.crouzet@gmail.com

labels = unique(Y);

if nargin<4 %exist('param','var') == 0 % param is not an input, usually training
    %param.feat_kept = false(1,size(X,2));
    param.feat_kept = ttest(X(Y==labels(1),:),X(Y==labels(2),:),'Alpha',0.001);
%    param.feat_kept = ttest2(X(Y==labels(1),:),X(Y==labels(2),:),'Alpha',0.001,'VarType','unequal');
end

% Select the features
Xnew = X(:,logical(param.feat_kept));