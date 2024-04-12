%% Script for applying the MD model to one set of simulated JV data
% -------------------------------------------------------------------------
% The JV data used in this script are simulated by SCAPS-1D. You can use
% this script to reproduce the results in Fig. 1 of the paper.
%
% @ Author: Minshen Lin
% @ Institution: Zhejiang University
%
% @ LICENSE
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% -------------------------------------------------------------------------

clear; clc; % Clear workspace

addpath(genpath(pwd)); % Include directories

perov = Device(); % initialize Device object with default constructor

% Load data
irradiance = 50; % specify the dataSet by irradiance level
if irradiance == 1
    dataSet = DataLoader('Figure1/1Sun.iv');
elseif irradiance == 50
    dataSet = DataLoader('Figure1/50Suns.iv');
end

dataJV = DataPreconditioner(dataSet, perov).dataJV; % Data preconditioning

retrievedParams = fittingMD(perov, dataJV); % MD model fitting

calJV = solver(perov, dataJV, retrievedParams); % Numerically solve JV

cost = costFunction(dataJV, calJV); % Evaluate cost function

% Plot
plotJV(dataJV, calJV, retrievedParams);
plotJrecV(dataJV, calJV);
