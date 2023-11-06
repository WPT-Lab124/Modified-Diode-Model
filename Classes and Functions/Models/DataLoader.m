classdef DataLoader
% -------------------------------------------------------------------------
% DataLoader is a class for parsing and storing the simulated JV data sets.
% The JV data exported from SCAPS-1D follow a specific format, which is
% utilized by the DataLoader for parsing.
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
    
%% Constant Properties
    properties (Constant)
        % signature strings for reading parameters in the simulation output
        strNum = 'Batch simulation #	1	step	1	of	';
        strIf = 'PTAA / Perov (I1)>>Defect 1>>total density [1/cm²]:	 ';
        strBulk = 'Perov (L2)>>defect 1>>total defect density [1/cm³]:	 ';
        strIrr = 'illumination>>ND filter transmission [-]:	 ';
        strVoc = 'Voc =	    ';
        strPCE = 'eta =	   ';
        strRs = 'Rs [Ohm.cm2]:	 ';
        strRsh = 'Rsh [Ohm.cm2]:	 ';
        
        % names for stored parameters in the simParams table
        ifString = "Interface Defect Density (/cm²)";
        bulkString = "Bulk Defect Density (/cm³)";
        irrString = "Irradiance (Suns)";
        VocString = "Voc (V)";
        PCEString = "PCE (%)";
        RsString = "Rs (Ohm*cm²)";
        RshString = "Rsh (Ohm*cm²)"; 
    end

%% Properties to be defined   
    properties
        fileName;
    end

