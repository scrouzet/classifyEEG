This is a set of MATLAB functions to perform classification based upon topographic EEG data.

This code is primarily designed for:
- time course analysis of time-locked electroencephalographic (EEG) signal.
- data preprocessed with [EEGLAB](http://sccn.ucsd.edu/eeglab/) (easy to also use with [Fieldtrip](http://fieldtrip.fcdonders.nl/) data).

### Dependencies:
- [LIBLINEAR](http://www.csie.ntu.edu.tw/~cjlin/liblinear/): compiled and added to the MATLAB path
- [EEGLAB](http://sccn.ucsd.edu/eeglab/): in the MATLAB path, but only used for plotting functions

Using it with another classification toolbox than [LIBLINEAR](http://www.csie.ntu.edu.tw/~cjlin/liblinear/) would only require a few modifications in the classification.m function.

Fan, R., Chang, K., & Hsieh, C. (2008). LIBLINEAR: A library for large linear classification. The Journal of Machine Learning Research, 9(2008), 1871–1874
Delorme A & Makeig S (2004) EEGLAB: an open source toolbox for analysis of single-trial EEG dynamics. Journal of Neuroscience Methods 134:9-21

### Installation
1. Download the zip file containing the code.
2. Unzip it and move it to the appropriate location.
3. Add this directory to the MATLAB path.
4. Install the necessary dependencies (-> [LIBLINEAR](http://www.csie.ntu.edu.tw/~cjlin/liblinear/))

# TODO LIST:
- example script to check that sufficient number of training example - decoding accuracy function of nb of training example
- sliding_stats() function to determine 
	- time point when it's significantly above chance level
	- minimal and best decoding latencies
- include the computing of shuffled labels
- function to add selectivity bar on top of a decoding accuracy curve
- decide for the label idx (1 vs 0, 1 vs -1, 1 vs 2). For the moment the code works only for 1vs2
- function to plot ROC from the classif results
- finish the tutorial
- averaging trials (taking groups of 3 trials could allow to get 20% more accuracy \cite{Isik2013})

function slidingClassif_stat() to extract:
- peak latency (=max decoding)
- onset latency (to define)

Temporal cross-decoding = neural template -> train and test on all possible combination of time-points

## Sliding-time-window analysis
A new classifier was trained and tested for each time point. This sliding time window approach was used to study the emerging categorical structure of object
representations.

## sliding vs. global classification
sliding is over time

## Pattern classification analysis
The aim of the study was to examine when and how categorical structure emerges in the brain. To this end, we used naive Bayes implementation of linear discriminant analysis (LDA, Duda, Hart, & Stork, 2001) to do single-trial classification of the exemplar and category of the stimuli that participants were viewing.


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
```matlab
[Xtrain, Xtest] = normalizeTrainTest(Xtrain, Xtest, 'scale'); 
```

## Parameter Selection
For linear classification, the only parameter is C (cost). According to Fan et al. (2008), 

It's still good to always try different C values to be sure that classification performance does not change much.

Important to perform a "number of training example" investigation to be sure that our classification accuracy is meaningful (i.e. that our classifier is properly trained).

A function to perform the cross-validation (random, k-fold, leave-one-out) automatically.
