% example_plot
load('example_data.mat');
load('example_results.mat');

% -------------------------------------------------------------------------
% plot classification accuracy over time
figure;
dec_acc    = mean(res.accuracy(1,:,:),3);
dec_acc_ci = bootci(200, @mean, squeeze(res.accuracy(1,:,:))');

% plot CI of the average across CV
fill([EEG.times fliplr(EEG.times) ], [ dec_acc_ci(1,:) fliplr(dec_acc_ci(2,:)) ], [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.5); hold on
% plot average across CV
plot(EEG.times, dec_acc, 'Color', 'k'); hold on
%    p_masked = double(sigtestClassifEEG(res(z).classif.accuracy(:,:,1), res(z).classif.accuracy_rand(:,:,1), alpha, nsucc, 'ttest_randlabel'));
%    plot(times(p_masked),repmat(ysig(1),length(times(p_masked)),1),'s','MarkerEdgeColor','none','MarkerFaceColor',mycolors(1,:), 'MarkerSize',4); hold on
%    p_masked(p_masked==0)=NaN;
%    plot(times,repmat(ysig(1),1,length(times)).*p_masked,'-','Color', mycolors(1,:), 'LineWidth', 3); hold on
xlabel('Time (ms)')
ylabel('Decoding accuracy (%)');


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
