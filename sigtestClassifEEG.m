function [p_masked] = sigtestClassifEEG(data1, data2, alpha, nsucc, method)
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

	case 'one>pop'
	case 'pop>one'
	case 'pop>pop'
    
    case 'mean_over_chance_distrib' % STILL A DRAFT
        
        mymean = mean(data1,1);
        myci   = getCIfromboot(data2,alpha);
        
        sig = mymean > myci(2,:);
        
        p_masked = selectivitySuccessiveBins(p_masked, nsucc);

        
    case 'ttest_randlabel'
        
        % t-test
        [h, pvals] = ttest(data1, data2, alpha, 'right', 1); % paired t-test
        %[h, pvals] = ttest2(data1, data2, 'Alpha', alpha, 'Tail',
        %'right'); % ttest2 for unpaired ttest
        
        %data1ci = bootci(200,@mean,data1);
        %data2ci = bootci(200,@mean,data2);
        %mytest = 1 - ((data2ci(1,:) < data1ci(2,:)) & (data1ci(1,:) < data2ci(2,:))); % test for overlap
        
        % FDR
        %[p_fdr, p_masked] = fdr(pvals, alpha);
        
        % check for nsucc in a row
        p_masked = cluster_correction_time(h,nsucc);
        
        
    case 'pop>popfrombaseline' %  METHOD CHANCE BASELINE FROM TRIAL BASELINE
        % rather than requiring the computation of a chance distribution, this one is here taken 
        % from the point in the baseline (for example pre-stimulus)
        baseline = mean(data1(:,1:51));
        q = quantile(baseline(:), [alpha/2 1-(alpha/2)]);
        p_masked = mean(data1)>q(2);
        p_masked = selectivitySuccessiveBins(p_masked, nsucc);

end