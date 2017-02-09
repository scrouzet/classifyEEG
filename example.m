% Example script to perform topography classification on EEGlab data
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
res.ncv            = 5;         % 'holdout' = number of cv / 'kfold' = number of repeat
res.toolbox        = 'liblinear';
res.cv_type        = 'kfold';    % 'holdout' 'kfold' 'leaveoneout'
res.training_ratio = 0.9;        % percentage of examples used for training the model (if kfold, has to be has to be 1 decimal digit) 
res.type           = 7;          % type of model (see Toolbox_options.md for the full list available, depends on res.toolbox)
res.norm_scheme    = 'scale';    % 'scale' or 'zscore'
res.optimization   = 'off';      % opimization 'on' or 'off'
res.conditions     = unique(Y);

res = classif_res_init(X,Y,res);           % initialize structure for results
res = mycrossvalidations(Y,res); % create cross-validations


for t = 1:res.n_time % loop over time-points
            
    % Get X for this timepoint and reshape it appropriately
    % We'll get the non-normalized values back at the beginning of each cv
    Xo = squeeze(X(:,t,:))';
    
    for cv = 1:res.ncv % loop over cross-validations
        itrain = res.itrain(:,cv);
        itest  = res.itest(:,cv);
        
        % TRAIN -----------------------------------------------------------
        
        % normalize the training data (scale between 0 and 1 seems to be the most efficient)
        [Xn(itrain,:), param] = mvpa_normalize(Xo(itrain,:), res.norm_scheme);
        
        % do the training
        model        = mvpa_train(Xn(itrain,:), Y(itrain), res.toolbox, res.type, res.optimization);
        model_chance = mvpa_train(shuffle(Xn(itrain,:)), shuffle(Y(itrain)), res.toolbox, res.type, res.optimization);
        
        % save weights and activation patterns
        res.weights(:,t,cv) = model.w'; % store the weights
        res.actpat(:,t,cv)  = get_activation_patterns(Xn(itrain,:), model.w');
        
        % TEST ------------------------------------------------------------
        Xn(itest,:) = mvpa_normalize(Xo(itest,:), res.norm_scheme, param);

        [res.accuracy(t,cv), res.predicted_label(itest,t,cv), res.prob_estimates(itest,t,cv)] = ...
            mvpa_test(Xn(itest,:), Y(itest), model, res.toolbox, 'accuracy');
       
        % Chance level, we test the same set (true labels) with our model trained on shuffled-label data
        [res.accuracy_chance(t,cv), res.predicted_label_chance(itest,t,cv), res.prob_estimates_chance(itest,t,cv)] = ...
            mvpa_test(Xn(itest,:), Y(itest), model_chance, res.toolbox, 'accuracy');
        
    end
    fprintf(1,'Processed time point %d / %d: %f%%\n', t, res.n_time, nanmean(res.accuracy(t,:)));
end

save('example_results.mat','res','-v7.3');