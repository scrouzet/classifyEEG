% example_plot
load('example_data.mat');
load('example_results_template.mat');

% -------------------------------------------------------------------------
% plot classification accuracy (neural template) over time
figure;
dec_acc    = mean(res.accuracy,3);
h = imagesc(res.times,res.times, dec_acc, [40 75]); hold on
axis xy square
xlabel('Train time (ms)');
ylabel('Test time (ms)');
print('example_template','-dpng')