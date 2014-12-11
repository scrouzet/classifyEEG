function [ w_projected ] = project_weights_back_PCA(w, coeff, ndim)
% w     = weights from classification of the PCA features
% coeff = coeff from pca()
% ndim  = number of dimension to use
%
% seb.crouzet@gmail.com

w_projected = w * coeff(:,1:ndim)';

end

