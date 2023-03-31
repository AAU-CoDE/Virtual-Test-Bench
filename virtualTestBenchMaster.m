%%% Extract Look-up table & function from LTSpice model of device
%% Initialize
clear 
close all
warning off

%% Specify MOSFET Model Filename 'mosfetFileName'.lib:

userDef. mosfetLibFileName = ''; % Specify the name of the .lib file, as found in your directory. (without .lib)
% E.g.: userDef.mosfetLibFileName = 'C2M0160120D - Packaged';

% If .lib file name is different from model file name (after .subckt
% statement within .lib file), or .lib file contains several models, but you know which model you want to extract, you can define the model name here and skip the dialogue 
% E.g.: userDef.mosfetModel = 'C2M0160120D';

%% Set up paths
% Automatically find working directory (No need to touch this)
userDef.pathName = setWorkingDir;
% Define LTSpice Paths
[userDef.mosfetLibFileName, userDef.LTlibPath] = setSpiceLibPath(userDef.mosfetLibFileName);
userDef.LTexePathBatch = setLTexePath;
% .subckt parse: Extract the nodes of the used model:
userDef.mosfetModel = subcktNameFinder(userDef);
userDef.mosfetNodeList = mosfetNodeExtract(userDef.LTlibPath,userDef.mosfetLibFileName,userDef.mosfetModel);
userDef.nodeListGeneral = generalizeNodeList(userDef.mosfetNodeList);

%% Rdson(Tj)
% Rdson - Test Conditions
Vgs = 20;  % Gate-Source Voltage
Id = 20; % Drain Current
% Temperature Range
Tj_array = 0.1:25:175;

plotOn = 1; % Want a plot? 1 = Yes, 0 = No
rdson = rdsonTjTestBench(Id,Vgs,Tj_array,userDef,plotOn);

%% Coss(Vds)/Qoss(Vds)
% Coss - Test Conditions
fcoss = 1e6; % 1MHz -  AC frequency
VdsMax = 1200; % Drain-Source Voltage Limit
VdsMin = 1e-2; % Lower Voltage Limit
nSampleTot = 25; % Nr of samples

plotOn = 1; % Want a plot? 1 = Yes, 0 = No
coss = cossVdsTestBench(fcoss,[VdsMin,VdsMax],nSampleTot,userDef,plotOn);

%%
disp("EXTRACTION FINISHED")
%% Future Work
% Expandable: Thermal Impedance?

% Interface?
