function [model, best_lambda]= mvpa_train_subaverage(X,Y,toolbox,type,optimization,n)
% Add the subaverage methode (miniERPs of n trials to increase SNR and reduce computational cost)
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
best_lambda = 1;

% Subaverage


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