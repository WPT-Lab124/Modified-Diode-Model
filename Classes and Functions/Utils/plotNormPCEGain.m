function plotNormPCEGain(PCEs)
% -------------------------------------------------------------------------
% Creating a bar graph of normalized PCE gains with the computed PCE values.
%
% Arguments:
%   PCEs: computed PCE values after excluding a specified loss pathway
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

% compute normalized PCE gain
fracGain = (PCEs - PCEs(1, 1));
fracGain = fracGain / fracGain(6, 1);
frac = fracGain(2 : 5, 1);
fracNorm = frac / sum(frac) * 100; 

% bar graph
figure
label = categorical({'Bulk', 'If.', 'Rsh', 'Rs'});
label = reordercats(label, {'Bulk', 'If.', 'Rsh', 'Rs'});
b = bar(label, fracNorm);
% display values at the tips of the bars
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData) + '%';
text(xtips1, ytips1, labels1, 'HorizontalAlignment', ...
    'center', 'VerticalAlignment', 'bottom');
title('Normalized PCE Gain (%)');

end

