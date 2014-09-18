% Example script to perform topography classification on EEGlab data
%
% seb.crouzet@gmail.com

% Add dependencies to the MATLAB path
addpath(genpath('~/Dropbox/src/MATLAB/liblinear-1.93/'));

% Load the data
load('example_data.mat');

% Get X (features) and Y (labels)
X = EEG.data;
% Y is loaded directly from the mat file

% Parameters --------------------------------------------------------------
res.ncv            = 20;         % number of cross-validation to perform
res.cv_type        = 'holdout';
res.training_ratio = 0.9;        % percentage of examples used for training the model
res.type           = 7;          % type of regularization 'L1' or 'L2'
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
        
        % X normalization (scale between 0 and 1 seems to be the more efficient)
        [Xn(itrain,:), Xn(itest,:)] = normalizeTrainTest(Xo(itrain,:), Xo(itest,:),'scale');
        
        % TRAIN
        model        = mvpa_train(Xn(itrain,:), Y(itrain), res.type, res.optimization);
        model_chance = mvpa_train(shuffle(Xn(itrain,:)), shuffle(Y(itrain)), res.type, res.optimization);
        
        % TEST
        [res.accuracy(t,cv), res.predicted_label(itest,t,cv), res.prob_estimates(itest,t,cv)] = ...
            mvpa_test(Xn(itest,:), Y(itest), model, 'accuracy');
        
        % save results
        res.weights(:,t,cv)      = model.w'; % store the weights
        res.true_label(itest,t,cv) = Y(itest); % store the true labels
        res.true_label_chance(itest,t,cv) = shuffle(Y(itest)); % store the "true" labels for the ones selected for chance
        
        % TEST (chance level estimated from shuffle labels)
        [res.accuracy_chance(t,cv), res.predicted_label_chance(itest,t,cv), res.prob_estimates_chance(itest,:,t,cv)] = ...
            mvpa_test(shuffle(Xn(itest,:)), res.true_label_chance(itest,t,cv), model_chance, 'accuracy');
        
    end
    fprintf(1,'Processed time point %d / %d: %f%%\n', t, res.n_time, nanmean(res.accuracy(t,:)));
end

save('example_results.mat','res');