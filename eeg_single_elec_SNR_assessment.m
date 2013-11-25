function [snr] = eeg_single_elec_SNR_assessment(data, times)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% calculate the variance for each time-point and each electrode
variance = var(data,[],3);

% calculate the average variance of the signal in the prestimulus period
noise = mean(variance(:,times<0),2);

snr = variance ./ repmat(noise,1,size(variance,2));

plot(times, snr');


end

