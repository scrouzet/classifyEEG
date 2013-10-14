function [probaPos] = sigmoidTransform(Ypredict)
% pass data through a sigmoid function with default parameters
% tranform from -1:1 to 0:1

probaPos       = 1./(1+exp(-Ypredict(:)));