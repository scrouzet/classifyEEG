function [snr] = eeg_single_elec_SNR_assessment(data, times)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% calculate the variance for each time-point and each electrode
variance = var(data,[],3);

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

