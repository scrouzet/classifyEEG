function [snr] = sERP_SNR(EEG, time_windows)
% The SNR is deﬁned as the ratio of standard deviations of the post-stimulus ERP
% signal [0:800 ms] and the one of the pre-stimulus [-800:0 ms].

if nargin<3, time_windows = {[-600 0] [0 600]}; end
% calculate the variance for each time-point and each electrode

%[newlat] = eeg_lat2point(EEG.times, -400, EEG.srate, [EEG.times(1) EEG.times(end)]);
[newlat] = eeg_lat2point([-400 0 400], [], EEG.srate, [EEG.times(1) EEG.times(end)]);

eeg_lat2point(cell2mat({EEG.event(1:5).epoch}), cell2mat({EEG.event(1:5).latency}), EEG.srate, [EEG.xmin EEG.xmax])

% Based on EEGLAB classic organization
[nelecs, ntimes, ntrials] = size(EEG.data);

for ch = 1:nelecs
    for tr = 1:ntrials
        SNR(ch,tr) = std( data(ch,time_windows{1}:,tr) );
    end
end
%variance = var(data,[],3);

% calculate the average variance of the signal in the prestimulus period
noise = mean(variance(:,times<0),2);

snr = variance ./ repmat(noise,1,size(variance,2));

plot(times, snr');


% Single-trial-electrode SNR = variance post-stimulus / variance
% pre-stimulus
% pre post = -300 300
% = how much this electrode as a sensory response
var_prestim = mean( variance(:, times>=-300 & times<0) , 2);
var_posstim = mean( variance(:, times>0 & times<=300) , 2);
sensory_response_ratio = var_posstim ./ var_prestim;

topoplot(zscore(sensory_response_ratio), EEG.chanlocs, 'style', 'fill', 'maplimits', 'absmax','conv','on'); % 'both' or 'fill' are nice
% 'maplimits', [-3 3],
% 'colormap', polarmap


end

