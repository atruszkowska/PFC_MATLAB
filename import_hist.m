function hist = import_hist(filename)
    %% Import history files as matrices
    fid=fopen(filename);
    % First two rows are headers
    fgets(fid);
    fgets(fid);

    % Rest is data
    hist=[];
    tline=fgets(fid);
    ih=1;
    while ischar(tline)
        hist(ih,:)=strread(tline);
        tline=fgets(fid);
        ih=ih+1;
    end
    fclose(fid);
end
