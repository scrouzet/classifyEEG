function [p_masked, p_fdr] = sigtestClassifEEG(data1, data2, alpha, nsucc, method)
% check if two decoding curves are significantly different
% can be 2 conditions
% or 1 condition vs. baseline (computed with random labels)
%
% data ->
% dim1 = repeats (cvs)
% dim2 = time
%
% requires EEGLAB in the path for the fdr() function
%
% seb.crouzet@gmail.com

switch method
    
    case 'ttest_randlabel'
        % t-test
        [~, pvals] = ttest(data1, data2, alpha, 'both', 1);
        
        %data1ci = bootci(200,@mean,data1);
        %data2ci = bootci(200,@mean,data2);
        %mytest = 1 - ((data2ci(1,:) < data1ci(2,:)) & (data1ci(1,:) < data2ci(2,:))); % test for overlap
        
        % FDR
        [p_fdr, p_masked] = fdr(pvals, alpha);
        
        % check for nsucc in a row: 10 at 512 Hz means an effect should last at least 20 ms
        p_masked = selectivitySuccessiveBins(p_masked, nsucc);
        
    case '95baseline'
        %  METHOD CHANCE BASELINE FROM TRIAL BASELINE
        baseline = mean(data1(:,1:51));
        q = quantile(baseline(:), [alpha/2 1-(alpha/2)]);
        p_masked = mean(data1)>q(2);
        p_masked = selectivitySuccessiveBins(p_masked, nsucc);

end