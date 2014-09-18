function [model, best_lambda]= mvpa_train(Xtrain,Ytrain,type,optimization)
%
% Inputs:
%   Xtrain       = matrix of data for training (Trials*features)
%   Ytrain       = vector of train labels (Trials)
%   type         = name of the type type to use ('L1' or 'L2')
%   optimization = optimize the constraint parameter on the training set ('on' or 'off')
%
% Outputs:
%   model           = 
%   weights         = weights associated with each dimension (i.e. feature)
%   best_lambda     = best constraint parameter get by optimization (x)
% 
% Recommendations:
% - Only logistic regression (type = 6 or 7) should be used when you want probability_estimates
%
% Author: seb.crouzet@gmail.com
%
% =========================================================================
% LIBLINEAR Usage (see the toolbox for more detailled information)
% =========================================================================
% 
% model = train(training_label_vector, training_instance_matrix [,'liblinear_options', 'col']);
% 	-s type : set type of solver (default 1) for multi-class classification
% 		 0 -- L2-regularized logistic regression (primal)
% 		 1 -- L2-regularized L2-loss support vector classification (dual)	
% 		 2 -- L2-regularized L2-loss support vector classification (primal)
% 		 3 -- L2-regularized L1-loss support vector classification (dual)
% 		 4 -- support vector classification by Crammer and Singer
% 		 5 -- L1-regularized L2-loss support vector classification
% 		 6 -- L1-regularized logistic regression
% 		 7 -- L2-regularized logistic regression (dual)
% 	  
%     for regression
% 		11 -- L2-regularized L2-loss support vector regression (primal)
% 		12 -- L2-regularized L2-loss support vector regression (dual)
% 		13 -- L2-regularized L1-loss support vector regression (dual)
% 
% 	-c cost : set the parameter C (default 1)

% Make sure that Y is a column vector
if isrow(Ytrain), Ytrain = Ytrain'; end

if ~ischar(type), type = num2str(type); end

%==========================================================================
%                           Classification
%==========================================================================

% Optimization
if ~strcmp(optimization,'off')
    error('need to be reimplemented (see the code below in the source mvpa_train.m file)');
    [best_lambda] = parameterSearch(Xtrain,Ytrain,classifier);
else
    best_lambda = 1;
end

% Classification
model = classif(Xtrain,Ytrain,type,best_lambda);

end


function model = classif(Xtrain,Ytrain,type,best_lambda)
% perform classification
model = train(Ytrain, sparse(double(Xtrain)), ['-s ' type ' -q -c ', num2str(best_lambda)]);

% reorder things according to the label order so that it's always consistent
% by default liblinear order everything according to the order of occurence in the training set
% which can cause trouble afterwards
if ~issorted(model.Label) % labels are not ordered well so we need to make it consistent across training
    [model.Label, ind] = sort(model.Label);
    if size(model.w,1)>1 % multiclass
        model.w = model.w(ind,:);
    else % binary classification
        model.w = -model.w;
    end
end
end
% function [best_lambda] = parameterSearch(Xtrain,Ytrain,type)
% %  NEEDS UPDATE - DOES NOT WORK ANYMORE
% % search for the best C parameter (cost)
% 
% ptraining = 0.5;
% ntraining = round((size(Xtrain,1)*ptraining)/2);
% nfold = 8; % if 8 labs are open, there are thus done all at once (8 labs on the cluster)
% foldPerf = nan(nfold,1);
% 
% % good for LIBLINEAR SVM
% interval = [-10 2]; % previously -15 4
% grain = [1 0.1];
% 
% % grid search to find the best C
% for pas = grain
%     i=1;
%     bestcv = 0;
%     for log2c = interval(1):pas:interval(2)
%         % repeat nfold times to be sure about the estimation for this C value
%         % the nfolds can be parallelized if matlabpool is open, going 8 times faster if 8 labs are available
%         parfor f=1:nfold
%             train = [];
%             labels = unique(Ytrain); % to handle both -1/1 and 0/1, maybe also multiclass
%             for l = 1:length(labels)
%                 c = labels(l);
%                 j = find(Ytrain==c);
%                 t = randperm(length(j));
%                 train = cat(1, train, j(t(1:ntraining)));
%             end
%             test = setdiff(1:size(Ytrain,1), train)';
%             [~,YlatTest,~] = classif(Xtrain(train,:),Xtrain(test,:),Ytrain(train),Ytrain(test),type,2^log2c);
%             perf = measure_perf(YlatTest,Ytrain(test));
%             foldPerf(f) = perf.accuracy;
%         end
%         %fprintf('.')
%         thisCVperf = mean(foldPerf);
%         if (thisCVperf > bestcv),
%             bestcv = thisCVperf;
%             bestc = 2^log2c;
%             bestlog2c = log2c;
%         end
%         i=i+1;
%     end
%     %fprintf(1, '\n')
%     interval(1) = bestlog2c-pas;
%     interval(2) = bestlog2c+pas;
% end
% %fprintf('\n')
% best_lambda = bestc;
% end