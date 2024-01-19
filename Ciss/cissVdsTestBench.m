function output = cissVdsTestBench(fciss,VdsLim,nSampleTot,userDef,plotOn)


    % Sweep
    cissExtracted = cissVdsExtraction(fciss,VdsLim,nSampleTot,userDef);
    
    if plotOn == 1
        % Plot 
        figure(2)
            semilogy(cissExtracted.Vds,cissExtracted.Ciss.*1e12,'x')
            grid on
            title(append("Ciss(Vds), ",userDef.mosfetModel))
            ylim([1 10000])
            xlabel("Drain-Source Voltage [V]")
            ylabel("Output Capacitance [pF]")
    end
    %% Qiss (Numerical Integration)
    
    % Ignore values bigger than 1uF;
    largeCissIdx = cissExtracted.Ciss > 1e-6;
    cissExtracted.CissValid = cissExtracted.Ciss;
    cissExtracted.VdsValid = cissExtracted.Vds;
    cissExtracted.CissValid(largeCissIdx) = [];
    cissExtracted.VdsValid(largeCissIdx) = [];
    % Numerical Integration
    qissLT = cumtrapz(cissExtracted.VdsValid,cissExtracted.CissValid);
    
    % Interpolation of Qiss(Vds)
    
    vdsVec = cissExtracted.Vds(1):0.1:cissExtracted.Vds(end);
    cissVec =  interp1(cissExtracted.VdsValid,cissExtracted.CissValid,vdsVec,"pchip","extrap");
    qissVec = cumtrapz(vdsVec, cissVec);
    % Define Fit Function
    cissFitFunc = fittype( 'a./((1 + x./b).^0.25) + c;',...
        'dependent',{'y'},'independent',{'x'},...
        'coefficients',{'a','b','c'});
     % Fit Options
        fitopt = fitoptions(cissFitFunc);
        fitopt.Lower = [1e-15 1e-3 1e-15];
        fitopt.Upper = [1e-7 1 1e-7];
        fitopt.DiffMinChange = 1e-16;
        fitopt.TolFun = 1e-16;
        fitopt.MaxFunEvals= 10000;
        fitopt.MaxIter= 10000;
    % Fit Interpolated points
    [cissFit, cissGof] = fit(vdsVec',cissVec',cissFitFunc,fitopt);
    % Extract Parameters
    cissFitParams = coeffvalues(cissFit);
    a = cissFitParams(1);
    b = cissFitParams(2);
    c = cissFitParams(3);

    qissFitFunc = fittype( '4.*a.*(b + x)./(3.*(b + x)/b).^0.25 + c.*x;;',...
        'dependent',{'y'},'independent',{'x'},...
        'coefficients',{'a','b','c'});
     % Fit Options
        fitopt = fitoptions(qissFitFunc);
        fitopt.Lower = [1e-15 1e-3 1e-15];
        fitopt.Upper = [1e-7 1 1e-7];
        fitopt.DiffMinChange = 1e-16;
        fitopt.TolFun = 1e-16;
        fitopt.MaxFunEvals= 10000;
        fitopt.MaxIter= 10000;
    % Fit Interpolated points
    [qissFit, qissGof] = fit(vdsVec',qissVec',qissFitFunc,fitopt);
    % Extract Parameters
    qissFitParams = coeffvalues(cissFit);
    aq = cissFitParams(1);
    bq = cissFitParams(2);
    cq = cissFitParams(3);
    %% As Analytical Function Qiss(vds)
    qissVdsFunc = @(x) 4.*aq.*(bq + x)./(3.*(bq + x)/bq).^0.25 + cq.*x;
    % Derivative for Ciss(vds)
    cissVdsFunc = @(x) a./((1 + x./b).^0.25) + c;
    
    if plotOn == 1
        figure(5)
            plot(cissExtracted.VdsValid,qissLT*1e6,'*')
            hold on
            plot(vdsVec,qissVec*1e6)
            plot(vdsVec,qissVdsFunc(vdsVec)*1e6)
            grid on
            title(append("Qiss(Vds), ",userDef.mosfetModel))
            %ylim([1 10000])
            xlabel("Drain-Source Voltage [V]")
            ylabel("Output Charge[\mu C]")
            hold off
            legend("LTSpice Extracted","Interpolated Data","Curve Fit Function")
            
        figure(6)
            semilogy(cissExtracted.Vds,cissExtracted.Ciss*1e12,'*')
            hold on
            semilogy(vdsVec,cissVec*1e12)
            semilogy(vdsVec,cissVdsFunc(vdsVec)*1e12)
            grid on
            title(append("Ciss(Vds), ",userDef.mosfetModel))
            ylim([1 10000])
            xlabel("Drain-Source Voltage [V]")
            ylabel("Output Capacitance[pF]")
            hold off
            legend("LTSpice Extracted","Interpolated Data","Curve Fit Function")
    end
        
    %% Output
    output.mosfetModel = userDef.mosfetModel;
    
    output.cissVdsFunc = cissVdsFunc;
    output.qissVdsFunc = qissVdsFunc;
    
    output.cissExtracted = cissExtracted;
    output.cissTable = [vdsVec',cissVdsFunc(vdsVec)'];
    output.qissTable = [vdsVec',qissVec'];
    output.fitParams = cissFitParams;

end