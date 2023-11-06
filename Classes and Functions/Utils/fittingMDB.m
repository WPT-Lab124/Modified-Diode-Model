function retrievedParams = fittingMDB(device, dataJV)
% -------------------------------------------------------------------------
% Curve fitting with modified detailed balance model
%
% Arguments:
%   device: a Device object containing relevant params
%   dataJV: a table containing the voltage and current data
% Return value:
%   retrievedParams: lumped parameters retrieved by MDB model
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

% Constants
kB = device.kB; % Boltzmann constant [J/K]
T = device.T; % temperature [K]
q = device.q; % elementary charge [C]

% Device parameters
L = device.L; % active layer thickness [cm]
ni = device.ni; % intrinsic carrier concentration [cm^-3]

% Set bounds and initial values for the following parameters:
% [Rs, Rsh, ybulk, Uif, nbulk, nif] --- [Ohm*cm2, Ohm*cm2, /s, /cm2/s, 1, 1]
initialValue = [1,    1e3,  device.yBulk, 1,    2,    1]; % initial guess
lowerBound   = [0,    0,    device.yBulk, 0,    2,    0]; % lower bound for fitting params.
upperBound   = [1e12, 1e12, device.yBulk, 1e12, 2, 1e12]; % upper bound for fitting params.

% J and V Data
dataV = dataJV{:, 'dataV'}; % [V]
dataJ = dataJV{:, 'dataJ'}; % [A/cm2]
Jph = dataJ(1);

% Fitting using L-M algorithm
% Rs = x(1), Rsh = x(2), ybulk = x(3), Uif = x(4), nbulk = x(5), nif = x(6)
fun = @(x) (Jph - dataJ - (dataV + dataJ * x(1)) / x(2) ... % Jph - J - Jsh
    - q * x(3) * L * ni * (exp(q * (dataV + dataJ * x(1)) / (x(5) * kB * T)) - 1) ... % - Jbulk
    - q * x(4) * (exp(q * (dataV + dataJ * x(1)) / (x(6) * kB * T)) - 1)); % - Jif

options = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', ...
    'Display', 'iter', 'FunctionTolerance', 1e-25, ...
    'OptimalityTolerance', 1e-20, 'StepTolerance', 1e-25, ...
    'MaxFunctionEvaluations', 1e5, 'MaxIterations', 1e5);

retrievedParams = lsqnonlin(fun, initialValue, lowerBound, upperBound, options);
end
