function output = crssVdsTestBench(fcrss,VdsLim,nSampleTot,userDef,plotOn)


    % Sweep
    crssExtracted = crssVdsExtraction(fcrss,VdsLim,nSampleTot,userDef);
    
    if plotOn == 1
        % Plot 
        figure(2)
            semilogy(crssExtracted.Vds,crssExtracted.Crss.*1e12,'x')
            grid on
            title(append("Crss(Vds), ",userDef.mosfetModel))
            ylim([1 10000])
            xlabel("Drain-Source Voltage [V]")
            ylabel("Output Capacitance [pF]")
    end
    %% Qrss (Numerical Integration)
    
    % Ignore values bigger than 1uF;
    largeCrssIdx = crssExtracted.Crss > 1e-6;
    crssExtracted.CrssValid = crssExtracted.Crss;
    crssExtracted.VdsValid = crssExtracted.Vds;
    crssExtracted.CrssValid(largeCrssIdx) = [];
    crssExtracted.VdsValid(largeCrssIdx) = [];
    % Numerical Integration
    qrssLT = cumtrapz(crssExtracted.VdsValid,crssExtracted.CrssValid);
    
    % Interpolation of Qrss(Vds)
    
    vdsVec = crssExtracted.Vds(1):0.1:crssExtracted.Vds(end);
    crssVec =  interp1(crssExtracted.VdsValid,crssExtracted.CrssValid,vdsVec,"pchip","extrap");
    qrssVec = cumtrapz(vdsVec, crssVec);
    % Define Fit Function
    
    
    if plotOn == 1
        figure(5)
            plot(crssExtracted.VdsValid,qrssLT*1e6,'*')
            hold on
            plot(vdsVec,qrssVec*1e6)
            %plot(vdsVec,qrssVdsFunc(vdsVec)*1e6)
            grid on
            title(append("Qrss(Vds), ",userDef.mosfetModel))
            %ylim([1 10000])
            xlabel("Drain-Source Voltage [V]")
            ylabel("Output Charge[\mu C]")
            hold off
            legend("LTSpice Extracted","Interpolated Data")%,"Curve Fit Function")
            
        figure(6)
            semilogy(crssExtracted.Vds,crssExtracted.Crss*1e12,'*')
            hold on
            semilogy(vdsVec,crssVec*1e12)
            %semilogy(vdsVec,crssVdsFunc(vdsVec)*1e12)
            grid on
            title(append("Crss(Vds), ",userDef.mosfetModel))
            ylim([1 10000])
            xlabel("Drain-Source Voltage [V]")
            ylabel("Output Capacitance[pF]")
            hold off
            legend("LTSpice Extracted","Interpolated Data")%,"Curve Fit Function")
    end
        
    %% Output
    output.mosfetModel = userDef.mosfetModel;
    
    %output.crssVdsFunc = crssVdsFunc;
    %output.qrssVdsFunc = qrssVdsFunc;
    
    output.crssExtracted = crssExtracted;
    output.crssTable = [vdsVec',crssVec'];
    output.qrssTable = [vdsVec',qrssVec'];
%     output.fitParams = crssFitParams;

end