%%  Properties whose values depend on other properties (see 'get' methods).
    properties (Dependent)
        recString;
        resString;
        
        dataJV;
        dataV;
        dataJ;
        dataJbulk;
        dataJif;
        
        numOfDataSets; % number of sets of JV data
        onlyOneSetOfData; % for post-processing if only one set of data is read
        
        dataIndex; % stores the indices of JV data (column 1 for start, column 2 for end)
        startIndex;
        endIndex;
        dataLength;
        
        % simParams; % stores the parameters used in drift diffusion simulations as table
        ifDefectDensity;
        bulkDefectDensity;
        irradiance;
        Voc;
        PCE;
        Rs;
        Rsh;
    end
    
    %% Non-static Methods
    methods
        %% Constructor
        function obj = DataLoader(varargin)
            % DataSet constructor method - runs numerous checks that
            % the input properties are consistent with the model
            if nargin == 1
                obj.fileName = varargin{1, 1};
            else
                error("Error. Use only 1 argument for the file name.");
            end                
        end
        
        %% Property Get Methods
        % Get method for recString
        function output = get.recString(obj)
            output = [obj.ifString, obj.bulkString, obj.irrString, obj.VocString, obj.PCEString];
        end
        
        % Get method for resString
        function output = get.resString(obj)
            output = [obj.RsString, obj.RshString, obj.irrString, obj.VocString, obj.PCEString];
        end
        
        % Get method for dataJV
        function output = get.dataJV(obj)
            output = readtable(obj.fileName, 'FileType', 'text', 'VariableNamingRule', 'preserve');
            if obj.onlyOneSetOfData
                numOfUselessLines = 7;
                output = output(1 : end - numOfUselessLines, :);
            end
        end
        
        % Get method for dataV
        function output = get.dataV(obj)
            output = obj.dataJV{:, 'v(V)'}; % [V]
        end
        
        % Get method for dataV
        function output = get.dataJ(obj)
            output = obj.dataJV{:, 'jtot(mA/cm2)'}; % [V]
        end
        
        % Get method for dataV
        function output = get.dataJbulk(obj)
            output = obj.dataJV{:, 'jbulk(mA/cm2)'}; % [V]
        end
        
        % Get method for dataV
        function output = get.dataJif(obj)
            output = obj.dataJV{:, 'jifr(mA/cm2)'}; % [V]
        end
                
        % Get method for numOfDataSets
        function output = get.numOfDataSets(obj)
            fileID = fopen(obj.fileName);
            str = obj.strNum;
            while ~feof(fileID)
                curStr = fgetl(fileID);
                if strncmp(curStr, str, length(str))
                    output = str2double(curStr(length(str) : end));
                    break;
                end
            end
            fclose(fileID);
        end
        
        % Get method for dataIndex
        function output = get.dataIndex(obj)
            output = zeros(obj.numOfDataSets, 2);
            ptr = 1;
            V = obj.dataV;
            for i = 1 : size(V, 1) % utilize the fact that in V, data sets are seperated by rows of NaN
                if ~isnan(V(i, 1)) && output(ptr, 1) == 0
                    output(ptr, 1) = i;
                    isFirstNaN = true;
                end
                if isnan(V(i, 1)) && isFirstNaN == true
                    output(ptr, 2) = i - 1;
                    ptr = ptr + 1;
                    isFirstNaN = false; % ignoring other but first NaNs
                end
            end
        end
        
        % Get method for startIndex
        function output = get.startIndex(obj)
            output = obj.dataIndex(:, 1);
        end
        
        % Get method for endIndex
        function output = get.endIndex(obj)
            output = obj.dataIndex(:, 2);
        end
        
        % Get method for dataLength
        function output = get.dataLength(obj)
            output = obj.endIndex - obj.startIndex;
        end
                
        % Get method for ifDefectDensity
        function output = get.ifDefectDensity(obj)
            fileID = fopen(obj.fileName);
            output = zeros(obj.numOfDataSets, 1);

            ptr = 1;
            
            while ~feof(fileID)
                str = fgetl(fileID);
                if strncmp(str, obj.strIf, length(obj.strIf))
                    output(ptr, 1) = str2double(str(length(obj.strIf) + 1 : end));
                    ptr = ptr + 1;
                end
            end
            
            fclose(fileID);
        end
        
        % Get method for bulkDefectDensity
        function output = get.bulkDefectDensity(obj)
            fileID = fopen(obj.fileName);
            output = zeros(obj.numOfDataSets, 1);

            ptr = 1;
            
            while ~feof(fileID)
                str = fgetl(fileID);
                if strncmp(str, obj.strBulk, length(obj.strBulk))
                    output(ptr, 1) = str2double(str(length(obj.strBulk) + 1 : end));
                    ptr = ptr + 1;
                end
            end
            
            fclose(fileID);
        end
        
        % Get method for irradiance
        function output = get.irradiance(obj)
            fileID = fopen(obj.fileName);
            output = zeros(obj.numOfDataSets, 1);

            ptr = 1;
            
            while ~feof(fileID)
                str = fgetl(fileID);
                if strncmp(str, obj.strIrr, length(obj.strIrr))
                    output(ptr, 1) = str2double(str(length(obj.strIrr) + 1 : end));
                    ptr = ptr + 1;
                end
            end
            
            fclose(fileID);
        end
        
        % Get method for Voc
        function output = get.Voc(obj)
            fileID = fopen(obj.fileName);
            output = zeros(obj.numOfDataSets, 1);

            ptr = 1;
            
            while ~feof(fileID)
                str = fgetl(fileID);
                if strncmp(str, obj.strVoc, length(obj.strVoc))
                    output(ptr, 1) = str2double(str(length(obj.strVoc) + 1 : length(obj.strVoc) + 9));
                    ptr = ptr + 1;
                end
            end
            
            fclose(fileID);
        end
        
        % Get method for PCE
        function output = get.PCE(obj)
            fileID = fopen(obj.fileName);
            output = zeros(obj.numOfDataSets, 1);

            ptr = 1;
            
            while ~feof(fileID)
                str = fgetl(fileID);
                if strncmp(str, obj.strPCE, length(obj.strPCE))
                    output(ptr, 1) = str2double(str(length(obj.strPCE) + 1 : length(obj.strPCE) + 8));
                    ptr = ptr + 1;
                end
            end
            
            fclose(fileID);
        end
        
        % Get method for Rs
        function output = get.Rs(obj)
            fileID = fopen(obj.fileName);
            output = zeros(obj.numOfDataSets, 1);

            ptr = 1;
            
            while ~feof(fileID)
                str = fgetl(fileID);
                if strncmp(str, obj.strRs, length(obj.strRs))
                    output(ptr, 1) = str2double(str(length(obj.strRs) + 1 : end));
                    ptr = ptr + 1;
                end
            end
            
            fclose(fileID);
        end
        
        % Get method for Rsh
         function output = get.Rsh(obj)
            fileID = fopen(obj.fileName);
            output = zeros(obj.numOfDataSets, 1);

            ptr = 1;
            
            while ~feof(fileID)
                str = fgetl(fileID);
                if strncmp(str, obj.strRsh, length(obj.strRsh))
                    output(ptr, 1) = str2double(str(length(obj.strRsh) + 1 : end));
                    ptr = ptr + 1;
                end
            end
            
            fclose(fileID);
         end

         % Get method for onlyOneSetOfData
         function output = get.onlyOneSetOfData(obj)
             output = false;
             try
                 isa(obj.numOfDataSets, 'int');
             catch
                 output = true;
             end
         end
         
    end
    
    %% Static Methods
    methods (Static)
        % Plot JV curve
        function plotJV(dataV, dataJ)
            figure
            plot(dataV, dataJ);
        end
    end
    
end
