%%% Extract Look-up table & function from LTSpice model of device
clear 
close all

%% Specify MOSFET Model 'mosfetmodel'.lib:
mosfetModel = 'C2M0080120D';

%% Define Test Conditions

% Rdson
% Define Test Conditions  
Vgs = 20;  % Gate-Source Voltage
Id = 20; % Drain Current
% Temperature Range
Tj_array = 0.1:25:175;

% Coss
% Define Test Conditions
fcoss = 1e6; % 1MHz -  AC frequency

VdsMax = 1200; % Drain-Source Voltage Limit
VdsMin = 1e-3; % Lower Voltage Limit
nSampleTot = 25; % Nr of samples

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Delete 'pathinfo.mat' if you want to reset the paths, or add them
%%% manually in section "Define LTSpice Paths"
%%%
%%% The rest below is automated, results will by in the struct 'output'
%%%
%% Automatically find working directory (No need to touch this)
    fullFilePath =  matlab.desktop.editor.getActiveFilename;
    startOfFileName = find(fullFilePath == '\',1,"last");
    userDef.pathName = fullFilePath(1:startOfFileName);
    % Add relevant folders to path
    cd(userDef.pathName)
    addpath(genpath(userDef.pathName))

%% Define LTSpice Paths
% Collect paths & model to stuct to parse it to other functions as 'userDef'

% Check whether pathfile already exists

try
    load('LTlibPathInfo.mat')
catch
    % Set LTSPice library path (where you stored .lib files)
    % userDef.LTlibPath = 'C:\Users\gd48aa\OneDrive - Aalborg Universitet\Documents\LTspiceXVII\lib\SicMOSFET\Wolfspeed\';
    disp('Set LTSPice library path (where you store your .lib files)')
    LTlibPath = uigetdir('Set LTSPice library path'); 
    save('LTlibPathInfo.mat','LTlibPath')
end

try
    load('LTexePathInfo.mat')
catch
    % Set LTSpice .exe path (where the application is installed - used for batch file generation)
    %LTexePath = 'C:\Program Files\LTC\LTspiceXVII\XVIIx86.exe';
    
    disp('Set LTSpice .exe path (where the application is installed - used for batch file generation)')
    [LTexeFile, LTexePath] = uigetfile('*.exe','Set LTSpice .exe path (XVIIx86.exe or similar)','C:\');
    LTexeFullPath = append(LTexePath,LTexeFile);
    save('LTexePathInfo.mat','LTexeFullPath')
end
% Store in userDef
userDef.LTlibPath = append(LTlibPath,'\');
userDef.LTexePathBatch = replace(LTexeFullPath,'\','\\'); % Used with double backslash within Batch file
% .subckt parse: Extract the nodes of the used model:
userDef.mosfetModel = mosfetModel;
userDef.mosfetNodeList = mosfetNodeExtract(userDef.LTlibPath,userDef.mosfetModel);


%% Extract Parameters: Rdson(Tj)
% Sweep
rdsonExtracted = rdsonTjExtraction(Id,Vgs,Tj_array,userDef);

% Interpolate Points    
tjInterp = linspace(rdsonExtracted.Tj(1),rdsonExtracted.Tj(end),1000);
rdsonInterp = interp1(rdsonExtracted.Tj,rdsonExtracted.Rdson,tjInterp,'spline','extrap');
% Curve fit
[rdsonTjFit, rdsonR2] = fitThisCurve(tjInterp,rdsonInterp,0.999); % fitThisCurve will try to find the best possible fit with Matlabs standard cf functions
% Write as analytical Function

rdsonTjFunc =  cfit2functionHandle(rdsonTjFit);
% Plot the Result
figure(1)
    plot(rdsonExtracted.Tj,rdsonExtracted.Rdson,'*')
    hold on    
    grid on
    plot(tjInterp,rdsonInterp,'Color','b')
    plot(rdsonTjFit)
    
    hold off
    ylabel('Rdson')
    xlabel('Tj')
    title(append('Rdson(Tj) of  ',userDef.mosfetModel,' Id = ',num2str(Id),'A'))
    legend("Extracted Points","Interpolated Points","Curve-fitted Points")

%% Coss(Vds)/Qoss(Vds)
    
% Sweep
cossExtracted = cossVdsExtraction(fcoss,[VdsMin, VdsMax],nSampleTot,userDef);
            
disp("COSS EXTRACTION FINISHED")
% Plot 
figure(2)
    semilogy(cossExtracted.Vds,cossExtracted.Coss.*1e12,'x')
    grid on
    title(append("Coss(Vds), ",userDef.mosfetModel))
    ylim([1 10000])
    xlabel("Drain-Source Voltage [V]")
    ylabel("Output Capacitance [pF]")

% Qoss (Numerical Integration)
qossLT = cumtrapz(cossExtracted.Vds,cossExtracted.Coss);

% Interpolation of Qoss(Vds)
vdsVec = cossExtracted.Vds(1):0.01:cossExtracted.Vds(end);
qossVec = interp1(cossExtracted.Vds,qossLT,vdsVec,"pchip","extrap");

% Define Fit Function
qossFitFunc = fittype( '2.*a.*b.*sqrt((b + x)/b) + c.*x.^2./2;',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a','b','c'});
 % Fit Options
    fitopt = fitoptions(qossFitFunc);
    fitopt.Lower = [1e-15 1e-3 1e-15];
    fitopt.Upper = [1e-7 1 1e-7];
    fitopt.DiffMinChange = 1e-16;
    fitopt.TolFun = 1e-16;
    fitopt.MaxFunEvals= 10000;
    fitopt.MaxIter= 10000;
% Fit Interpolated points
[qossFit, qossGof] = fit(vdsVec',qossVec',qossFitFunc,fitopt);
% Extract Parameters
qossFitParams = coeffvalues(qossFit);
a = qossFitParams(1);
b = qossFitParams(2);
c = qossFitParams(3);
% As Analytical Function Qoss(vds)
qossVdsFunc = @(x) 2.*a.*b.*sqrt((b + x)/b) + c.*x.^2./2;
% Derivative for Coss(vds)
cossVdsFunc = @(x) a./(1 + x./b).^0.5 + c.*x;


figure(3)
    plot(cossExtracted.Vds,qossLT*1e6,'*')
    hold on
    plot(vdsVec,qossVec*1e6)
    plot(vdsVec,qossVdsFunc(vdsVec)*1e6)
    grid on
    title(append("Qoss(Vds), ",userDef.mosfetModel))
    %ylim([1 10000])
    xlabel("Drain-Source Voltage [V]")
    ylabel("Output Charge[\mu C]")
    hold off
    legend("LTSpice Extracted","Interpolated Data","Curve Fit Function")
    
figure(4)
    semilogy(cossExtracted.Vds,cossExtracted.Coss*1e12,'*')
    hold on
    semilogy(vdsVec,cossVdsFunc(vdsVec)*1e12)
    grid on
    title(append("Coss(Vds), ",userDef.mosfetModel))
    ylim([1 10000])
    xlabel("Drain-Source Voltage [V]")
    ylabel("Output Capacitance[pF]")
    hold off
    legend("LTSpice Extracted","Interpolated Data","Curve Fit Function")
    
%% Output
output.mosfetModel = userDef.mosfetModel;
output.rdsonTjFunc = rdsonTjFunc;
output.cossVdsFunc = cossVdsFunc;
output.qossVdsFunc = qossVdsFunc;
output.rdsonExtract = [rdsonExtracted.Tj',rdsonExtracted.Rdson'];
output.rdsonTable = [tjInterp',rdsonInterp'];
output.cossExtract = [cossExtracted.Vds',cossExtracted.Coss'];
output.cossTable = [vdsVec',cossVdsFunc(vdsVec)'];
output.qossTable = [vdsVec',qossVec'];

%% Future Work
% Expandable: Thermal Impedance?

% Interface?
