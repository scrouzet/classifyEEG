function[res] = classif_res_init(X,Y,res)
% initialize the structure containing the variable output of interest for
% the classification

% get the number of classes (to know if binary or multiclass classification)
labels = unique(Y);

res.n_class    = length(labels);
res.n_features = size(X,1);

if numel(size(X)) > 2 % we are in the EEG sliding analysis case
    res.n_time     = size(X,2);
    res.n_instance = size(X,3);
elseif numel(size(X)) == 2
    res.n_instance = size(X,2);
end

res.freq_table = tabulate(Y);
res.n_min      = min(res.freq_table(:,2));

if strcmp(res.cv_type,'leaveoneout')
    res.ncv = res.n_min;
end

% -------------------------------------------------------------------------
% Initialize the result matrices with nans

if numel(size(X)) > 2 % we are in the EEG sliding analysis case
    
    res.predicted_label = nan(res.n_instance, res.n_time, res.ncv);
    res.true_label      = nan(res.n_instance, res.n_time, res.ncv);
    res.accuracy        = nan(res.n_time, res.ncv);
    res.accuracy_rand   = nan(res.n_time, res.ncv);
    
    if res.n_class==2 % binary classification
        res.prob_estimates  = nan(res.n_instance, res.n_time, res.ncv);
        res.weights         = nan(res.n_features, res.n_time, res.ncv);
    elseif res.n_class>2 % multiclass
        res.prob_estimates  = nan(res.n_instance, res.n_class, res.n_time, res.ncv);
        res.weights         = nan(res.n_features, res.n_class, res.n_time, res.ncv);
    end
    
    res.best_lambda     = nan(res.n_time, res.ncv);
    
elseif numel(size(X)) == 2
    
    res.predicted_label = nan(res.n_instance, res.ncv);
    res.true_label      = nan(res.n_instance, res.ncv);
    res.accuracy        = nan(1, res.ncv);
    res.accuracy_rand   = nan(1, res.ncv);
    
    if res.n_class==2 % binary classification
        res.prob_estimates  = nan(res.n_instance, res.ncv);
        res.weights         = nan(res.n_features, res.ncv);
    elseif res.n_class>2 % multiclass
        res.prob_estimates  = nan(res.n_instance, res.n_class, res.ncv);
        res.weights         = nan(res.n_features, res.n_class, res.ncv);
    end
    
    res.best_lambda     = nan(1, res.ncv);
end

% Initialiwze the CV matrices
res.itrain          = false(res.n_instance, res.ncv); % logical array
res.itest           = false(res.n_instance, res.ncv); % logical array