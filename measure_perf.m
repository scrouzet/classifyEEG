function [perf]=measure_perf(Ypredict,Yreal)
% measure_perf() - measure different performances for a classification
% Usage: [perf] = measure_perf(Ypredict,Yreal)
%
% Required input: 
%   Ypredict      = a vector of decimal value predicted by the classifier (1 for targets, 2 for distractors)
%   Yreal         = a vector of 1 and -1 labels sames size as Ypredict (1 for targets, 2 for distractors)
%
% Outputs:
%   perf          = stuctures containing all the performances
%
% Author: Sebastien Crouzet, Serre Lab, 2011 seb.crouzet@gmail.com

% probablility of positive class
%-----------------------------

% I removed makeYconsistent because this took too much time.
% Labels should be 1 and 2
%Yreal    = makeYconsistent(Yreal);
%Ypredict = makeYconsistent(Ypredict);

perf.Yreal    = Yreal;
perf.Ypredict = Ypredict;

% Compute perf
%-------------
perf.correctPredict      = Ypredict == Yreal;
perf.n_pos               = length(find(Yreal == 1));
perf.n_neg               = length(find(Yreal == 2));

%                                ACTUAL VALUE
%                         pos                  neg
%-------------------------------------------------------------------
% PREDICTED   pos |   True Positive (TP)   |   False Positive (FP) |
% OUTCOME         |                        |                       |
%             neg |   False Negative (FN)  |   True Negative (TN)  |
%-------------------------------------------------------------------

TP                       = sum(Ypredict(Yreal == 1) == 1);
FN                       = sum(Ypredict(Yreal == 1) == 2);
TN                       = sum(Ypredict(Yreal == 2) == 2);
FP                       = sum(Ypredict(Yreal == 2) == 1);

perf.TP                  = TP;
perf.FN                  = FN;
perf.TN                  = TN;
perf.FP                  = FP;

perf.accuracy            = (TP+TN) / (TP+FN+FP+TN);

% +1 on all to avoid Infs or NaNs (dirty trick for d' computing)
if any([TP FN TN FP]==0), TP = TP+1; FN = FN+1; TN = TN+1; FP = FP+1; end

perf.sensitivity         = TP / (TP + FN); % True positive rate (pHit)
perf.specificity         = TN / (TN + FP); % True negative rate
perf.PPV                 = TP / (TP + FP); % Positive Predictive Value
perf.NPV                 = TN / (TN + FN); % Negative Predictive Value

perf.fpr                 = FP / (FP + TN); % False positive rate = 1 - specificity (pFA)
perf.fnr                 = FN / (TP + FN); % False negative rate = 1 - sensitivity
perf.fdr                 = FP / (FP + TP); % False Discovery Rate
perf.likelihoodRatioPos  = perf.sensitivity / (1 - perf.specificity);
perf.likelihoodRatioNeg  = (1 - perf.sensitivity) / perf.specificity;

pHit = perf.sensitivity;
pFA  = perf.fpr;
zHit = norminv(pHit) ;
zFA  = norminv(pFA) ;
perf.dprime              = zHit - zFA;
%if type == '2AFC', d = d * (1/sqrt(2)); end

yHit = normpdf(zHit) ;
yFA  = normpdf(zFA) ;
perf.beta                = yHit ./ yFA;
% perf.beta              = exp(-zHit*zHit/2+zFA*zFA/2); % alternative to compute beta

a = 1/2+((pHit+pFA)*(1+pHit-pFA) / (4*pHit*(1-pFA)));
b = 1/2-((pFA-pHit)*(1+pFA-pHit) / (4*pFA*(1-pHit)));
a(pFA>pHit) = b(pFA>pHit); % trick to handle the two cases fa>hit and fa<hit without loop
a(pFA==pHit) = .5;
perf.aprime              = a; % A' = Area Under Curve (AUC)
	
perf.bppd                = ((1-pHit)*(1-pFA)-pHit*pFA) / ((1-pHit)*(1-pFA)+pHit*pFA);

% Clarifying various terms for evaluating classifier (or hypothesis testing) performance
% by Alex Hartemink amink@cs.duke.edu
%
%true positives:  TP
%true negatives:  TN
%false positives: FP (type I error)
%false negatives: FN (type II error)
%
%measures whose denominator involves the entire sample:
%
%   prevalence = (TP+FN)/(TP+TN+FP+FN)
%   error rate = (FP+FN)/(TP+TN+FP+FN)
%   accuracy   = (TP+TN)/(TP+TN+FP+FN)
%
%      prevalence measures the proportion of cases that are positive
%         and is thus independent of the classifier; the prevalence 
%         of negative cases could also be defined analogously
%      accuracy is also called efficiency
%      note that error rate + accuracy = 1
%
%measures whose denominator involves only the positive cases:
%
%   true positive rate  = TP/(TP+FN)
%   false negative rate = FN/(TP+FN)
%
%      true positive rate is also called recall, recall ratio, sensitivity
%      note that true positive rate + false negative rate = 1
%
%measures whose denominator involves only the negative cases:
%
%   true negative rate  = TN/(TN+FP)
%   false positive rate = FP/(TN+FP)
%
%      true negative rate is also called specificity
%      note that true negative rate + false positive rate = 1
%
%measures whose denominator involves only the positive predictions:
%
%   positive predictive value = TP/(TP+FP)
%   false discovery rate = FP/(TP+FP)
%
%      positive predictive value is also called precision, precision ratio
%      note that positive predictive value + false discovery rate = 1
%
%measures whose denominator involves only the negative predictions:
%
%   negative predictive value = TN/(TN+FN)
%
%finally, an ROC curve is a plot of true positive rate (or recall or sensitivity or (1-false negative rate)) 
%                           versus false positive rate (or (1-true negative rate) or (1-specificity))