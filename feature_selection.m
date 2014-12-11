function [Xnew, feat_kept, coeff] = feature_selection(X, Y, itrain, itest, res)
% Feature selection using pca or L1
% if strcmp(res.feat_selection,'pca') then res.n_feat needs be defined
% seb.crouzet@gmail.com

Xnew   = nan(size(X,1),res.n_feat,'single');

ndim   = size(X(itrain,:),2);
ntrain = size(X(itrain,:),1);
ntest  = size(X(itest,:),1);

switch res.feat_selection
    
    case 'pca' % Dimensionality reduction using PCA
        
        feat_kept = false(1,size(X(itrain,:),2));
        feat_kept(1:res.n_feat) = 1;
        
        [coeff,score]  = pca(X(itrain,:));  % ~,~,explained
        
        meanXtrain = mean(X(itrain,:),1);
        X_pca_test = bsxfun(@minus, X(itest,:), meanXtrain); % center the features used for testing
        
        X           = nan(size(X));       % reinit
        X(itrain,:) = score;              % Get the projection for the train set features
        X(itest,:)  = X_pca_test * coeff; % Project the test set features
        
        % Reconstruction
        %ndim_recon = ndim; % number of dimensions used
        %Xtrain_recon = bsxfun(@plus, score(:,1:ndim_recon)*coeff(:,1:ndim_recon)', meanXtrain);
        
        %  figure()
        %  pareto(explained,1:20)
        %  xlabel('Principal Component')
        %  ylabel('Variance Explained (%)')
        %  plot(cumsum(explained))
        
    case 'L1'
        
        model = mvpa_train(X(itrain,:),Y(itrain),res.toolbox,'6','off');
        feat_kept = model.w > 0;
end

% Select the features
Xnew = X(:,feat_kept);
%X(:,~feat_kept) = [];

        %x = bsxfun(@rdivide, x, we);
