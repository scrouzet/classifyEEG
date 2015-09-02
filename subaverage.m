function [Xsub, Ysub, subs] = subaverage(Xo,Yo,subs,n,do_boot)
% Subaverage rows in a matrix
% Can be used in classification to increase SNR by reducing the number of
% trials (rows)
%
% do_boot makes multiple averaging by sampling with replacement so that you
% end up with the same number of trials than the original ones. This allow
% to increase the SNR but does not reduce computing time (contrary to
% do_boot==0). See if this is still usefull in practice.
%
% seb.crouzet@gmail.com

if nargin<4, n=3; end
if nargin<5, do_boot=0; end

labels = unique(Yo);
if ~isrow(labels), labels = labels'; end

Xsub = []; Ysub = [];
for lab = labels
    
    X = Xo(Yo==lab,:);
    
    [nRows, nCols] = size(X);
    nRows_final = floor(nRows/n);
    
    if do_boot==0
        Xsub_temp = X(1:(nRows_final),:); % initialize Xsub to be like X but with less lines
        
        if nargin<3,
            % Define the trials to be averaged together if not provided
            subs = repmat(1:nRows_final, 1, n+1)'; % do too much (n+1) and cut after
            subs = shuffle(subs(1:nRows));
        end
        
        for iRow = 1:nRows_final
            Xsub_temp(iRow,:) = mean(X(subs==iRow,:),1);
        end
        % for iCol = 1:nCols
        %     Xsub(:,iCol) = accumarray(subs, X(:,iCol), [], @mean);
        % end
    
    elseif do_boot==1;
        Xsub_temp = X(1:(nRows_final),:); % initialize Xsub to be like X but with less lines
        
        if nargin<3,
            % Define the trials to be averaged together if not provided
            subs = repmat(1:nRows_final, 1, n+1)'; % do too much (n+1) and cut after
            subs = shuffle(subs(1:nRows));
        end
        
        for iRow = 1:nRows_final
            Xsub_temp(iRow,:) = mean(X(subs==iRow,:),1);
        end
        % for iCol = 1:nCols
        %     Xsub(:,iCol) = accumarray(subs, X(:,iCol), [], @mean);
        % end
    end
    
    Xsub = [Xsub ; Xsub_temp];
    Ysub = [Ysub ; repmat(lab, length(Xsub_temp), 1)];
end

end