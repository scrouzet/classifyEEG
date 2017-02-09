function[res] = mycrossvalidations(Y, res)
% Create cross-validations indices.
% 
% Make sure that there is an equivalent number of training examples for
% each class. Idem for test examples. This is not impletemented (as far as 
% I understood) in built-in MATLAB functions.
%
% http://en.wikipedia.org/wiki/Cross-validation_(statistics)
%
% seb.crouzet@gmail.com

if isrow(Y), Y=Y'; end

res.freq_table = tabulate(Y);
res.n_min      = min(res.freq_table(:,2));

switch res.cv_type
    
    case 'holdout' 
    	% also called: Monte Carlo cross-validation (MCCV) ; Repeated random sub-sampling validation
    	% Xu & Liang (2001) Monte Carlo cross validation. Chemometrics and Intelligent Laboratory Systems.
        % 
        % On each cv, get a random sample for training and the rest for testing
        % - different training set have overlaping members, so the error bar
        % is not well defined statistically
        % - it's not neither boostrap since it draws without replacement
        %
        % Zhang, P. (1993). Model Selection Via Multifold Cross Validation. Ann. Stat.
        % They showed that running N^2 (with N=number of data points) provide an 
        % estimate as good as all combinations possible
        
        if ~isfield(res,'ncv'), error('For houldout cv, the field res.ncv should be specified.'); end
        if ~isfield(res,'training_ratio'), error('For houldout cv, the field res.training_ratio should be specified.'); end

        % Initialize the CV matrices
        res.itrain = false(res.n_instance, res.ncv); % logical array
        res.itest  = false(res.n_instance, res.ncv); % logical array

        for cv = 1:res.ncv
            for class = 1:res.n_class
                
                % get n instance, n corresponding to the min category
                instances = randsample(find(Y==class), res.n_min);
                
                % split that into a train and a test set
                sel4train = randsample(instances, floor(res.n_min*res.training_ratio));
                sel4test  = setdiff(instances, sel4train);
                
                res.itrain(sel4train, cv) = true;
                res.itest(sel4test, cv)   = true;
            end
        end
        
        
    case 'kfold'
    	% k-fold cross-validation
        % Split all the data in n folds. Train on n-1, test on the remainings
        % ncv = number of repeat of the entire kfold procedure (usually
        %               called a Monte-Carlo repetitions of cv analysis)
        %       set ncv to 1 for regular k-fold procedure without repetition
        % training_ratio = nfold, has to be a one decimal number = 0.9 not 9.2
        %                  if 0.9, then 10-fold (train on 90%, test on 10%)
        %                  if 0.8, then 5-fold 
        % standard cv procedure in machine learning
        % error bars computed across cv are well defined statistically
        % Since I push each group to be as equal as possible in number,
        % this is usually called a stratified kfold.
        
        if ~isfield(res,'ncv'), error('For kfold cv, the field res.ncv should be specified (= nfold).'); end
        % I disable this specific warning because this is indeed what we want to do here.
        warning('off','stats:cvpartition:MissingGroupsRemoved')
        nfold = floor(1/(1-res.training_ratio));
        
        % Initialize the CV matrices
        res.itrain = false(res.n_instance, res.ncv*nfold); % logical array
        res.itest  = false(res.n_instance, res.ncv*nfold); % logical array
        
        cv=1;
        for rep = 1:res.ncv
            
            % Equalize the number of instance of each class in Y
            Y_equal = nan(length(Y),1);
            for class = 1:res.n_class
                Y_equal( randsample(find(Y==class), res.n_min) ) = class;
            end
            
            % Now we can use the built-in MATLAB function to do it.
            c = cvpartition(Y_equal,'kfold',nfold);
            for fold = 1:nfold
                res.itrain(training(c,fold), cv) = true;
                res.itest(test(c,fold), cv)      = true;
                cv=cv+1;
            end
        end
        warning('on','stats:cvpartition:MissingGroupsRemoved')
        
    case 'leaveoneout'
        % get one instance (=trial) for test, and train on the rest
        % the rest corresponding to the minimum number among the different labels
        % equalize the number of instances used for training
        
        n_instance = sum(res.freq_table(:,2));
        res.itrain = false(n_instance,n_instance);
        res.itest  = false(n_instance,n_instance);
                
        for cv = 1:n_instance
            % store the one for test
            res.itest(cv, cv) = true;
            
            mycount = tabulate( Y(~res.itest(:, cv)) ); % don't count test
            n_min = min(mycount(:,2));

            % pick up the train set among remainings
            sel4train = [];
            for class = 1:res.n_class
                sel4train = [ sel4train ; randsample(find(Y==class & ~res.itest(:, cv)), n_min) ];
            end
            res.itrain(sel4train, cv) = true;
        end
end