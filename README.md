A set of MATLAB functions to perform classification based upon topographic EEG data.

This code is primarily designed for:
- time course analysis of time-locked EEG signal (generally to stimulus onset).  
- data preprocessed with EEGLAB (should be straighforward to use with Fieldtrip data).

Dependencies:
- LIBLINEAR: compiled and added to the MATLAB path
- EEGLAB: in the MATLAB path, but only used for plotting functions

Using it with another classification toolbox than LIBLINEAR would only require a few modifications in the classification.m function.

# TODO LIST:
- []example script to check that sufficient number of training example
	decoding accuracy function of nb of training example
- []finish the tutorial
- []function to determine
	- []minimal decoding latency
	- []best decoding latency
- [] include the computing of shuffled labels
- []function to add selectivity bar on top of a decoding accuracy curve

# Information about example data
One single participant in a go/nogo binary classification task (1 = target; 2 = distractor).

Here, Y is directly loaded from the example_data.mat, one way to get it from a cell array of labels is:

```matlab
mycellarray = {'A' 'A' 'B' 'B'}; 
Y = grp2idx(mycellarray);
Y =
  [1 1 2 2]
```

# BRIEF TUTORIAL

From scikit-learn webpage:
classification: samples belong to two or more classes and we want to learn from already labeled data how to predict the class of unlabeled data. An example of classification problem would be the handwritten digit recognition example, in which the aim is to assign each input vector to one of a finite number of discrete categories. Another way to think of classification is as a discrete (as opposed to continuous) form of supervised learning where one has a limited number of categories and for each of the n samples provided, one is to try to label them with the correct category or class.

regression: if the desired output consists of one or more continuous variables, then the task is called regression. An example of a regression problem would be the prediction of the length of a salmon as a function of its age and weight.



LIBLINEAR's solvers all give similar performances, but their training time may be different. 

For current solvers for L2-regularized problems, a rough guideline is in Table 1. We recommend users:
	1. Try the default dual-based solver first.
	2. If it is slow, check primal-based solvers.

For L1-regularized problems, the choice is limited because currently we only offer primal based solvers. To choose between using L1 and L2 regularization, we recommend trying L2 first unless users need a sparse model. In most cases, L1 regularization does not give higher accuracy
but may be slightly slower in training; see a comparison in Section D of the supplemenary materials of Yuan et al. (2010).

## Normalization
In classification, large data values may cause the following problems:
1. Features in larger numeric ranges may dominate those in smaller ranges.
2. Optimization methods for training may take longer time.

The function normalizeTrainTest() does that. A typical use would be:
[Xtrain, Xtest] = normalizeTrainTest(Xtrain, Xtest, 'scale'); 

## Parameter Selection
For linear classification, the only parameter is C (cost). According to Fan et al. (2008), 

It's still good to always try different C values to be sure that classification performance does not change much.

Important to perform a "number of training example" investigation to be sure that our classification accuracy is meaningful (i.e. that our classifier is properly trained).

A function to perform the cross-validation (random, k-fold, leave-one-out) automatically.
