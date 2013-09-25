function[res] = mycrossvalidations(Y, res, type)
% Create cross-validations
% make sure that there is an equivalent number of training examples for
% each class. Idem for test examples. This is not impletemented in built-in
% matlab functions.
%
% seb.crouzet@gmail.com | Sep 25 2013

for cv = 1:res.ncv
    switch type
        
        case 'holdout'
            for class = 1:res.n_class
                
                % get n instance, n corresponding to the min category
                instances = randsample(find(Y==class), res.n_min);
                
                % split that into a train and a test set
                sel4train = randsample(instances, floor(res.n_min*res.training_ratio));
                sel4test  = setdiff(instances, sel4train);
                
                res.itrain(sel4train, cv) = true;
                res.itest(sel4test, cv)   = true;
            end
            
        case 'leave1out'
        case 'kfold'
    end
end