classdef Device
% -------------------------------------------------------------------------
% Device is a class where you can define the properties of your PV devices
% or the devices built in drift diffusion simualtions. The parameters for
% the device are described in the properties section, which can be modified
% at initialization or any time with dot notation.
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

    %% Constant properties
    properties (Constant)
        kB = 1.380649 * 1e-23; % Boltzmann constant [J/K]
        T = 300; % temperature [K]
        q = 1.602176634 * 1e-19; % elementary charge [C]
        h = 6.62607015 * 1e-34; % [J*s]
        c = 2.99792458 * 1e8;    % [m/s]
    end
    
    %% Properties to be defined
    properties
        L = 700 * 1e-7; % Active layer thickness [nm]
        Nc = 3.1e18; % Conduction band effective density of states[cm^-3]
        Nv = 3.1e18; % Valance band effective DoS [cm^-3]
        Eg = 1.6; % Active layer bandgap [eV]
        tBulk = 500 * 1e-9; % Bulk SRH recombination lifetime [s]
        RsSim = 1; % Series resistance used in drift diffusion simulations [Ohm*cm^2]
        RshSim = 1e7; % Shunt resistance used in drift diffusion simulations [Ohm*cm^2]
    end
    
    %%  Properties whose values depend on other properties (see 'get' methods)
    properties (Dependent)
       ni; % Active layer intrinsic carrier concentration [cm^-3]
       yBulk; % Bulk SRH recombination coefficient [s^-1]
    end

    %% Methods
    methods
        %% Constructor
        function obj = Device(varargin)
            % Device constructor method - runs numerous checks that
            % the input properties are consistent with the model
            if nargin > 1
                warning('Only the first input arg is used.')
            end
            
            if nargin >= 1
                % Use argument to read and overwrite properties.
                Prpt = varargin{1, 1};
                try
                    obj.L = Prpt(1, 1);
                catch
                    warning('No input thickness value. Using default value.')
                end
                try
                    obj.Nc = Prpt(1, 2);
                catch
                    warning('No input Nc value. Using default value.')
                end
                try
                    obj.Nv = Prpt(1, 3);
                catch
                    warning('No input Nv value. Using default value.')
                end
                try
                    obj.Eg = Prpt(1, 4);
                catch
                    warning('No input Eg value. Using default value.')
                end
                try
                    obj.tBulk = Prpt(1, 5);
                catch
                    warning('No input bulk SRH recombination lifetime value. Using default value.')
                end
                try
                    obj.RsSim = Prpt(1, 6);
                catch
                    warning('No input series resistance (in simulation) value. Using default value.')
                end
                try
                    obj.RshSim = Prpt(1, 7);
                catch
                    warning('No input shunt resistance (in simulation) value. Using default value.')
                end
            end
        end
        
        %% Property get methods
        function output = get.ni(obj)
            output = sqrt(obj.Nc * obj.Nv) * exp(-obj.Eg * obj.q / 2 / obj.kB / obj.T);
        end
        
        function output = get.yBulk(obj)
            output = 1 / 2 / obj.tBulk;
        end
        
    end
end

