classdef DataPreconditioner
% -------------------------------------------------------------------------
% DataPreconditioner is a class for JV data preconditioning. Both the
% simulated and the experimental data can be preconditioned by this class.
% And the dataJV is the expected output for further computation.
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
    
    %% Properties to be defined
    properties
        % input parameters for single dataset
        isSingleDataSet;
        dataSet;
        device;

        % input parameter for batch dataset
        loadedJV;

        % input parameter for experiment data
        isExperimentData = false;
        inputJV;
    end

    %% Properties whose values depend on other properties (see 'get' methods)
    properties (Dependent)
        dataJV; % preconditioned JV data
    end

    %% Methods
    methods
        %% Constructor
        function obj = DataPreconditioner(varargin)
            if nargin == 1
                if isa(varargin{1}, "string")
                    obj.isExperimentData = true;
                    obj.inputJV = readtable(varargin{1}, 'FileType', 'text', 'VariableNamingRule', 'preserve');
                else
                    obj.isSingleDataSet = false;
                    obj.loadedJV = varargin{1};
                end
            elseif nargin == 2
                obj.isSingleDataSet = true;
                obj.dataSet = varargin{1}; % dataSet
                obj.device = varargin{2}; % device
            end
        end

        %% Property get methods
        function output = get.dataJV(obj)
            % for experiment dataset
            if obj.isExperimentData == true
                dataV = obj.inputJV{:, "V(V)"};
                dataJ = obj.inputJV{:, "J(mA/cm2)"} * 1e-3;
                output = table(dataV, dataJ);
                return
            end
            
            % for simulation dataset
            if obj.isSingleDataSet == false % for batch dataset
                JV = obj.loadedJV;
            elseif obj.isSingleDataSet == true % for single dataset
                JV = [obj.dataSet.dataV, obj.dataSet.dataJ, ...
                      obj.dataSet.dataJbulk, obj.dataSet.dataJif];
            end
            V = JV(:, 1); % [V]
            Jtot = JV(:, 2) * 1e-3; % [A/cm2]
            Jbulk = JV(:, 3) * 1e-3; % [A/cm2]
            Jif = JV(:, 4) * 1e-3; % [A/cm2]
            
            dataV = (V(1) : 0.01 : V(end) + 0.01)';
            dataJ = interp1(V, Jtot, dataV, 'linear', 'extrap');
            dataJbulk = interp1(V, Jbulk, dataV, 'linear', 'extrap');
            dataJif = interp1(V, Jif, dataV, 'linear', 'extrap');

            if obj.isSingleDataSet == true % for single dataset
                dataJsh = (dataV + dataJ .* obj.device.RsSim) ./ obj.device.RshSim;
                output = table(dataV, dataJ, dataJbulk, dataJif, dataJsh);
            else % for batch dataset
                output = table(dataV, dataJ, dataJbulk, dataJif);
            end
        end

    end

end
