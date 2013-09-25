function [predicted_label,accuracy,prob_estimates,weights,best_lambda]= classification(Xtrain,Xtest,Ytrain,Ytest,regularization,optimization)
%function [YlatTr,YlatTest,B_new,best_lambda]= classification(Xtrain,Xtest,Ytrain,Ytest,regularization,optimization)
% classification() - run the classification of something
%
% Only logistic regression is used because this is the only one to allow
% for meaningful interpretation of probability_estimates.
% 
% Example usage: 
% [YlatTr,YlatTest,B_new,best_lambda] = classification(Xtrain, Xtest, Ytrain, Ytest, 'L2', 'off');
%
% -------------------------------------------------------------------------
% Inputs:
%   Xtrain         = matrix of data for training (Trials*features)
%   Xtest          = matrix of data for testing (Trials*features)
%   Ytrain         = vector of train labels (Trials)
%   Ytest          = vector of test labels (Trials)
%   regularization = name of the regularization type to use ('L1' or 'L2')
%   optimization   = optimize the constraint parameter on the training set ('on' or 'off')
%
% -------------------------------------------------------------------------
% Outputs:
%   YlatTr         = colon vector of decimal value predicted by the
%                     algorithm for training set, to get the predicted value
%                     sign(YlatTr) (Trials)
%   YlatTest       = colon vector of decimal value predicted by the
%                     algorithm for test set, to get the predicted value
%                     sign(YlatTest) (Trials)
%   B_new          = weights (features)
%   best_lambda    = best constraint parameter get by optimization (x)
% -------------------------------------------------------------------------
% 
% Author: seb.crouzet@gmail.com
%
% LIBLINEAR Usage
% ===============
% 
% matlab> model = train(training_label_vector, training_instance_matrix [,'liblinear_options', 'col']);
% 
%         -training_label_vector:
%             An m by 1 vector of training labels. (type must be double)
%         -training_instance_matrix:
%             An m by n matrix of m training instances with n features.
%             It must be a sparse matrix. (type must be double)
%         -liblinear_options:
%             A string of training options in the same format as that of LIBLINEAR.
%         -col:
%             if 'col' is set, each column of training_instance_matrix is a data instance. Otherwise each row is a data instance.
% 
% matlab> [predicted_label, accuracy, decision_values/prob_estimates] = predict(testing_label_vector, testing_instance_matrix, model [, 'liblinear_options', 'col']);
% 
%         -testing_label_vector:
%             An m by 1 vector of prediction labels. If labels of test
%             data are unknown, simply use any random values. (type must be double)
%         -testing_instance_matrix:
%             An m by n matrix of m testing instances with n features.
%             It must be a sparse matrix. (type must be double)
%         -model:
%             The output of train.
%         -liblinear_options:
%             A string of testing options in the same format as that of LIBLINEAR.
%         -col:
%             if 'col' is set, each column of testing_instance_matrix is a data instance. Otherwise each row is a data instance.
% 
%
% 	liblinear_options:
% 	-s type : set type of solver (default 1) for multi-class classification
% 		 0 -- L2-regularized logistic regression (primal)\n"
% 		 1 -- L2-regularized L2-loss support vector classification (dual)\n"	
% 		 2 -- L2-regularized L2-loss support vector classification (primal)\n"
% 		 3 -- L2-regularized L1-loss support vector classification (dual)\n"
% 		 4 -- support vector classification by Crammer and Singer\n"
% 		 5 -- L1-regularized L2-loss support vector classification\n"
% 		 6 -- L1-regularized logistic regression\n"
% 		 7 -- L2-regularized logistic regression (dual)\n"
% 	  for regression\n"
% 		11 -- L2-regularized L2-loss support vector regression (primal)\n"
% 		12 -- L2-regularized L2-loss support vector regression (dual)\n"
% 		13 -- L2-regularized L1-loss support vector regression (dual)\n"
% 	-c cost : set the parameter C (default 1)\n"
% 	-p epsilon : set the epsilon in loss function of SVR (default 0.1)\n"
% 	-e epsilon : set tolerance of termination criterion\n"
% 		-s 0 and 2\n" 
% 			|f'(w)|_2 <= eps*min(pos,neg)/l*|f'(w0)|_2,\n" 
% 			where f is the primal function and pos/neg are # of\n" 
% 			positive/negative data (default 0.01)\n"
% 		-s 11\n"
% 			|f'(w)|_2 <= eps*|f'(w0)|_2 (default 0.001)\n" 
% 		-s 1, 3, 4 and 7\n"
% 			Dual maximal violation <= eps; similar to libsvm (default 0.1)\n"
% 		-s 5 and 6\n"
% 			|f'(w)|_1 <= eps*min(pos,neg)/l*|f'(w0)|_1,\n"
% 			where f is the primal function (default 0.01)\n"
% 		-s 12 and 13\n"
% 			|f'(alpha)|_1 <= eps |f'(alpha0)|,\n"
% 			where f is the dual function (default 0.1)\n"
% 	-B bias : if bias >= 0, instance x becomes [x; bias]; if < 0, no bias term added (default -1)\n"
% 	-wi weight: weights adjust the parameter C of different classes (see README for details)\n"
% 	-v n: n-fold cross validation mode\n"
% 	-q : quiet mode (no outputs)\n"

