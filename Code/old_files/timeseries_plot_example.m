function timeseries_plot_example(filename,trackNum,Feature_Name)
    % This script illustrates how to load time series features generated using
    % Tierpsy Tracker and generates some plots.
    % 
    % For information on how the results files used here can
    % be generated from video files, see the Tierpsy Tracker page here:
    % 
    % http://ver228.github.io/tierpsy-tracker/
    
    % -------------------------------------------------------------------------
    % --------------------Load file and examine contents-----------------------
    % -------------------------------------------------------------------------


    % choose a file to analyse
    % filename = fileName;
    % ['/Users/abrown/Andre/code/tierpsy_tools/sample_multiworm_results/' ...
    %    'N2_worms5_food1-10_Set1_Pos4_Ch5_02062017_115615_features.hdf5'];

    % get the HDF5 file info and display the top level dataset names. You can
    % use h5disp(fileInfo) to display all the contents but it's very verbose.
    % It's easier to understand the structure by double-clicking fileInfo in
    % the workspace and browsing the contents.
    fileInfo = h5info(filename);
    disp({fileInfo.Datasets.Name}')

    % load feature data
    featTS = h5read(filename, '/features_timeseries');
    assignin('base','featTS',featTS);
    % we also want to get the frame rate and confirm that the xy units have
    % been converted from pixels to microns. These are included in the HDF5
    % file's attributes.  Other useful attributes are microns_per_pixel, 
    % time_units, and is_light_background.
    fps = h5readatt(filename, '/features_timeseries', 'fps');
    disp(h5readatt(filename, '/features_timeseries', 'xy_units'));


    % featTS is a struct with multiple fields for the different features
    % calculated by Tierpsy Tracker.  Each field is a long vector that includes
    % the feature values for each tracked object from the video.  For
    % single-worm data generated using WormTracker 2.0, there should be only a
    % single worm index.  For multiworm data, there will be a different unique
    % index for each object.
    wormInds = featTS.worm_index;

    % get the unique indices
    uniqueInds = unique(wormInds);
    disp(['This file has ' num2str(numel(uniqueInds)) ' tracks.'])


    % -------------------------------------------------------------------------
    % -------------------------Make a simple plot------------------------------
    % -------------------------------------------------------------------------


    % plot the speed over time calculated for one of the tracks
    % trackNum = 1; % change to plot a different track
    currentInds = wormInds == uniqueInds(trackNum);
    figure
    % plot(featTS.timestamp(currentInds) / fps, featTS.(Feature_Name)(currentInds));
    plot(featTS.timestamp(currentInds) / fps, abs(featTS.(Feature_Name)(currentInds)),'.');
    set(gca, 'FontSize', 18);
    xlabel('Time (s)');
    ylabel(Feature_Name);



    % -------------------------------------------------------------------------
    % -----------------Multi-track plot with plate average---------------------
    % -------------------------------------------------------------------------


    % To make a plot of a feature over time averaged over all of the tracked
    % objects, we need to calculate the average at each time point.  Because
    % the features are stored in long indexed vectors there is not direct way
    % to do it.  Here are four ways to do it with different advantages and
    % disadvantages.

    % OPTION 1 - USE STATS TOOLBOX, IF YOU HAVE IT
    % this option is intuitive and is easy to adapt to calculating different
    % statistics or to calculate the statistics across tracks instead of across
    % time.  It's middle of the road in terms of speed.
    featMean1 = grpstats(featTS.(Feature_Name), featTS.timestamp, 'mean');



    % OPTION 2 - INITIALISE A BIG MATRIX OF NANS AND USE NANMEAN
    % for the example file I used (small number of worms fairly long tracks)
    % this is the fastest option (~10x faster than option 1 on the example I 
    % tried.  The tradeoff is that it will be very memory inefficient if you 
    % have a file with a large number of short tracks.

    % initialise matrix to hold feature values for each track
    featMat = NaN(numel(uniqueInds), max(featTS.timestamp) + 1);

    % loop through tracks and add them to the appropriate position in the
    % feature matrix
    for ii = 1:numel(uniqueInds)
        % get indices for current track
        currentInds = find(wormInds == uniqueInds(ii));

        % add the features to featMat at the right time point. N.B. Timestamps
        % are zero-indexed so add 1 for Matlab.
        startInd = featTS.timestamp(currentInds(1)) + 1;
        endInd = featTS.timestamp(currentInds(end)) + 1;
        featMat(ii, startInd:endInd) = featTS.(Feature_Name)(currentInds);
    end

    % get the average value of the feature over time
    featMean2 = nanmean(featMat);


    % OPTION 3 - USE A SPARSE MATRIX
    % This is the second fastest option and doesn't take much memory.  It's
    % probably the best of the four if you want to calculate the mean.  The
    % tradeoff is that it's more involved to adapt it to other statistics
    % and it isn't the most intuitive.

    % get the row index (one index per track) for sparse feature matrix
    [~, ~, rowInds] = unique(wormInds);

    % Replace zero feature values with a very small number. This is because
    % undeclared values in a sparse matrix are assumed to be zero and we need
    % to ignore them below when calculating the mean.
    featNoZeros = double(featTS.(Feature_Name));
    featNoZeros(featTS.(Feature_Name) == 0) = eps;

    % the column indices for the sparse feature matrix are the timestamps + 1
    % to convert from zero indexing.  Note that sparse doesn't work with
    % singles.
    featMatSparse = sparse(rowInds, double(featTS.timestamp + 1), featNoZeros);

    % calculate the mean value at each time in the sparse matrix, but note that
    % this version has included all the zero values implicit in the sparse
    % matrix.
    featMean3 = nanmean(featMatSparse);

    % get the number of non-zero and NaN elements in each column and use these
    % to correct the calculated mean values.
    numberNonZeros = sum(featMatSparse ~= 0);
    numberNaNs = sum(isnan(featMatSparse));

    featMean3 = featMean3 .* ...
        (size(featMatSparse, 1) - numberNaNs) ./ (numberNonZeros - numberNaNs);


    % OPTION 4 - USE A FOR LOOP OVER TIME POINTS

    % This is by far the slowest method (~200x slower than the fastest on my
    % test file), but it's straight forward and doesn't use a lot of memory.

    % initialise featMean
    featMean4 = NaN(1, max(featTS.timestamp) + 1);

    % loop over timestamps
    for ii = 1:max(featTS.timestamp) + 1
        % get entries for the current frame
        currentTimeInds = featTS.timestamp == ii-1; % -1 to shift to zero-indexing

        % get the mean for the current frame
        featMean4(ii) = nanmean(featTS.(Feature_Name)(logical(currentTimeInds)));
    end


    % finally, let's actually make the plot

    % for fun, let's smooth the feature mean
    featMeanSmooth = conv(featMean1, ones(51,1)/51, 'same');

    % plot the speed times series of each track
    figure
    for ii = 1:numel(uniqueInds)
        % get indices for current track
        currentInds = wormInds == uniqueInds(ii);

        % plot the track
        plot(featTS.timestamp(currentInds) / fps, ...
            featTS.(Feature_Name)(currentInds), 'Color', [0.7 0.7 0.7])
        hold on
    end

    % overlay the average feature
    plot((0:max(featTS.timestamp))' / fps, featMeanSmooth, ...
        'Color', 'r', 'LineWidth', 2)

    set(gca, 'FontSize', 18)
    xlabel('Time (s)')
    ylabel(Feature_Name)
    hold off

end
