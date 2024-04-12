function plotJV(dataJV, calJV, retrievedParameters)
% -------------------------------------------------------------------------
% Plotting JV curves with the retrieved parameters from MD model fitting.
%
% Arguments:
%   dataJV: a table containing the voltage and current data
%   calJV: a table containing containing the calculated JV curves
%   retrievedParameters: an array containing [Rs, Rsh, Ubulk, Uif, nbulk,
%     nif], i.e., the parameters in the MD model.
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

% Read data and convert unit from [A/cm2] to [mA/cm2]
dataV = dataJV{:, 'dataV'}; % [V]
dataJ = dataJV{:, 'dataJ'} * 1e3; % [mA/cm2]
calJV = calJV{:, 'calJ'} * 1e3; % [mA/cm2]

% plot JV curve
figure
plot(dataV, dataJ, 'r--');
hold on
plot(dataV, calJV, 'k-');
xlim([dataV(1), dataV(end)]);
xlabel('Voltage (V)');
ylabel('Current Density (mA/cm²)');
% ylim([dataJ(end), dataJ(1) + 5]);
legend({'Drift-Diffusion', 'Equivalent Circuit'},'Location','best');
str = {sprintf('Rs is %e',retrievedParameters(1)), ...
       sprintf('Rsh is %e',retrievedParameters(2)), ...
       sprintf('ybulk is %e',retrievedParameters(3)), ...
       sprintf('Uif is %e',retrievedParameters(4)), ...
       sprintf('nbulk is %e',retrievedParameters(5)), ...
       sprintf('nif is %e',retrievedParameters(6))};
       annotation('textbox', [0.17 0.1 0.4 0.5], 'String', str, 'FitBoxToText', ...
       'on', 'Color', 'red', 'FontSize', 14);
hold off

end
