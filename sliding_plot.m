function[] = sliding_plot(mytimes, dec_acc, mycolor, dec_acc_ci)
% plot the classification performance over time: 
% - fill for the CI
% - line for the average across cv

if nargin > 3
    % Plot CI
    fill([mytimes fliplr(mytimes) ], [ dec_acc_ci(1,:) fliplr(dec_acc_ci(2,:)) ],...
        mycolor, 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on
end

if ~isempty(dec_acc)
    % Plot average across CV
    plot(mytimes, dec_acc, 'Color', mycolor); hold on
end

%    p_masked = double(sigtestClassifEEG(res(z).classif.accuracy(:,:,1), res(z).classif.accuracy_rand(:,:,1), alpha, nsucc, 'ttest_randlabel'));
%    plot(times(p_masked),repmat(ysig(1),length(times(p_masked)),1),'s','MarkerEdgeColor','none','MarkerFaceColor',mycolors(1,:), 'MarkerSize',4); hold on
%    p_masked(p_masked==0)=NaN;
%    plot(times,repmat(ysig(1),1,length(times)).*p_masked,'-','Color', mycolors(1,:), 'LineWidth', 3); hold on
