function[res] = classif_res_init(X,Y,res)
% initialize the structure containing the variable output of interest for
% the classification

res.n_class    = length(unique(Y));
res.n_instance = length(Y);
res.n_features = size(X,1);
res.n_time     = size(X,2);
res.freq_table = tabulate(Y);
res.n_min      = min(res.freq_table(:,2));

% initialize the resutl matrices with nans
res.predicted_label = nan(res.n_instance, res.n_time, res.ncv);
res.accuracy        = nan(3, res.n_time, res.ncv);
res.prob_estimates  = nan(res.n_instance, res.n_time, res.ncv);
res.weights         = nan(res.n_features, res.n_time, res.ncv);
res.best_lambda     = nan(res.n_time, res.ncv);
res.itrain          = false(res.n_instance, res.ncv); % logical array
res.itest           = false(res.n_instance, res.ncv); % logical array