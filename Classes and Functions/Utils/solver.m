function calJV = solver(device, dataJV, retrievedParameters)
% -------------------------------------------------------------------------
% Solving JV curved with the retrieved parameters from MDB model fitting.
%
% Arguments:
%   device: a Device object containing relevant params
%   dataJV: a table containing the voltage and current data
%   retrievedParameters: an array containing [Rs, Rsh, Ubulk, Uif, nbulk,
%     nif], i.e., the parameters in the MDB model.
% Return value:
%   calJV: a table containing containing the calculated JV curves
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

% Params
L = device.L;
ni = device.ni;
Rs = retrievedParameters(1); Rsh = retrievedParameters(2);
ybulk = retrievedParameters(3); Uif = retrievedParameters(4);
nbulk = retrievedParameters(5); nif = retrievedParameters(6);

% J and V data
dataV = dataJV{:, 'dataV'}; % [V]
dataJ = dataJV{:, 'dataJ'}; % [A/cm2]
Jph = dataJ(1);

% Initialize variables
syms J;
f(J) = 0 * J;
calJ = zeros(size(dataV, 1), 1);

% The function of J to be solved is: f(J) = Jph - Jsh - Jbulk - Jif - J = 0
for i = 1 : size(dataV, 1)
    f(J) = Jph - J - (dataV(i) + J * Rs) / Rsh ... Jph - J - Jsh
        - q * ybulk * L * ni * (exp(q * (dataV(i) + J * Rs) / (nbulk * kB * T)) - 1) ... - Jbulk
        - q * Uif * (exp(q * (dataV(i) + J * Rs) / (nif * kB * T)) - 1); % - Jif
    S = vpasolve(f);
    calJ(i) = S;
end

% Calculate rec. and shunt current densities
calJbulk = q * L * ni * ybulk * (exp(q * (dataV + calJ * Rs)/(nbulk * kB * T)) - 1);
calJif = q * Uif * (exp(q * (dataV + calJ * Rs) / (nif * kB * T)) - 1);
calJsh = (calJ * Rs + dataV) / Rsh;

calJV = table(dataV, calJ, calJbulk, calJif, calJsh);

end
