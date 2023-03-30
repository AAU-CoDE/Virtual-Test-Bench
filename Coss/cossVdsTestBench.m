function output = cossVdsTestBench(fcoss,VdsLim,nSampleTot,userDef,plotOn)


    % Sweep
    cossExtracted = cossVdsExtraction(fcoss,VdsLim,nSampleTot,userDef);
    
    if plotOn == 1
        % Plot 
        figure(2)
            semilogy(cossExtracted.Vds,cossExtracted.Coss.*1e12,'x')
            grid on
            title(append("Coss(Vds), ",userDef.mosfetModel))
            ylim([1 10000])
            xlabel("Drain-Source Voltage [V]")
            ylabel("Output Capacitance [pF]")
    end
    %% Qoss (Numerical Integration)
    
    % Ignore values bigger than 1uF;
    largeCossIdx = cossExtracted.Coss > 1e-6;
    cossExtracted.CossValid = cossExtracted.Coss;
    cossExtracted.VdsValid = cossExtracted.Vds;
    cossExtracted.CossValid(largeCossIdx) = [];
    cossExtracted.VdsValid(largeCossIdx) = [];
    % Numerical Integration
    qossLT = cumtrapz(cossExtracted.VdsValid,cossExtracted.CossValid);
    
    % Interpolation of Qoss(Vds)
    vdsVec = cossExtracted.Vds(1):0.01:cossExtracted.Vds(end);
    qossVec = interp1(cossExtracted.VdsValid,qossLT,vdsVec,"pchip","extrap");
    
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
    qossVdsFunc = @(x) 2.*a.*b.*sqrt((b + x)/b) + c.*x.^2./2 - 2.*a.*b;
    % Derivative for Coss(vds)
    cossVdsFunc = @(x) a./(1 + x./b).^0.5 + c.*x;
    
    if plotOn == 1
        figure(3)
            plot(cossExtracted.VdsValid,qossLT*1e6,'*')
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
    end
        
    %% Output
    output.mosfetModel = userDef.mosfetModel;
    
    output.cossVdsFunc = cossVdsFunc;
    output.qossVdsFunc = qossVdsFunc;
    
    output.cossExtracted = cossExtracted;
    output.cossTable = [vdsVec',cossVdsFunc(vdsVec)'];
    output.qossTable = [vdsVec',qossVec'];

end