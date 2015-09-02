function [Xnew, param] = feature_selection_L1(X, Y, res, param)
% Dimensionality reduction using L1 classification
%
% seb.crouzet@gmail.com

param.feat_kept = false(1,size(X,2));
%param.feat_kept(1:res.n_feat) = 1;

if nargin<4 %exist('param','var') == 0 % param is not an input, usually training
    
    model = mvpa_train(X,Y,res.toolbox,'6','off');
    param.feat_kept = model.w ~= 0;
    
end

% Select the features
Xnew = X(:,param.feat_kept);