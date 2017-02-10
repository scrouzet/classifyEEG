This is a set of MATLAB functions to perform multivariate analysis (only classification for now) based upon topographic EEG data.

The code provided here is primarily designed for:
- time course analysis of time-locked electroencephalographic (EEG) signal.
- data preprocessed with [EEGLAB](http://sccn.ucsd.edu/eeglab/) (easy to also use with [Fieldtrip](http://fieldtrip.fcdonders.nl/) data).

I've used previous and current versions of this code in the following studies:

Crouzet*, S.M., Busch*, N.A. & Ohla, K. (2015). Taste quality decoding parallels taste sensations. Current Biology, 25, 1-7.

Cauchoix*, M., Crouzet*, S.M., Fize, D., & Serre T. (2016). Fast ventral stream neural activity enables rapid visual categorization. NeuroImage, 125, 280-290. 

If you use it, please cite one of these.

### Dependencies:
- [LIBLINEAR](http://www.csie.ntu.edu.tw/~cjlin/liblinear/): compiled and added to the MATLAB path
- [EEGLAB](http://sccn.ucsd.edu/eeglab/): in the MATLAB path, but only used for plotting functions

Using it with another classification toolbox than [LIBLINEAR](http://www.csie.ntu.edu.tw/~cjlin/liblinear/) will only require minor modifications in the mvpa_train_.m and mvpa_test.m functions.

Fan, R., Chang, K., & Hsieh, C. (2008). LIBLINEAR: A library for large linear classification. The Journal of Machine Learning Research, 9(2008), 1871–1874

Delorme A & Makeig S (2004) EEGLAB: an open source toolbox for analysis of single-trial EEG dynamics. Journal of Neuroscience Methods 134:9-21

### Installation
1. Download the zip file containing the code.
2. Unzip it and move it to the appropriate location.
3. Add this directory to the MATLAB path.
4. Install the necessary dependencies (-> [LIBLINEAR](http://www.csie.ntu.edu.tw/~cjlin/liblinear/))

### Example use

I included 3 examples :

- example.m: standard example of time-resolved MVPA on EEG in which an "immediate" classifier is trained at each time-point (i.e. 64 dimensions if 64 channels).
![example decoding plot](/example.png)

- example_integration.m: same as example.m but the classification is integrated over a time-window (i.e. if integrating over 10 previous timepoints, then 64*10=640 dimensions).
![example decoding with integration over time plot](/example_integration_.png)

- example_template.m: training and testing on all possible combinations of timepoints (). See Crouzet et al. 2015 for an example of results.
![example neural template plot](/example_template_.png)

# TODO LIST:
- example script to check that sufficient number of training example - decoding accuracy function of nb of training example
- function to add selectivity bar on top of a decoding accuracy curve
- decide for the label idx (1 vs 0, 1 vs -1, 1 vs 2). For the moment the code works only for 1vs2
- function to plot ROC from the classif results
- write a proper tutorial
- integrate trial averaging (taking groups of 3 trials could allow to get 20% more accuracy \cite{Isik2013})
- Temporal cross-decoding = neural template -> train and test on all possible combination of time-points


### What does multivariate analysis means?
These kind of tools can usually also be refered to as pattern recognition, MVPA (MultiVariate Pattern Analysis) or decoding. More generally, multivariate analyses can usually be divided in two types (definitions from the scikit-learn website):
- classification: samples belong to two or more classes and we want to learn from already labeled data how to predict the class of unlabeled data. An example of classification problem would be the handwritten digit recognition example, in which the aim is to assign each input vector to one of a finite number of discrete categories. Another way to think of classification is as a discrete (as opposed to continuous) form of supervised learning where one has a limited number of categories and for each of the n samples provided, one is to try to label them with the correct category or class.
- regression: if the desired output consists of one or more continuous variables, then the task is called regression. An example of a regression problem would be the prediction of the length of a salmon as a function of its age and weight.

## Sliding-time-window analysis
A new classifier is trained and tested for each time point. This sliding time window approach is used to study the emergence and time-course of categorical information in the signal.


# Information about example data
One single participant in a go/nogo binary classification task (1 = target; 2 = distractor).

Here, Y is directly loaded from the example_data.mat, one way to get it from a cell array of labels is:

```matlab
mycellarray = {'A' 'A' 'B' 'B'}; 
Y = grp2idx(mycellarray);
Y =
  [1 1 2 2]
```

# Improving the SNR (signal-to-noise ratio) of EEG  measurement

EEG measurements are very noisy. Could there be a way to improve that for classification purposes?

The following potential solutions are not implemented yet.

## "Downsampling" the number of trials 
In ERP measurements, the most typical approach is to average several trials together. This process has also been used in decoding of MEG signal (Isik et al., 2013, J. Neurophysiology). The number of epochs that needs to be averaged can vary depending on the experiment and setup. They showed that in their case, 3 trials together was already optimal to improve the decoding performance. 

In  the  time averaging of evoked potentials it is assumed that the measured stochastic signal x(t) is the sum  of  actual  signal  s(t)  and  additive  stochastic  noise  n(t).  If  the  noise  samples  are uncorrelated, the amplitude SNR increases proportionally to square root of the number of averaged epochs. This additive model might only be valid under anaesthesia and for short latency evoked potentials. For longer latencies, the assumption of additive noise has been shown to be insufficient and more complex models are needed (Lopes da Silva 2005).

## "Downsampling" the number of electrodes 
The multichannel aspect of EEG can also be used to increase SNR. It is possible that the desired signal is correlated over several electrodes in a multichannel measurement, whereas the noise is not. In such as case, spatially averaging the signals measured with adjacent electrodes, the multichannel EEG measurement can be downsampled, for example, from a 64 to a 16 electrodes system measurement. In the downsampled multichannel measurement, the SNR is higher than if the measurements had originally been conducted with the 16 electrodes system.



# BRIEF TUTORIAL

## From LIBLINEAR help
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

## Parameter selection/optimization
For linear classification, the only parameter is C (cost). It is good to always try different C values to be sure that classification performance does not change much. From my experience, the performance improvement with EEG or iEEG data is minimal, and the computing time cost is huge...

A good thing to do would be to perform a "number of training example" investigation to be sure that our classification accuracy is meaningful (i.e. that our classifier is properly trained).