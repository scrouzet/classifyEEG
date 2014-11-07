# LIBLINEAR OPTIONS

% model = train(training_label_vector, training_instance_matrix [,'liblinear_options', 'col']);
% 	-s type : set type of solver (default 1) for multi-class classification
% 		 0 -- L2-regularized logistic regression (primal)
% 		 1 -- L2-regularized L2-loss support vector classification (dual)	
% 		 2 -- L2-regularized L2-loss support vector classification (primal)
% 		 3 -- L2-regularized L1-loss support vector classification (dual)
% 		 4 -- support vector classification by Crammer and Singer
% 		 5 -- L1-regularized L2-loss support vector classification
% 		 6 -- L1-regularized logistic regression
% 		 7 -- L2-regularized logistic regression (dual)
% 	  
%     for regression
% 		11 -- L2-regularized L2-loss support vector regression (primal)
% 		12 -- L2-regularized L2-loss support vector regression (dual)
% 		13 -- L2-regularized L1-loss support vector regression (dual)
% 
% 	-c cost : set the parameter C (default 1)


# LIBSVM OPTIONS
	
	"-s svm_type : set type of SVM (default 0)\n"
	"	0 -- C-SVC		(multi-class classification)\n"
	"	1 -- nu-SVC		(multi-class classification)\n"
	"	2 -- one-class SVM\n"
	"	3 -- epsilon-SVR	(regression)\n"
	"	4 -- nu-SVR		(regression)\n"
	
	"-t kernel_type : set type of kernel function (default 2)\n"
	"	0 -- linear: u'*v\n"
	"	1 -- polynomial: (gamma*u'*v + coef0)^degree\n"
	"	2 -- radial basis function: exp(-gamma*|u-v|^2)\n"
	"	3 -- sigmoid: tanh(gamma*u'*v + coef0)\n"
	"	4 -- precomputed kernel (kernel values in training_instance_matrix)\n"
	
	"-d degree : set degree in kernel function (default 3)\n"
	
	"-g gamma : set gamma in kernel function (default 1/num_features)\n"
	
	"-r coef0 : set coef0 in kernel function (default 0)\n"
	
	"-c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)\n"
	
	"-n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)\n"
	
	"-p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)\n"
	
	"-m cachesize : set cache memory size in MB (default 100)\n"
	
	"-e epsilon : set tolerance of termination criterion (default 0.001)\n"
	
	"-h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1)\n"
	
	"-b probability_estimates : whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)\n"
	
	"-wi weight : set the parameter C of class i to weight*C, for C-SVC (default 1)\n"
	
	"-v n : n-fold cross validation mode\n"
	
	"-q : quiet mode (no outputs)\n"
