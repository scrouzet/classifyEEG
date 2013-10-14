function[res] = mycrossvalidations(Y, res)
% Create cross-validations
% make sure that there is an equivalent number of training examples for
% each class. Idem for test examples. This is not impletemented in built-in
% matlab functions.
%
% http://en.wikipedia.org/wiki/Cross-validation_(statistics)
%
% seb.crouzet@gmail.com | Sep 25 2013


switch res.cv_type
    
    case 'holdout' 
    	% also called: Monte Carlo cross-validation (MCCV) ; Repeated random sub-sampling validation
    	% Xu & Liang (2001) Monte Carlo cross validation. Chemometrics and Intelligent Laboratory Systems. 56-1(1–11)
        % 
        % On each cv, get a random sample for training and the rest for testing
        % - different training set have overlaping members, so the error bar
        % is not well defined statistically
        % - it's not neither boostrap since it draws without replacement
        %
        % Zhang, P. (1993). Model Selection Via Muiltfold Cross Validation. Ann. Stat. 21 299–313
        % showed that running N^2 (with N=number of data points) provide an estimate as good as all combinations possible
        
        if ~isfield(res,'ncv'), error('For houldout cv, the field res.ncv should be specified.'); end
        if ~isfield(res,'training_ratio'), error('For houldout cv, the field res.training_ratio should be specified.'); end
        
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
        
        
        
        
        
    case 'kfold' %%%%% NOT FINISHED
    	% k-fold cross-validation
        % Split all the data in n folds. Train on n-1, test on the remainings
        % ncv = nfold
        % standard cv procedure in machine learning
        % error bars computed across cv are well defined statistically
        
        if ~isfield(res,'ncv'), error('For kfold cv, the field res.ncv should be specified (= nfold).'); end
        
        % equalize the number of instance of each class in Y
        Y_equal = nan(length(Y),1); 
        for class = 1:res.n_class
            Y_equal( randsample(find(Y==class), res.n_min) ) = class;
        end
        Y = Y_equal;
        
%         for class = 1:res.n_class
%             instances = reshape(find(Y==class);
%         end
%         
        
        c = cvpartition(Y,'kfold',res.ncv);        
        for cv = 1:res.ncv
            res.itrain(training(c,cv), cv) = true;
            res.itest(test(c,cv), cv)      = true;
        end
        
        
        
        
    case 'leaveoneout'
        % get one instance (=trial) for test, and train on the rest
        % the rest corresponding to the minimum number among the different labels
        % does not give very stable estimate with EEG data...
        
        res.ncv = res.n_min;
        
        for class = 1:res.n_class
            id4test = randsample(res.freq_table(class,2), res.n_min);
            
            for cv = 1:res.ncv
                
                % get all the relevant instances
                instances = find(Y==class);
                
                % store the one for test
                sel4test = instances(id4test(cv));
                
                % leave it out of instances to be picked for training
                instances(id4test(cv)) = [];
                
                % pick up the train test among remainings
                sel4train = randsample(instances, res.n_training_example);
                
                res.itrain(sel4train, cv) = true;
                res.itest(sel4test, cv) = true;
            end
        end
end