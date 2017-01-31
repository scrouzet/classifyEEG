% example_plot
addpath(genpath('~/Dropbox/src/MATLAB/eeglab13_4_4b/'));
load('example_data.mat');
load('example_results.mat');

% -------------------------------------------------------------------------
% plot classification accuracy over time
figure;
dec_acc    = mean(res.accuracy,2);
dec_acc_ci = bootci(200, @mean, squeeze(res.accuracy(:,:))');
dec_acc_ci_chance = bootci(200, @mean, squeeze(res.accuracy_chance(:,:))');

% plot chance level
plot(EEG.times, repmat(50,1,length(EEG.times)), 'k--'); hold on

% plot CI of the chance
fill([EEG.times fliplr(EEG.times) ], [ dec_acc_ci(1,:) fliplr(dec_acc_ci(2,:)) ], [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.5); hold on

% plot CI of the average across CV
fill([EEG.times fliplr(EEG.times) ], [ dec_acc_ci_chance(1,:) fliplr(dec_acc_ci_chance(2,:)) ], [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.5); hold on
% plot average across CV
plot(EEG.times, dec_acc, 'Color', 'k'); hold on
xlabel('Time (ms)')
ylabel('Decoding accuracy (%)');
title('Decoding time-course');
xlim([-200 600]);
ylim([40 90]);


% -------------------------------------------------------------------------
% plot cross-validation matrix and Y label vector
figure;
subplot(1,50,1:49);
cvmatrix = zeros(size(res.itrain)); % not used in blue
cvmatrix(res.itrain) = -1;          % train in green
cvmatrix(res.itest)  = 1;           % test in red
imagesc(cvmatrix);
title('CV matrix');
subplot(1,50,50);
imagesc(Y);
axis off

% -------------------------------------------------------------------------
% plot_weight_topo()
figure;
time2plot = find(dec_acc == max(dec_acc), 1); % choose the time-point to plot (here the max decoding accuracy)
%addpath(genpath('~/Dropbox/src/MATLAB/eeglab13_2_2b'));

subplot(1,2,1)
weights = abs(mean(res.weights,3));           % average weights across cross-validations
topoplot(weights(:,time2plot), EEG.chanlocs, 'style', 'both'); % 'both' or 'fill' are nice
title(['Weights at ' num2str(EEG.times(time2plot)) 'ms']);

subplot(1,2,2)
actpats = abs(mean(res.actpat,3));           % average act pats across cross-validations
topoplot(actpats(:,time2plot), EEG.chanlocs, 'style', 'both'); % 'both' or 'fill' are nice
title(['Activation patterns at ' num2str(EEG.times(time2plot)) 'ms']);

% -------------------------------------------------------------------------
% Modified version of timtopo() to explore topographies of activation
% patterns
figure;
dectopo(mean(res.actpat,3),EEG.chanlocs, dec_acc, 'limits', [EEG.times(1) EEG.times(end) 40 90]);
