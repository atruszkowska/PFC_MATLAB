function err_tot = FunctionF(params)
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % Function that communicates with the optimization algorithm and PFC
    % Input: parameters that the algorithm is searching for
    % Output: current error
    % NOTE: computes C11, C12 and C44 in GPa by fitting the stress-strain 
    % response; stress and strain tensor components used to compute the 
    % constants depend on PFC simulation and have to be adjusted manually
    % Computes from 60th data point - skips initial non-linear part, this was
    % optimzed and that is why is hardcoded
    % CURRENTLY COMPUTES FROM yy AND xz DEFORMATIONS
    % Data order from PFC (by columns): 
    % 1 - xx, 2 - xy, 3 - xz, 4 - yy, 5 - yz, 6 - zz
    % Last modified: July 21 2016
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    % Constraints on the parameters
    params=abs(params');
    temp=[params(1),params(2),params(3),params(4)];
    params=temp';

    % Save parameters to file
    save('parameters.txt', 'params', '-ascii')
    % Remove previous PFC results 
    delete('xz_ts_compression.txt')
    delete('spheres_time_compression.log')

    % Change hold flag and update flag file to start PFC simulation
    hold_flag=0;
    save('hold_flag.txt', 'hold_flag', '-ascii')
    % While PFC is running, hold and check hold_flag.txt for a signal from PFC
    % to continue the optimization
    while hold_flag==0
        pause(15)
        hold_flag=load('hold_flag.txt');
    end

    % Collect the new data and compute the constants
    [stress, rate]=get_spheres([strcat(pwd,'\spheres_time_compression'),'.log']); 
    time=import_hist([pwd,'\xz_ts_compression','.txt']);
    time=[0; time(:,4)];

    % Integrate the strains for each collected time interval
    for jst=1:6
        for jst2=2:length(time)
            strain(jst2,jst)=trapz(time(1:jst2),rate(1:jst2,jst));
        end
    end

    % Find the constants - uncomment rounding options if needs smaller
    % precision
    % C11 - yy
    ptemp=polyfit(strain(60:end,4),stress(60:end,4),1);
    C11=ptemp(1)/1e9%round(ptemp(1)/1e9)
    % C12 -yy&xx
    ptemp=polyfit(strain(60:end,4),stress(60:end,1),1);
    C12=ptemp(1)/1e9%round(ptemp(1)/1e9)
    % C44 -xz
    ptemp=polyfit(strain(60:end,3),stress(60:end,3),1);
    C44=ptemp(1)/1e9/2 %round(ptemp(1)/1e9/2)

    % Saving current data after each iteration - in case of crashes
    save('temp')

    % Error
    reler=@(a,b)abs((a-b)/b);
    % Experimental data (extrapolated to 873.15 K from data used for MD 
    % constants comparison), GPa
    C11exp=460;
    C12exp=176;
    C44exp=110;
    % Relative errors
    reler(C11,C11exp)
    reler(C44,C44exp)
    reler(C12,C12exp)
    % For - LSQ or weighted LSQ
    err_tot=sqrt(reler(C11,C11exp)^2+reler(C12,C12exp)^2+reler(C44,C44exp)^2);
    % err_tot=sqrt(10*reler(C12/C11,C12exp/C11exp)^2+10*reler(C44/C12,C44exp/C12exp)^2+...
    %     reler(C44/C11,C44exp/C11exp)^2);
end