%==========================================================================
%                           Initializations
%==========================================================================

B_init = [];

% Add bias at the end
%-------------------
Xtrain      = [Xtrain ones(size(Xtrain,1),1)];
Xtest       = [Xtest ones(size(Xtest,1),1)];

% Make sure that Y is a column vector
if isrow(Ytrain), Ytrain = Ytrain'; end
if isrow(Ytest),  Ytest  = Ytest'; end

%==========================================================================
%                           Classification
%==========================================================================

% Optimization
%----------------
if ~strcmp(optimization,'off')
    
    [best_lambda B_init] = parameterSearch(Xtrain,Ytrain,classifier);
else
    best_lambda = 1;
end

% Classification
%----------------
%[YlatTr,YlatTest,B_new]= classif(Xtrain,Xtest,Ytrain,Ytest,regularization,best_lambda,B_init);
[predicted_label,accuracy,prob_estimates,weights]= classif(Xtrain,Xtest,Ytrain,Ytest,regularization,best_lambda,B_init);

end




function [predicted_label,accuracy,prob_estimates,weights]= classif(Xtrain,Xtest,Ytrain,Ytest,regularization,best_lambda,B_init)
%function [YlatTr,YlatTest,B_new]= classif(Xtrain,Xtest,Ytrain,Ytest,regularization,best_lambda,B_init)
% perform classification

switch regularization       
    case 'L2'
        model = train(Ytrain, sparse(double(Xtrain)), ['-s 7 -q -c ', num2str(best_lambda)]);
    case 'L1'
        model = train(Ytrain, sparse(double(Xtrain)), ['-s 6 -q -c ', num2str(best_lambda)]);
end

% Handle libSVM and liblinear "bug" - the B_new values can be sometimes reversed (see libSVM FAQ)
labels = unique(Ytrain);
if Ytrain(1) == labels(1);
    B_new = -model.w';
elseif Ytrain(1) == labels(2);
    B_new = model.w';
end

% Value predicted
%YlatTr              = Xtrain*B_new;
%YlatTest            = Xtest*B_new;
weights = B_new(1:end-1); % remove the bias to have clean weights

[predicted_label, accuracy, prob_estimates] = predict(Ytest, sparse(double(Xtest)), model, 'b -1');

end



function [best_lambda B_init] = parameterSearch(Xtrain,Ytrain,regularization)
% ptraining = percentage of trial kept for training during the C optimization
% seb.crouzet@gmail.com

B_init      = [];
ptraining = 0.5;
ntraining = round((size(Xtrain,1)*ptraining)/2);
nfold = 8; % if 8 labs are open, there are thus done all at once (8 labs on the cluster)
foldPerf = nan(nfold,1);

% good for LIBLINEAR SVM
interval = [-10 2]; % previously -15 4
grain = [1 0.1];

% grid search to find the best C
for pas = grain
    i=1;
    bestcv = 0;
    for log2c = interval(1):pas:interval(2)
        % repeat nfold times to be sure about the estimation for this C value
        % the nfolds can be parallelized if matlabpool is open, going 8 times faster if 8 labs are available
        parfor f=1:nfold
            train = [];
            labels = unique(Ytrain); % to handle both -1/1 and 0/1, maybe also multiclass
            for l = 1:length(labels)
                c = labels(l);
                j = find(Ytrain==c);
                t = randperm(length(j));
                train = cat(1, train, j(t(1:ntraining)));
            end
            test = setdiff(1:size(Ytrain,1), train)';
            [~,YlatTest,~] = classif(Xtrain(train,:),Xtrain(test,:),Ytrain(train),Ytrain(test),regularization,2^log2c,B_init);
            perf = measure_perf(YlatTest,Ytrain(test));
            foldPerf(f) = perf.accuracy;
        end
        %fprintf('.')
        thisCVperf = mean(foldPerf);
        if (thisCVperf > bestcv),
            bestcv = thisCVperf;
            bestc = 2^log2c;
            bestlog2c = log2c;
        end
        i=i+1;
    end
    %fprintf(1, '\n')
    interval(1) = bestlog2c-pas;
    interval(2) = bestlog2c+pas;
end
%fprintf('\n')
best_lambda = bestc;
end
