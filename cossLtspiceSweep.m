cossPath = append(pathName,'\virtualTestBench\Coss\');
reltolvds = 1e-1;
for itNr = 1:numel(Vds_array)
        Vds = Vds_array(itNr) 
        % Create Netlist
        run('cossNetlist.m')
        % Run Netlist.        
        dos(append(cossPath,'LTspice_call.bat'));
        pause(1)
        % Extract Data
        simStart = 0;
        while simStart == 0
            pause(0.5)
            % Read .raw file for the first time
            try
                cossRawData(itNr) = LTspice2Matlab(append(cossPath,filename,'.raw'));
            catch
                pause(5)
                 cossRawData(itNr) = LTspice2Matlab(append(cossPath,filename,'.raw'));
            end
            % Check whether simulation has started (by checking Vds)
            VdsSim = LTretrieve("V(ds)",cossRawData(itNr));
            if abs(VdsSim(1) - Vds)/VdsSim(1) < reltolvds
                simStart = 1;
            end
        end
        % Check whether simulation is done 
        while cossRawData(itNr).time_vect(end) < 2/fcoss
            pause(0.5)
            cossRawData(itNr) = LTspice2Matlab(append(cossPath,filename,'.raw'));
        end
        % End LTSpice
        %dos(append(pwd,path,'LTspice_end.bat'))
        
        % Extract Variables    
        if contains(mosfetModel,'G3R') == 1 % Encrypted, can't be parsed
           IacFull = LTretrieve("Ix(u2:DP)",cossRawData(itNr));
        else
            IacFull = LTretrieve("I(Vac)",cossRawData(itNr));
        end        
        VacFull = LTretrieve("V(s)",cossRawData(itNr));
        tFull = cossRawData(itNr).time_vect;
        % Remove first Period:
        firstPeriodIdx = find(tFull > 1e-6,1);
        t = tFull(firstPeriodIdx:end);
        Vac = VacFull(firstPeriodIdx:end);
        Iac = IacFull(firstPeriodIdx:end);

        % Find Coss 
        ts = 1/fcoss; % Time Period
        % Find time & value of max(Vac)
        [VacMax, VacMaxIdx] = max(Vac);
        tVacMax = t(VacMaxIdx);

        % Find time & value of min/max(Iac)
        [IacMax, IacMaxIdx] = max(Iac);
        IacMin = min(Iac);      
        tIacMax = t(IacMaxIdx);
        % Remove Bias
        IacAmp = (IacMax - IacMin)/2;
        
        % Calculate angle between V & I
        phaseAngle = mod((tIacMax - tVacMax)/ts*2*pi,pi);
        %phaseAngle = pi/2;
        % Impedance
        Z = VacMax/IacAmp;
        Coss = 1/(cos(pi/2 - phaseAngle)*Z*2*pi*fcoss)


        % Build Struct
        cossIter.Coss(itNr) = Coss;
        cossIter.f(itNr) = 1/ts;
        cossIter.Vds(itNr) = Vds;
        cossIter.VacMax(itNr) = VacMax;
        cossIter.tVacMax(itNr) = tVacMax;
        
        
        cossIter.IacAmp(itNr) =  IacAmp;
        cossIter.tIacMax(itNr) = tIacMax;
      
        cossIter.phaseAngle(1,itNr) = phaseAngle;
        cossIter.phaseAngle(2,itNr) = rad2deg(phaseAngle);
        cossIter.ts(itNr) = ts;
        % Vectors
        cossIterVec(itNr).Iac = Iac;
        cossIterVec(itNr).Vac = Vac;
        cossIterVec(itNr).t = t;
end