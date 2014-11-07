function [model, best_lambda]= mvpa_train(X,Y,toolbox,type,optimization)
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

% Make sure that Y is a column vector
if isrow(Y), Y = Y'; end
if ~ischar(type), type = num2str(type); end

% Optimization
if ~strcmp(optimization,'off'), best_lambda = parameterSearch(X,Y,type);
else                            best_lambda = 1; end

% Classification
model = classif(X, Y, toolbox, type, best_lambda);

end


function model = classif(X, Y, toolbox, type, best_lambda)
% train the model

switch toolbox
    case 'liblinear'
        
        model = train(Y, sparse(double(X)), ['-s ' type ' -q -c ', num2str(best_lambda)]);
        
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
        
    case 'libsvm'
        model = svmtrain(Y, double(X), ['-s ' type ' -t 0 -q -c ', num2str(best_lambda)]); % -b 1 for prob estimates
        % we may need to also do the label re-ordering
end


end


function [best_lambda] = parameterSearch(X,Y,type)
% search for the best C parameter (cost)
% Only work when there is ONE parameter to optimize
% Only work with liblinear so far

nfold = 10; % if 8 labs are open, there are thus done all at once (8 labs on the cluster)
foldPerf = nan(nfold,1);

% good for LIBLINEAR SVM
interval = [-10 2]; % previously -15 4
%grain = [1 0.1];
grain = [1];

% grid search to find the best C
for pas = grain
    i=1;
    bestcv = 0;
    for log2c = interval(1):pas:interval(2)
        % repeat nfold times to be sure about the estimation for this C value
        % the nfolds can be parallelized if matlabpool is open, going 8 times faster if 8 labs are available
        
        % Using the built-in n-fold CV from liblinear
        %thisCVperf = train(Y, sparse(double(X)), ['-s ' type ' -q -c ', num2str(2^log2c), ' -v 10']);
        
        % Homemade nfold CV
        res.ncv     = nfold;    % number of cross-validation to perform
        res.cv_type = 'kfold';  % 'kfold' 'holdout' = 'Repeated random sub-sampling validation'
        res.type    = type;
        res = classif_res_init(X,Y,res); % initialize structure for results
        res = mycrossvalidations(Y,res); % create cross-validations

        for f=1:nfold            
            model = train(Y(res.itrain(:,f)), sparse(double(X(res.itrain(:,f)))), ['-s ' type ' -q -c ', num2str(2^log2c)]);
            foldPerf(f)  = mvpa_test(X(res.itest(:,f)),Y(res.itest(:,f)),model,'accuracy');
        end
        thisCVperf = mean(foldPerf);
%        fprintf('.')

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
 

% %# read some training data
% [labels,data] = libsvmread('./heart_scale');
% 
% %# grid of parameters
% folds = 5;
% [C,gamma] = meshgrid(-5:2:15, -15:2:3);
% 
% %# grid search, and cross-validation
% cv_acc = zeros(numel(C),1);
% for i=1:numel(C)
%     cv_acc(i) = svmtrain(labels, data, ...
%                     sprintf('-c %f -g %f -v %d', 2^C(i), 2^gamma(i), folds));
% end
% 
% %# pair (C,gamma) with best accuracy
% [~,idx] = max(cv_acc);
% 
% %# contour plot of paramter selection
% contour(C, gamma, reshape(cv_acc,size(C))), colorbar
% hold on
% plot(C(idx), gamma(idx), 'rx')
% text(C(idx), gamma(idx), sprintf('Acc = %.2f %%',cv_acc(idx)), ...
%     'HorizontalAlign','left', 'VerticalAlign','top')
% hold off
% xlabel('log_2(C)'), ylabel('log_2(\gamma)'), title('Cross-Validation Accuracy')
% 
% %# now you can train you model using best_C and best_gamma
% best_C = 2^C(idx);
% best_gamma = 2^gamma(idx);
% %# ...


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
%             model = train(Ytrain, sparse(double(Xtrain)), ['-s ' type ' -q -c ', num2str(best_lambda), '-v 10']);
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