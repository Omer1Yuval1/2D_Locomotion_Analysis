function [Time_Series_Features_Struct,Time_Series_Features,Smoothed_Skeletons,Worms_Indices,featNames,Time_Series] = HDF5_2_MATLAB(fileName,minLength,featFlag,Chosen_Worms_Indices)
    
    % FEATSTRUCT2MAT imports the mean features from a tierpsy HDF5 feature file
    % and converts them into a feature matrix.  Features derived from
    % trajectories less than minLength are not included.
    % 
    % Input
    %   fileName  - the full path of the file to be imported.
    %   minLength - the minimum trajectory length (in frames) required for data
    %               to be included.
    %   featFlag  - logical vector of length 726 indicating whether each mean 
    %               feature is to be included. Mean feature table has 730
    %               entries, but first 4 are metadata not features.
    % 
    % Output
    %   featMat   - a numTrajectories x numFeatures matrix of mean feature
    %               values. May contain NaNs for features that could not be
    %               calculated.
    %   wormInds  - the indices used to identify each trajectory. Can be used
    %               to get skeleton and trajectory data corresponding to
    %               mean feature data.
    %   featNames - the names of each of the features
    
    % check inputs
    if ~islogical(featFlag)
        error('featFlag must be a vector of logicals.')
    end

    % Load feature data:
    File_Info = h5info(fileName);
    if(strcmp(File_Info.Datasets(1).Name,'blob_features')) % A hack to identify the new Tierpsy format (featuresN.hdf5).
        
		featData = h5read(fileName,'/features_means');
        Smoothed_Skeletons = h5read(fileName,'/coordinates/skeletons');
        
        Time_Series = h5read(fileName,'/timeseries_data');
        Time_Series = Time_Series.timestamp;
    
	elseif(strcmp(File_Info.Datasets(1).Name,'features_means')) % A hack to identify the old Tierpsy format (features.hdf5).
		featData = h5read(fileName,'/features_means');
        Smoothed_Skeletons = h5read(fileName,'/coordinates/skeletons'); % More under coordinates: dorsal_contours,ventral_contours,widths.
        
        Time_Series = h5read(fileName,'/features_timeseries');
        Time_Series = Time_Series.timestamp;
    else
        warning('Input file cannot be read. Possibly empty.');
        featMat = [];
        wormInds = [];
        featNames = [];
        return;
    end
    
    % get worm indices
    % wormInds = featData.worm_index;

    % get trajectory lengths (in frames)
    trajLengths = featData.n_frames;
    
    % get feature names
    featNames = fieldnames(featData);
    featNames(1:4) = []; % drop metadata fields
    
    % check featFlag length
    if size(featNames,1) ~= length(featFlag)
        error('featFlag must have the same length as number of features.');
    end
    
    % drop unused feature names
    featNames = featNames(featFlag);

    % convert to cell, dropping metadata entries at start
    featCell = struct2cell(featData);
    featCell(1:4) = [];

    % loop through features to reshape into numTrajectories x numFeatures
    % matrix
    keepInds = find(featFlag);
    featMat = NaN(size(featCell{1}, 1), numel(keepInds));
    for ii = 1:numel(keepInds)
        featMat(:, ii) = featCell{keepInds(ii)};
    end

    % drop short trajectories
    featMat = featMat(trajLengths > minLength,:);

    % Generate a time-series features struct:
    Time_Series_Features = h5read(fileName,'/features_timeseries');
	
    if(isempty(Chosen_Worms_Indices))
        Worms_Indices = featData.worm_index;
    else
        Worms_Indices = Chosen_Worms_Indices;
    end
    
    Feature_Names = fieldnames(Time_Series_Features);
    Fields_Num = numel(Feature_Names);
    % Time_Series_Features_Mat = zeros(length(Worms_Indices),Fields_Num,0); % Initiate a 3D feature matrix. Rows are objects (worms), columns are features, depth is time (frames).
    Time_Series_Features_Struct = struct();
    for i=1:length(Worms_Indices) % For each object.
        f1 = find([Time_Series_Features.worm_index] == Worms_Indices(i)); % An ordered (in time) list of row numbers.
        for j=1:Fields_Num % For each field.
            % Time_Series_Features_Mat(i,j,) = ;
            Time_Series_Features_Struct(i).(Feature_Names{j}) = Time_Series_Features(1).(Feature_Names{j})(f1);
        end
        Time_Series_Features_Struct(i).worm_index = unique([Time_Series_Features_Struct(i).worm_index]);
    end
    
    % assignin('base','Time_Series_Features',Time_Series_Features);
    % assignin('base','Time_Series_Features_Struct',Time_Series_Features_Struct);
end