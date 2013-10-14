% example_plot
load('example_data.mat');
load('example_results.mat');

% -------------------------------------------------------------------------
% plot classification accuracy over time
figure;
dec_acc    = mean(res.accuracy(1,:,:),3);
dec_acc_ci = bootci(200, @mean, squeeze(res.accuracy(1,:,:))');

% plot chance level
plot(EEG.times, repmat(50,1,length(EEG.times)), 'k--'); hold on
% plot CI of the average across CV
fill([EEG.times fliplr(EEG.times) ], [ dec_acc_ci(1,:) fliplr(dec_acc_ci(2,:)) ], [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.5); hold on
% plot average across CV
plot(EEG.times, dec_acc, 'Color', 'k'); hold on
xlabel('Time (ms)')
ylabel('Decoding accuracy (%)');
xlim([-100 700]);
ylim([40 100]);


% -------------------------------------------------------------------------
% plot cross-validation matrix
figure;
cvmatrix = zeros(size(res.itrain)); % not used in white
cvmatrix(res.itrain) = -1;          % train in blue
cvmatrix(res.itest)  = 1;           % test in red
imagesc(cvmatrix); polarmap;


% -------------------------------------------------------------------------
% plot_weight_topo()
figure;
addpath(genpath('~/Dropbox/src/MATLAB/eeglab12_0_2_1b'));
weights = abs(mean(res.weights,3));           % average weights across cross-validations
time2plot = find(dec_acc == max(dec_acc), 1); % choose the time-point to plot (here the max decoding accuracy)
topoplot(weights(:,time2plot), EEG.chanlocs, 'style', 'both', 'colormap', polarmap); % 'both' or 'fill' are nice
