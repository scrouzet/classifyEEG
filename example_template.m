% Example script to perform topography classification on EEGlab data
% Here it is doing what some people call a "neural template analysis"
% which is to train/test on all possible combination of timepoints.
%
% seb.crouzet@gmail.com

% Add dependencies to the MATLAB path
addpath(genpath('~/Dropbox/src/MATLAB/liblinear-1.96/'));

% Load the data
load('example_data.mat');

% Get X (features) and Y (labels)
X = EEG.data;
% Y is loaded directly from the mat file

% Parameters --------------------------------------------------------------
res.ncv            = 20;         % number of cross-validation to perform
res.toolbox        = 'liblinear';
res.cv_type        = 'holdout';
res.training_ratio = 0.9;        % percentage of examples used for training the model
res.type           = 7;          % type of regularization 'L1' or 'L2'
res.optimization   = 'off';      % opimization 'on' or 'off'
res.conditions     = unique(Y);
norm_scheme = 'scale';

res.times = EEG.times;
res = classif_res_init(X,Y,res); % initialize structure for results
res = mycrossvalidations(Y,res); % create cross-validations
res.chanlocs    = EEG.chanlocs;

% Init: adapt the result matrices to the neural template analysis
res.accuracy            = nan(res.n_time, res.n_time, res.ncv, 'single');
res.accuracy_chance     = nan(res.n_time, res.n_time, res.ncv, 'single');
res.weights             = nan(res.n_features, res.n_time, res.ncv, 'single');
res.activation_patterns = nan(res.n_features, res.n_time, res.ncv, 'single');

for cv = 1:res.ncv % loop over cross-validations
    itrain = res.itrain(:,cv);
    itest  = res.itest(:,cv);
    
    % LOOP OVER TRAINING TIME
    for train_t = 1:res.n_time % loop over time-points (for training)
        tic
        
        % Reshape
        Xo = squeeze(X(:,train_t,:))';

        % Normalize
        [Xntrain, param] = mvpa_normalize(Xo(itrain,:), norm_scheme);

        % TRAIN
        model        = mvpa_train(Xntrain, Y(itrain), res.toolbox, res.type, res.optimization);
        model_chance = mvpa_train(shuffle(Xntrain), shuffle(Y(itrain)), res.toolbox, res.type, res.optimization);
        
        % save weights and activation patterns based on this training
        res.weights(:,train_t,cv)             = model.w';
        res.activation_patterns(:,train_t,cv) = get_activation_patterns(Xntrain, res.weights(:,train_t,cv));  % store the activation patterns
        
        % LOOP OVER TESTING TIME
        for test_t = 1:res.n_time % loop over time-points (for testing)
            
            % Normalize testing set
            Xo = squeeze(X(:,test_t,:))';
            Xn(itest,:) = mvpa_normalize(Xo(itest,:), norm_scheme, param);
            
            % TEST
            res.accuracy(test_t,train_t,cv)        = mvpa_test(Xn(itest,:), Y(itest), model, res.toolbox, 'accuracy');
            res.accuracy_chance(test_t,train_t,cv) = mvpa_test(shuffle(Xn(itest,:)), shuffle(Y(itest)), model_chance, res.toolbox, 'accuracy');
        end
        fprintf(1,'CV %d - Processed training time point %d / %d in %.3f s\n', cv, train_t, res.n_time, toc);
    end
end
res = rmfield(res,{'predicted_label' 'true_label' 'best_lambda' 'accuracy_rand' 'prob_estimates'});
save('example_results_template.mat','res', '-v7.3');
