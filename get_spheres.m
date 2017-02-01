function [stress, strain]=get_spheres(filename)
    %% Extract stress and strain data from the measurment spheres datafiles
    fid=fopen(filename);

    stress=[];
    strain=[];
    tline=fgetl(fid);
    kval=1;
    while ischar(tline)
        % If line above numbers - collect the output
        if length(tline)>2
            if strcmp(tline(1:3),'pfc')
                tline = fgetl(fid);
                if ~strcmp(tline(1),'*')
                    stress(kval,:)=strread(tline);
                    tline = fgetl(fid);
                    strain(kval,:)=strread(tline);
                    kval=kval+1;
                end
            end
        end
        tline = fgetl(fid);
    end    
    fclose(fid);
end