%%% Automate extracting Rdson & Coss from a LTPsice Model
clear all
pathName = useAutomatePath; % Comment and set your own path!
% Set path to LTSpice Library (where LTSPice Models are stored)
LTlibPath = 'C:\Users\gd48aa\OneDrive - Aalborg Universitet\Documents\LTspiceXVII\lib\SicMOSFET\Wolfspeed\';
%LTlibPath = 'C:\Users\gd48aa\OneDrive - Aalborg Universitet\Documents\LTspiceXVII\lib\SicMOSFET\';

% Specify MOSFET Model 'mosfetmodel'.lib:
mosfetModel = 'C2M0080120D';
%mosfetModel = 'CPM3-1200-0013A';
%mosfetModel = 'G3R160MT12J';

% .subckt parse: Extract the nodes of the used model:
mosfetNodeList = mosfetNodeExtract(LTlibPath,mosfetModel);
%% RdsonTestBench Netlist
% Gate-Source Voltage
Vgs = 20;
% Drain Current
Id = 20;
% Junction Temperature
Tj_array = 0.1:25:175;
% Run Rdson Test
run('virtualTestBench\rdsonLtspiceSweep.m')

% Interpolate Points    
tjFit = linspace(Tj_array(1),Tj_array(end),1000);
rdsonExtrac = interp1(rdsonIter.Tj,rdsonIter.Rdson,tjFit,'spline','extrap');

% Curve Fit
[rdsonTj, rdsonR2] = fitThisCurve(tjFit,rdsonExtrac,0.999);
% Plot
close all
figure(1)
    plot(rdsonIter.Tj,rdsonIter.Rdson,'*')
    hold on    
    grid on
    plot(tjFit,rdsonExtrac,'Color','b')
    plot(rdsonTj)
    
    hold off
    ylabel('Rdson')
    xlabel('Tj')
    title(append('Rdson(Tj) ',mosfetModel,' Id = ',num2str(Id),'A'))
    legend("Extracted Points","Interpolated Points","Curve-fitted Points")

% As Function Handle
rdsonFunc = @(x) rdsonTj(x);

%% Coss 

% AC frequency
fcoss = 1e6; % 1MHz

% Drain-Source Voltage range
VdsMin = 1e-3;
VdsMax = 1200;
nSampleTot = 25;

% First few samples (20%) should be in log (up to 1% of Vds Max)
nSampleLog = ceil(nSampleTot*0.20);
Vds_arrayLV = logspace(log10(VdsMin),log10(VdsMax*0.01),nSampleLog); % "low" voltage sample points

% Last half of sample points should be linearily spaced
Vds_arrayHV = linspace(VdsMax*0.01,VdsMax,nSampleTot-nSampleLog); % "high" voltage sample points
Vds_array = [Vds_arrayLV, Vds_arrayHV(2:end)]; % combine drain-source voltage sample points

% Run Coss Test
run("virtualTestBench\cossLtspiceSweep.m")
disp("COSS EXTRACTION FINISHED")

% Plot 
figure(2)
    semilogy(cossIter.Vds,cossIter.Coss.*1e12,'x')
    grid on
    title(append("Coss(Vds), ",mosfetModel))
    ylim([1 10000])
    xlabel("Drain-Source Voltage [V]")
    ylabel("Output Capacitance [pF]")

%% Coss Interpolation 
% Algorithm to get equally spaced interpolated points

% GeneSiC Model is not robust for low voltages, reject datapoints below 5V
if contains(mosfetModel,'G3R') == 1 % GeneSiC
     validDataStart = find(cossIter.Vds >= 5, 1);
else 
    % Start interpolating at sample point where the Coss(Vds) curve starts evening out
   validDataStart = nSampleLog- 1; 
end

[vdsPoints, cossPoints, dFound] = euclideanInterpolation(cossIter.Vds(validDataStart:end),cossIter.Coss(validDataStart:end),200,0);
vdsPoints = [cossIter.Vds,vdsPoints];
cossPoints = [cossIter.Coss,cossPoints];
% PLOT Interpolation
        
figure(3)
    plot(cossIter.Vds,cossIter.Coss.*1e12,'*')
    grid on
    title(append("Coss(Vds), ",mosfetModel))
    ylim([1 3000])
    xlabel("Drain-Source Voltage [V]")
    ylabel("Output Capacitance [pF]")
    hold on
    plot(vdsPoints,cossPoints.*1e12,'x')
    hold off

%%  Coss Fit

% Fit type for SiC capacitance: a/(1 + x/b)^0.5 + c*x 
sicFit = fittype( 'a./(1 + x./b).^0.5 + c.*x',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a','b','c'});
    % Fit Options
    fitopt = fitoptions(sicFit);
    fitopt.Lower = [0 1e-3 0];
    fitopt.Upper = [1e-7 1 1e-7];
    fitopt.StartPoint = [3.945e-09,0.3187,1.839e-14];
% Initialize
R2 = 0;
fitIter = 1;
fitIterMin = 50;
% Fit several times to get the best fit
while fitIter < fitIterMin
    [cossVds, cossGof] = fit(vdsPoints',cossPoints',sicFit,fitopt);

    if R2 < cossGof.rsquare
        cossR2 = cossGof.rsquare;
    end
    fitIter = fitIter + 1;
end
% Plot
vdsVec = [0:0.1:VdsMax];
cossFit = cossVds(vdsVec)';

figure(11)
    semilogy(cossIter.Vds,cossIter.Coss.*1e12,'*')
    hold on
     semilogy(vdsVec,cossFit.*1e12)
    grid on
    title(append("Coss(Vds), ",mosfetModel))
    ylim([1 10000])
    xlabel("Drain-Source Voltage [V]")
    ylabel("Output Capacitance [pF]")
    hold off
    
    legend("LTSpice Calculated","Curve Fit Function")
% As Function Handle
cossFunc = @(x) cossVds(x);

%% END
output.mosfetModel = mosfetModel;
output.rdsonFunc = rdsonFunc;
output.rdsonTable = [tjFit',rdsonExtrac'];
output.cossTable = [vdsPoints',cossPoints'];
disp("LTSPICE EXTRACTION FINISHED")
