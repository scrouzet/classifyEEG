function[res] = classif_res_init(X,Y,res)
% initialize the structure containing the variable output of interest for
% the classification

% get the number of classes (to know if binary or multiclass classification)
labels = unique(Y);

res.n_class    = length(labels);
res.n_instance = length(Y);
res.n_features = size(X,1);
res.n_time     = size(X,2);
res.freq_table = tabulate(Y);
res.n_min      = min(res.freq_table(:,2));

if strcmp(res.cv_type,'leaveoneout')
    res.ncv = res.n_min;
end

% -------------------------------------------------------------------------
% Initialize the result matrices with nans

%if length(labels)==2 % binary classification
res.predicted_label = nan(res.n_instance, res.n_time, res.ncv);
res.accuracy        = nan(3, res.n_time, res.ncv);
res.prob_estimates  = nan(res.n_instance, res.n_time, res.ncv);
res.weights         = nan(res.n_features, res.n_time, res.ncv);
res.best_lambda     = nan(res.n_time, res.ncv);
res.itrain          = false(res.n_instance, res.ncv); % logical array
res.itest           = false(res.n_instance, res.ncv); % logical array
res.accuracy_rand   = nan(3, res.n_time, res.ncv);

% elseif length(labels) > 2 % multiclass
%     res.predicted_label = nan(res.n_instance, res.n_time, res.ncv);
%     res.prob_estimates  = nan(res.n_instance, res.n_class, res.n_time, res.ncv);
%     res.weights         = nan(res.n_features, res.n_class, res.n_time, res.ncv);
%     res.best_lambda     = nan(res.n_time, res.ncv);
%     res.itrain          = false(res.n_instance, res.ncv); % logical array
%     res.itest           = false(res.n_instance, res.ncv); % logical array
% end
