function [sigtime, decoding_onset, decoding_peak] = sliding_stats(data1, data2, alpha, nsucc, method)
% check if two decoding curves are significantly different
% can be 2 conditions
% or 1 condition vs. baseline (computed with random labels)
%
% Inputs:
% data ->
% dim1 = repeats (cvs)
% dim2 = time
%
% Outputs:
% p_masked       = vector of significant bins (same size as EEG.times)
% decoding_onset = indice of the first selective bin
% decoding_peak  = indice of the bin with max decoding
%
% requires EEGLAB in the path for the fdr() function
%
% seb.crouzet@gmail.com

switch method

	case 'one>pop'
	case 'group>chance'
        mymean = mean(data1,1);
        myci   = bootci(200,@mean,data1);
        sigtime = myci(1,:) > 50;
        sigtime = cluster_correction_time(sigtime, nsucc);
        
	case 'pop>pop'
    
    case 'mean_over_chance_distrib' % STILL A DRAFT
        
        mymean = mean(data1,1);
        myci   = getCIfromboot(data2,alpha);
        
        sigtime = mymean > myci(2,:);
        
        sigtime = selectivitySuccessiveBins(sigtime, nsucc);

        
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
        sigtime = cluster_correction_time(h,nsucc);
        
%     case 'pop>popfrombaseline' %  METHOD CHANCE BASELINE FROM TRIAL BASELINE
%         % rather than requiring the computation of a chance distribution, this one is here taken 
%         % from the point in the baseline (for example pre-stimulus)
%         baseline = mean(data1(:,1:51));
%         q = quantile(baseline(:), [alpha/2 1-(alpha/2)]);
%         sigtime = mean(data1)>q(2);
%         sigtime = selectivitySuccessiveBins(sigtime, nsucc);

end

% Determine the 'decoding onset' = first time point significantly above chance level
decoding_onset = min(find(sigtime)); 

% Determine the 'decoding peak' = best decoding latencies
[~,decoding_peak] = max(mean(data1)); 

