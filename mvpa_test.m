function [perf, predicted_label, prob_estimates]= mvpa_test(Xtest,Ytest,model,toolbox,measure)

% Example usage:
% [accuracy,predicted_label,prob_estimates]= mvpa_test(Xtest,Xtrain,model,'libsvm','accuracy')
%
% Inputs:
%   Xtest        = matrix of data for testing (Trials*features)
%   Ytest        = vector of test labels (Trials)
%
% Outputs:
%   perf            = the performance measurement. Can be accuracy, dprime (takes longer) or AUC (takes much longer)
%   predicted_label = vector of categorical labels
%   prob_estimates  = vector of continuous values -> distance from decision boundary for each instance
%
% Author: seb.crouzet@gmail.com

% Make sure that Y is a column vector
if isrow(Ytest),  Ytest  = Ytest'; end

switch toolbox
    case 'liblinear'
        [predicted_label, accuracy, prob_estimates] = predict(double(Ytest), sparse(double(Xtest)), model);
    case 'libsvm'
        [predicted_label, accuracy, prob_estimates] = svmpredict(Ytest, Xtest, model);
%     case 'lda'
%         predict
end

% compute the prob estimates myself (I had issues with those given by liblinear)
prob_estimates = 1./(1+exp(-prob_estimates));
% Note: decision values are usually in the range [-1 1] so the sigmoid 
% transform does not make them bimodal

switch measure
    
    case 'accuracy'
        perf = accuracy(1);
        
    case 'dprime'
        % Evaluate performance
        TP = sum(predicted_label(Ytest == 1) == 1);
        FN = sum(predicted_label(Ytest == 1) == 2);
        TN = sum(predicted_label(Ytest == 2) == 2);
        FP = sum(predicted_label(Ytest == 2) == 1);
        
        %perf.accuracy            = (TP+TN) / (TP+FN+FP+TN);
        
        % +1 on all to avoid Infs or NaNs (dirty trick for d' computing to not get Inf values)
        if any([TP FN TN FP]==0), TP = TP+1; FN = FN+1; TN = TN+1; FP = FP+1; end
        
        pHit = TP / (TP + FN); % True positive rate (pHit) - sensitivity
        pFA  = TN / (TN + FP); % True negative rate () - specificity
        zHit = norminv(pHit) ;
        zFA  = norminv(pFA) ;
        perf = zHit - zFA;
        
        % To use the Statistics Toolbox function
        %perf = dprime(pHit,pFA);
        
    case 'auc'
        perf = get_aroc(Ytest,prob_estimates);
        %[~,~,~,perf] = perfcurve(Ytest,prob_estimates,1);
        
end

% prob_estimates are between 0 and 1
% make them between -128 and 128 to store as int8 and save space
%prob_estimates = uint8(255 * (1./(1+exp(-prob_estimates))));
%prob_estimates = int8(255 * prob_estimates - 255/2);

end