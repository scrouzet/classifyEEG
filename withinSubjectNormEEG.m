function[data_norm, mean_all, mean_ci] = withinSubjectNormEEG(data,ncond)
% Function made to perform this normalization on time series from EEG/iEEG data for example
% 
% Inputs:
% data = (successive measurements x time x individuals)
% ncond = number of conditions to be compared
%
% When there are within-subjects variables (repeated measures), plotting the standard error or regular confidence
% intervals may be misleading for making inferences about differences between conditions.
% The method below is from Morey (2008), which is a correction to Cousineau (2005), which in turn is meant to be a simpler
% method of that in Loftus and Masson (1994). See these papers for a more detailed treatment of the issues involved in
% error bars with within-subjects variables.
%
% Cousineauʹs method is simple:
% normalize the data by subtracting the appropriate participantʹs mean performance from each observation, and
% then add the grand mean score to every observation. Then, use the normalized data to build confidence intervals using
% the standard method described above.
% 
% Here, following Morey 2008, we add a correction factor to that
%
% See the following page for more info:
% http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)/
%
% seb.crouzet@gmail.com

% Get the mean for each individual
mean_ind = mean(data);

% Get the group mean
mean_all = mean(mean_ind,3);

% Substract the individual mean and add the group mean 
data_norm = data - repmat(mean_ind, [size(data,1) 1 1]) + repmat(mean_all, [size(data,1) 1 size(data,3)]);


% manual reshape to compute CIs
datan = data_norm(:,:,1);
for n = 2:size(data_norm,3)
    datan = cat(1,datan, squeeze(data_norm(:,:,n)));
end
mean_ci = bootci(100,@mean,datan);

% Apply correction from Morey 2008 to the ci
correctionFactor = ncond / (ncond-1);
mean_ci = repmat(mean_all,2,1) - (repmat(mean_all,2,1) - mean_ci)*correctionFactor;