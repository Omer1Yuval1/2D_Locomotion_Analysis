function Plot_Time_Series_Feature(filename,Feature_Name,Time_Series_Features_Struct,Chosen_Worms_Indices)
    
    % Get the HDF5 file info and display the top level dataset names:
    fileInfo = h5info(filename);
    disp({fileInfo.Datasets.Name}');
    
    % Get the frame rate:
    fps = h5readatt(filename,'/features_timeseries', 'fps');
    % disp(h5readatt(filename,'/features_timeseries','xy_units'));  % confirm that the xy units have been converted from pixels to microns. These are included in the HDF5 file's attributes.  Other useful attributes are microns_per_pixel, time_units, and is_light_background.

    Worms_Indices = [Time_Series_Features_Struct.worm_index];
    % disp(['This file has ' num2str(numel(Worms_Indices)) ' tracks.']);
    
    figure;
    for i=1:length(Chosen_Worms_Indices)
        ii = find(Worms_Indices == Chosen_Worms_Indices(i));
        plot(Time_Series_Features_Struct(ii).timestamp ./ fps,Time_Series_Features_Struct(ii).(Feature_Name),'.');
        hold on;
    end
    set(gca,'FontSize', 18);
    xlabel('Time (s)');
    ylabel(Feature_Name);

end