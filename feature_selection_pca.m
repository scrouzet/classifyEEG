function [Xnew, param] = feature_selection_pca(X, res, param)
% Dimensionality reduction using PCA
% if strcmp(res.feat_selection,'pca') then res.n_feat needs be defined
% seb.crouzet@gmail.com

%Xnew = nan(size(X,1),res.n_feat,'single');
param.feat_kept = false(1,size(X,2));
param.feat_kept(1:res.n_feat) = 1;

if nargin<3 %exist('param','var') == 0 % param is not an input, usually training
    param.meanX = mean(X,1); % to be used on the train set
    [param.coeff, X] = pca(X);  % ~,~,explained
    % 2nd output is scores, which are the projection for the train set features       

else % we just apply the coefficients (usually testing)
    X = bsxfun(@minus, X, param.meanX); % center the features used for testing based on training
    X = X * param.coeff;                % project the test set features
end

% Select the features
Xnew = X(:,param.feat_kept);

% Reconstruction
%ndim_recon = ndim; % number of dimensions used
%Xtrain_recon = bsxfun(@plus, score(:,1:ndim_recon)*coeff(:,1:ndim_recon)', meanXtrain);

%  figure()
%  pareto(explained,1:20)
%  xlabel('Principal Component')
%  ylabel('Variance Explained (%)')
%  plot(cumsum(explained))

%     case 'L1'
%
%         model = mvpa_train(X(itrain,:),Y(itrain),res.toolbox,'6','off');
%         feat_kept = model.w > 0;