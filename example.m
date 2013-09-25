% Example script to perform topography classification on EEGlab data

% Add dependencies to the MATLAB path
addpath(genpath('~/Dropbox/src/MATLAB/liblinear-1.93/'));
addpath(genpath('~/Dropbox/src/MATLAB/eeglab12_0_2_1b'));

% Load the data
load('example_data.mat');

% Get X (features) and Y (labels)
X = EEG.data;
% Y is loaded directly from the mat file

% Parameters --------------------------------------------------------------
res.ncv = 20;              % number of cross-validation to perform
res.training_ratio = 0.9;  % percentage of examples used for training the model
res.regularization = 'L1'; % type of regularization 'L1' or 'L2'
res.optimization = 'off';  % opimization 'on' or 'off'

res = classif_res_init(X,Y,res); % initialize structure for results
res = mycrossvalidations(Y,res,'holdout'); % create cross-validations

for t = 1:res.n_time % loop over time-points

    % Get X for this timepoint and reshape it appropriately
    % We'll get the non-normalized values back at the beginning of each cv
    Xo = squeeze(X(:,t,:))';
        
    for cv = 1:res.ncv % loop over cross-validations
        itrain = res.itrain(:,cv);
        itest  = res.itest(:,cv);

        % X normalization (scale between 0 and 1 seems to be the more efficient)
        [Xn(itrain,:), Xn(itest,:)] = normalizeTrainTest(Xo(itrain,:), Xo(itest,:),'scale');
        
        % Do the classification
        [res.predicted_label(itest,t,cv), res.accuracy(:,t,cv), res.prob_estimates(itest,t,cv), res.weights(:,t,cv), res.best_lambda(t,cv)] = ...
            classification(Xn(itrain,:), Xn(itest,:), Y(itrain), Y(itest), res.regularization, res.optimization);
        
        % Store additional infos
        res.trainingset(:,t,cv) = itrain;
        res.testset(:,t,cv)     = itest;
    end
    fprintf(1,'Processed time point %d / %d: %f%%\n', t, res.n_time, nanmean(res.accuracy(1,t,:)));
end

save('example_results.mat','res');