function [pks, locs, idx] = findpeaks_EEGclassif(data, mytimes)
% Finds peaks in the time-course of EEG decoding. The function starts by 
% finding local maxima using the findpeaks() built-in MATLAB function. Then
% it removes peaks that have "similar" topography to their neighbors (this last part was finally not added).
%
% April 1st 2016 | seb.crouzet@gmail.com

MinPeakDistance = 30; % in ms

% Calculate sampling rate based on mytimes
%Fs = 1000/mode(diff(mytimes));
%timestep = mode(diff(mytimes));
%MinPeakDistance = floor(MinPeakDistance/timestep);

[pks,locs] = findpeaks(double(data),mytimes,...
    'MinPeakDistance',MinPeakDistance,...
    'MinPeakHeight',0.6,...
    'NPeaks',8,...
    'Annotate','extents');

idx = find(ismember(mytimes,locs));

% Assess difference in the actpat (if too similar, then keep only the earliest)
%mycorr = triu(corr(actpat(:,idx)));

%actpat = actpat(:,idx);

if any(locs<=0)
    pks(locs<=0)  = [];
    locs(locs<=0) = [];
    idx(locs<=0)  = [];
%    actpat = actpat(:,locs>0);
end

% % Plot the peak
% if do_plot
%     figure
%     for sp = 1:size(actpat,2)
%         subplot(1,size(actpat,2),sp);
%         topoplot(actpat(:,sp), mychanlocs, 'style', 'both'); % 'both' or 'fill' are nice
%         title(' / ');
%     end
% end

%     aze
% end

end

