function cost = costFunction(dataJV, calJV)
% -------------------------------------------------------------------------
% Evaluating the cost function.
%
% Arguments:
%   dataJV: a table containing the voltage and current data
%   calJV: a table containing containing the calculated JV curves
% Return Value:
%   cost: the computed cost function
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

Jph = dataJV{:, 'dataJ'}(1, 1);
dataJbulk = dataJV{:, 'dataJbulk'};
dataJif = dataJV{:, 'dataJif'};
dataJ = dataJV{:, 'dataJ'};

calJ = calJV{:, 'calJ'};
calJbulk = calJV{:, 'calJbulk'};
calJif = calJV{:, 'calJif'};
dataSize = size(dataJbulk, 1);

cost = 1 / Jph * (sum(abs(dataJbulk - calJbulk)) / dataSize ...
    + sum(abs(dataJif - calJif)) / dataSize ...
    + sum(abs(dataJ - calJ)) / dataSize);

end
