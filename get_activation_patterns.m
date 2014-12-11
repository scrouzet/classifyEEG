function [A] = get_activation_patterns(X,w)
% [A] = get_activation_patterns(X,w);
%
% INPUT:
% X = m*n matrix, where m are the number of observations and n are the number of features (e.g. voxels or channels)
% w = weight vector of length n
%
% OUTPUT:		
% A = activation patterns 
	
A = cov(X) * w;