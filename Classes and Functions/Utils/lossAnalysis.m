function PCEs = lossAnalysis(dataJV, calJV, device, retrievedParams)
%--------------------------------------------------------------------------
% In this method, the effect of each loss pathway is quantified by the PCE
% gain after excluding it. The PCE excluding one specific loss pathway,
% e.g. Rs, can be calculated by setting the value of Rs to zero in the MD
% model. Likewise, the overall PCE gain can be calculated by setting all the
% parameters of interest in the MD model to zero or infinity (for Rsh),
% denoting the highest PCE that can be possibly achieved. All PCE values
% are evaluated at maximum power points.
%
% @ Arguments:
%     dataJV: a table containing the voltage and current data
%     calJV: a table containing containing the calculated JV curves
%     retrievedParams: an array containing [Rs, Rsh, Ubulk, Uif, nbulk,
%     nif], i.e., the parameters in the MD model. 
% @ Return value:
%     PCEs: PCE values calculated by the MD model for the initial device,
%     device excluding each loss pathway, and device excluding all loss
%     pathways.
% 
% @ Author: Minshen Lin
% @ Institute: Zhejiang University
%
% @ LICENSE
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%--------------------------------------------------------------------------

dataV = dataJV{:, 'dataV'};
interpV = dataV(1) : 0.001 : dataV(end); % interpolate dataV for accurate determination of Pmax

irradiance = 0.1; 
PCEs = zeros(6, 1);

%% Calculating PCE accounting for all losses
rtrvParams = retrievedParams;
calJ = calJV{:, 'calJ'};
interpJ = interp1(dataV, calJ, interpV, 'linear', 'extrap');
PCEs(1) = max(interpV .* interpJ) / irradiance;

%% Calculating PCE excluding bulk SRH recombination
rtrvParams(3) = 0;
collectionNoBulk = solver(device, dataJV, rtrvParams);
calJ = collectionNoBulk{:, 'calJ'};
interpJ = interp1(dataV, calJ, interpV, 'linear', 'extrap');
PCEs(2) = max(interpV .* interpJ) / irradiance;

%% Calculating PCE excluding interface SRH rec.
rtrvParams = retrievedParams;
rtrvParams(4) = 0;
collectionNoIf = solver(device, dataJV, rtrvParams);
calJ = collectionNoIf{:, 'calJ'};
interpJ = interp1(dataV, calJ, interpV, 'linear', 'extrap');
PCEs(3) = max(interpV .* interpJ) / irradiance;

%% Calculating PCE excluding Rsh
rtrvParams = retrievedParams;
rtrvParams(2) = Inf;
collectionNoRsh = solver(device, dataJV, rtrvParams);
calJ = collectionNoRsh{:, 'calJ'};
interpJ = interp1(dataV, calJ, interpV, 'linear', 'extrap');
PCEs(4) = max(interpV .* interpJ) / irradiance;

%% Calculating PCE excluding Rs
rtrvParams = retrievedParams;
rtrvParams(1) = 0;
collectionNoRs = solver(device, dataJV, rtrvParams);
calJ = collectionNoRs{:, 'calJ'};
interpJ = interp1(dataV, calJ, interpV, 'linear', 'extrap');
PCEs(5) = max(interpV .* interpJ) / irradiance;

%% Calculating PCE excluding all
rtrvParams = retrievedParams;
rtrvParams(1) = 0; rtrvParams(2) = Inf; rtrvParams(3) = 0; rtrvParams(4) = 0;
collectionNoAll = solver(device, dataJV, rtrvParams);
calJ = collectionNoAll{:, 'calJ'};
interpJ = interp1(dataV, calJ, interpV, 'linear', 'extrap');
PCEs(6) = max(interpV .* interpJ) / irradiance;

end

