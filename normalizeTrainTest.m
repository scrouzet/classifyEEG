function [XtrainNorm,XtestNorm,param] =  mvpa_normalize(Xtrain,Xtest,method,param)
% normalizeTrainTest() - normalize train and test sets based on the train set
%
% Usage:  [XtrainNorm,XtestNorm] = normalizeTrainTest(Xtrain,Xtest,'scale')
%
% Input:
% - Xtrain     = matrix for training the classifier (trials*features)
% - Xtest      = matrix for testing the classifier (trials*features)
% - method     = 'scale' or 'zscore' (from my experience, scale is usually better for SVM)
%
% Outputs:
% - XtrainNorm = normalized matrix for training the classifier (trials*features)
% - XtestNorm  = normalized matrix for testing the classifier (trials*features)
%
% Author: seb.crouzet@gmail.com

if exist('param','var') == 0 % param is not an input (most common case)
    
    param{1} = method;
    
    if strcmp(method,'zscore')
        
        m = mean(Xtrain,1);
        s = std(Xtrain,[],1);
        
        XtrainNorm = (Xtrain - repmat(m,size(Xtrain,1),1)) ./ repmat(s,size(Xtrain,1),1);
        XtestNorm  = (Xtest - repmat(m,size(Xtest,1),1)) ./ repmat(s,size(Xtest,1),1);
        
        param{2} = m;
        param{3} = s;
        
    elseif strcmp(method,'scale')
        
        data = Xtrain;
        minV  = min(data,[],1);
        maxV  = max(data,[],1);
        [R,C] = size(data);
        XtrainNorm = (data - repmat(minV,R,1))*full(spdiags(1./(maxV-minV)',0,C,C));
        
        data = Xtest;
        [R,C] = size(data);
        XtestNorm = (data - repmat(minV,R,1))*full(spdiags(1./(maxV-minV)',0,C,C));
        
        param{2} = minV;
        param{3} = maxV;
        
    end
    
    % needed for 'zscore', I don't know for 'scale'
    % if some features are always 0, then s=0 and then there is inf values
    XtrainNorm(isinf(XtrainNorm)) = 0;
    XtestNorm(isinf(XtestNorm))   = 0;
    
    % also remove nans, not sure why there is some sometimes
    XtrainNorm(isnan(XtrainNorm)) = 0;
    XtestNorm(isnan(XtestNorm))   = 0;
    
else % param is an input (Xtrain is not required)
    
    if strcmp(method,param{1})==0
        error('The normalization method is not the one that was used during training.')
    end
    
    if strcmp(method,'zscore')
        m = param{2};
        s = param{3};
        XtestNorm  = (Xtest - repmat(m,size(Xtest,1),1)) ./ repmat(s,size(Xtest,1),1);
        
    elseif strcmp(method,'scale')
        minV  = param{2};
        maxV  = param{3};
        data = Xtest;
        [R,C] = size(data);
        XtestNorm = (data - repmat(minV,R,1))*full(spdiags(1./(maxV-minV)',0,C,C));
    end
    XtestNorm(isinf(XtestNorm))   = 0;
    XtestNorm(isnan(XtestNorm))   = 0;
    XtrainNorm = [];
end