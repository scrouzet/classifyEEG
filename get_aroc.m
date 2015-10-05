function [aroc,pval] = get_aroc(lab,dat)
%  GET_AROC  Get area under ROC curve
%
%  Usage:
%    >> [aroc] = get_aroc(lab,dat)
%
%  Input arguments:
%    - lab = category labels
%    - dat = data
%
%  Valentin Wyart <valentin.wyart@ens.fr>

if nargin < 2
    error('missing input argument(s)!');
end

% % preprocess category labels
% lab = lab(:); % columnize category labels
% [lab_lst,~,lab] = unique(lab); % re-label using integers
% 
% % preprocess data
% dat = dat(:); % columnize data
% if length(lab_lst) ~= 2 || length(dat) ~= length(lab)
%     error('invalid data format!');
% end

x = dat(lab == 1);
y = dat(lab == 2);
m = length(x);
n = length(y);

% compute area under ROC curve
aroc = 0;
for i = 1:m
    % changed > to < here. MC
    aroc = aroc+nnz(y < x(i))+0.5*nnz(y == x(i));
end
aroc = aroc/m/n;

if nargout > 1
    % compute corresponding p-value
    pval = ranksum(x,y);
end

end