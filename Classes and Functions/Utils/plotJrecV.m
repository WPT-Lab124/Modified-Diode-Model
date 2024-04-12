function plotJrecV(dataJV, calJV)
% -------------------------------------------------------------------------
% Plotting Jrec-V curves with the retrieved parameters from MD model fitting.
%
% Arguments:
%   dataJV --- a table containing V, J, Jbulk, Jf, and Jsh
%   calJV  --- calculated JV curves
%   retrievedParameters --- [Rs, Rsh, ybulk, Uif, nbulk, nif, Jph]
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
dataJbulk = dataJV{:, 'dataJbulk'} * 1e3; % [mA/cm2]
dataJif = dataJV{:, 'dataJif'} * 1e3; % [mA/cm2]
dataJsh = dataJV{:, 'dataJsh'} * 1e3; % [mA/cm2]
calJbulk = calJV{:, 'calJbulk'} * 1e3; % [mA/cm2]
calJif = calJV{:, 'calJif'} * 1e3; % [mA/cm2]
calJsh = calJV{:, 'calJsh'} * 1e3; % [mA/cm2]

figure
warning('off', 'MATLAB:Axes:NegativeDataInLogAxis')
plot(dataV, dataJbulk, 'r-');
hold on
plot(dataV, calJbulk, 'r--');
plot(dataV, dataJif, 'k-');
plot(dataV, calJif, 'k--');
plot(dataV, dataJsh, 'b-');
plot(dataV, calJsh, 'b--');
title('Bulk and Interface Recombination');
xlabel('Voltage (V)');
ylabel('Current Density (mA/cm²)');
legend({'J_{bulk}', 'J_{bulk}^{cal}', 'J_{if}', 'J_{if}^{cal}', 'J_{sh}', 'J_{sh}^{cal}'}, 'Location', 'best');
set(gca, 'YScale', 'log')
hold off

end
