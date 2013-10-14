% measure_perf() - measure different performances for a classification
%
% Usage: [perf] = measure_perf(Ypredict,Yreal)
%
% Requiered input: 
%
%   Ypredict      = a vector of decimal value predicted by the classiifeur
%   Yreal         = a vector of 1 and -1 labels sames size as Ypredict
%
% Outputs:
%
%   perf          = stuctures containing all the performances
%
% Modified by Sebastien, Serre Lab, 2011
% Autors: Maxime, Serre Lab, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [perf]=measure_perf(Ypredict,Yreal)

% probablility of positive class
%-----------------------------

Yreal    = makeYconsistent(Yreal);
Ypredict = makeYconsistent(Ypredict);

perf.Yreal    = Yreal;
perf.Ypredict = Ypredict;

% Compute perf
%-------------
perf.correctPredict      = Ypredict == Yreal;
perf.n_pos               = length(find(Yreal == 1));
perf.n_neg               = length(find(Yreal == -1));

%                                ACTUAL VALUE
%                         pos                  neg
%-------------------------------------------------------------------
% PREDICTED   pos |   True Positive (TP)   |   False Positive (FP) |
% OUTCOME         |                        |                       |
%             neg |   False Negative (FN)  |   True Negative (TN)  |
%-------------------------------------------------------------------

TP                       = sum(Ypredict(Yreal == 1) == 1);
FN                       = sum(Ypredict(Yreal == 1) == -1);
TN                       = sum(Ypredict(Yreal == -1) == -1);
FP                       = sum(Ypredict(Yreal == -1) == 1);

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