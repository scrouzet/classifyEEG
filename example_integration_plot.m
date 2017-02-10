% example_plot
%addpath(genpath('~/Dropbox/src/MATLAB/eeglab13_4_4b/'));
load('example_data.mat');
load('example_results_integration.mat');

% -------------------------------------------------------------------------
% plot classification accuracy over time
figure;
dec_acc    = mean(res.accuracy,2);
dec_acc_ci = bootci(200, @mean, squeeze(res.accuracy(:,:))');
dec_acc_ci_chance = bootci(200, @mean, squeeze(res.accuracy_chance(:,:))');

% plot chance level
plot(res.times, repmat(50,1,length(res.times)), 'k--'); hold on

% plot CI of the chance
fill([res.times fliplr(res.times) ], [ dec_acc_ci(1,:) fliplr(dec_acc_ci(2,:)) ], [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.5); hold on

% plot CI of the average across CV
fill([res.times fliplr(res.times) ], [ dec_acc_ci_chance(1,:) fliplr(dec_acc_ci_chance(2,:)) ], [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.5); hold on
% plot average across CV
plot(res.times, dec_acc, 'Color', 'k'); hold on
xlabel('Time (ms)')
ylabel('Decoding accuracy (%)');
title('Decoding time-course');
xlim([res.times(1) res.times(end)]);
ylim([40 90]);
print('example_integration','-dpng')
