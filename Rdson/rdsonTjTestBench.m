function output = rdsonTjTestBench(Id,Vgs,Tj_array,userDef,plotOn)

    % Sweep Tj
    rdsonExtracted = rdsonTjExtraction(Id,Vgs,Tj_array,userDef);
    
    % Interpolate Points    
    tjInterp = linspace(rdsonExtracted.Tj(1),rdsonExtracted.Tj(end),1000);
    rdsonInterp = interp1(rdsonExtracted.Tj,rdsonExtracted.Rdson,tjInterp,'spline','extrap');
    % Curve fit
    [rdsonTjFit, rdsonR2] = fitThisCurve(tjInterp,rdsonInterp,0.999); % fitThisCurve will try to find the best possible fit with Matlabs standard cf functions
    % Write as analytical Function
    
    rdsonTjFunc =  cfit2functionHandle(rdsonTjFit);

    if plotOn == 1
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
    end

    output.mosfetModel = userDef.mosfetModel;
    output.rdsonTjFunc = rdsonTjFunc;
    output.rdsonExtracted = rdsonExtracted;
    output.rdsonTable = [tjInterp',rdsonInterp'];
end