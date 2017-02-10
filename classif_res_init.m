function[res] = classif_res_init(X,Y,res)
% initialize the structure containing the variable output of interest for
% the classification

% get the number of classes (to know if binary or multiclass classification)
labels = unique(Y);

res.n_class    = length(labels);


if numel(size(X)) > 2 % we are in the EEG sliding analysis case
    if isfield(res,'integrat_win')
        if res.integrat_win>1
            res.intwin = round(res.integrat_win/(res.times(2) - res.times(1)));
            res.n_time = size(X,2)-(res.intwin-1);
            res.times  = res.times(res.intwin:end);
            res.n_features = size(X,1)*res.intwin;
        else
            res.n_time = size(X,2);
            res.n_features = size(X,1);
        end
    else
        res.n_time     = size(X,2);
        res.n_features = size(X,1);
    end
    res.n_instance = size(X,3);
elseif numel(size(X)) == 2
    res.n_instance = size(X,2);
end

if strcmp(res.cv_type,'leaveoneout')
    res.ncv = res.n_instance;
end

% -------------------------------------------------------------------------
% Initialize the result matrices with nans

if numel(size(X)) > 2 % we are in the EEG sliding analysis case
    
    res.predicted_label = nan(res.n_instance, res.n_time, res.ncv, 'single');
    res.true_label      = nan(res.n_instance, res.n_time, res.ncv, 'single');
    res.accuracy        = nan(res.n_time, res.ncv, 'single');
    
    res.accuracy_chance        = nan(res.n_time, res.ncv, 'single');
    res.predicted_label_chance = nan(res.n_instance, res.n_time, res.ncv, 'single');
    res.true_label_chance      = nan(res.n_instance, res.n_time, res.ncv, 'single');
    
    if res.n_class==2 % binary classification
        res.prob_estimates = nan(res.n_instance, res.n_time, res.ncv, 'single');
        res.weights        = nan(res.n_features, res.n_time, res.ncv, 'single');
        res.actpat          = nan(res.n_features, res.n_time, res.ncv, 'single');
        res.prob_estimates_chance = nan(res.n_instance, res.n_time, res.ncv, 'single');
    elseif res.n_class>2 % multiclass
        res.prob_estimates = nan(res.n_instance, res.n_class, res.n_time, res.ncv, 'single');
        res.weights        = nan(res.n_features, res.n_class, res.n_time, res.ncv, 'single');
        res.actpat         = nan(res.n_features, res.n_class, res.n_time, res.ncv, 'single');
        res.prob_estimates_chance = nan(res.n_instance, res.n_class, res.n_time, res.ncv, 'single');
    end
    res.best_lambda = nan(res.n_time, res.ncv, 'single');
    
elseif numel(size(X)) == 2
    
    res.predicted_label = nan(res.n_instance, res.ncv, 'single');
    res.true_label      = nan(res.n_instance, res.ncv, 'single');
    res.accuracy        = nan(1, res.ncv, 'single');
    
    res.accuracy_chance   = nan(1, res.ncv, 'single');
    res.true_label_chance = nan(res.n_instance, res.ncv, 'single');
    res.predicted_label_chance = nan(res.n_instance, res.ncv, 'single');
    
    if res.n_class==2 % binary classification
        res.prob_estimates = nan(res.n_instance, res.ncv, 'single');
        res.weights        = nan(res.n_features, res.ncv, 'single');
        res.actpat         = nan(res.n_features, res.ncv, 'single');    
        res.prob_estimates_chance  = nan(res.n_instance, res.ncv, 'single');
    elseif res.n_class>2 % multiclass
        res.prob_estimates = nan(res.n_instance, res.n_class, res.ncv, 'single');
        res.weights        = nan(res.n_features, res.n_class, res.ncv, 'single');
        res.actpat         = nan(res.n_features, res.n_class, res.ncv, 'single');    
        res.prob_estimates_chance  = nan(res.n_instance, res.n_class, res.ncv, 'single');
    end
    res.best_lambda = nan(1, res.ncv, 'single');
end