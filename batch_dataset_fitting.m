%% Script for applying the MD model to a batch of simulated JV data
% -------------------------------------------------------------------------
% The JV data used in this script are simulated by SCAPS-1D. You can use
% this script to reproduce the results in Fig. 4 of the paper.
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

%% Clear workspace
clear; clc;

%% Include directories
addpath(genpath(pwd));

%% Initialize the Device object for modeling
% You can initialize the Device object with the following parameters:
% [L, Nc, Nv, Eg, tbulk, RsSim, RshSim], or use the default parameter values.
deviceParams = [760e-7, 3.1e18, 3.1e18, 1.6, 500e-9, 1, 1e7];
perov = Device(deviceParams);

%% Initialize data set
irradiance = 50; % specify the dataSet by irradiance level
if irradiance == 1
    dataSet = DataLoader('Figure4/Rec1Sun.iv');
elseif irradiance == 50
    dataSet = DataLoader('Figure4/Rec50Suns.iv');
end

%% Parameter preconditioning
logScale = [10^0.2; 10^0.4; 10^0.6; 10^0.8; 10^1];

ifDefectDensity = cat(1, 1e10, 1e10 * logScale, 1e11 * logScale, 1e12 * logScale); % [cm^-3]
bulkDefectDensity = cat(1, 1e13 * logScale(2 : end), 1e14 * logScale, 1e15 * logScale, 1e16 * logScale(1 : 2)); % [cm^-3]
ifDefectDensity = round(ifDefectDensity, 4, 'significant');
bulkDefectDensity = round(bulkDefectDensity, 4, 'significant');

tBulk = 1e17 ./ bulkDefectDensity; % [ns]
Sif = ifDefectDensity / 1e8; % [cm/s]

%% Evaluate the performance via cost function over the entire data set
yBulk = 1 / 2 / 1e8 * dataSet.bulkDefectDensity; % [s^-1]
cost = zeros(dataSet.numOfDataSets, 1);

startIndex = dataSet.startIndex;
endIndex = dataSet.endIndex;
dataV = dataSet.dataV;
dataJ = dataSet.dataJ;
dataJbulk = dataSet.dataJbulk;
dataJif = dataSet.dataJif;

for i = 1 : dataSet.numOfDataSets
    % Extracting JV data from dataSet
    dataRange = startIndex(i) : endIndex(i);
    loadedJV = [dataV(dataRange), dataJ(dataRange), dataJbulk(dataRange), dataJif(dataRange)];
    dataJV = DataPreconditioner(loadedJV).dataJV; % [V] and [A/cm2]
    
    % MD model fitting for the following parameters:
    % [Rs, Rsh, ybulk, Uif, nbulk, nif] --- [Ohm*cm2, Ohm*cm2, /s, /cm2/s, 1, 1]
    perov.tBulk = 1 / 2 / yBulk(i);
    retrievedParams = fittingMD(perov, dataJV);
    
    % Numerically solve JV
    calJV = solver(perov, dataJV, retrievedParams);
    
    % Evaluate cost function
    cost(i, 1) = costFunction(dataJV, calJV);
end

%% Evaluate MD performance over the entire data set
bulkDefectDensitySim = dataSet.bulkDefectDensity;
ifDefectDensitySim = dataSet.ifDefectDensity;

costMatrix = zeros(size(ifDefectDensity, 1), size(bulkDefectDensity, 1), size(irradiance, 1));

for i = 1 : dataSet.numOfDataSets
    bulkIndex = find(bulkDefectDensity == bulkDefectDensitySim(i, 1));
    ifIndex = find(ifDefectDensity == ifDefectDensitySim(i, 1));
    costMatrix(ifIndex, bulkIndex) = cost(i, 1);
end

%% Draw contour plot of cost function
figure;
contourf(tBulk, Sif, costMatrix(:, :, 1), 100, 'LineColor', 'none');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
colorbar;
xlabel('Bulk SRH Recombination Lifetime (ns)');
ylabel('Interface SRH Recombination Velocity (cm/s)');
if irradiance == 1
    clim([0.15 0.4]);
    title('Cost Function @ 1 Sun Irradiance');
elseif irradiance == 50
    clim([0.2 0.4]);
    title('Cost Function @ 50 Suns Irradiance');
end
