function skeleton_plot_example(filename,trackInd)
    % This script illustrates how to load skeletons (midlines) generated using
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
    % ['/Users/abrown/Andre/code/tierpsy_tools/sample_multiworm_results/' ...
    %    'MY16_worms5_food1-10_Set9_Pos4_Ch5_19052017_161053_features.hdf5'];

    % get the HDF5 file info and display the group with the skeletons. You can
    % use h5disp(fileInfo) to display all the contents but it's very verbose.
    % It's easier to understand the structure by double-clicking fileInfo in
    % the workspace and browsing the contents.
    fileInfo = h5info(filename);
    disp({fileInfo.Groups.Name}')
    disp({fileInfo.Groups(1).Datasets.Name}')

    % load the skeleton data
    skeletons = h5read(filename, '/coordinates/skeletons');
    
    % we also need the worm indices so that we can tell which tracked object
    % the skeletons correspond to. See timeseries_plot_example.m for a more
    % detailed comment.
    featTS = h5read(filename, '/features_timeseries');
    wormInds = featTS.worm_index;

    % get the unique indices
    uniqueInds = unique(wormInds);

    % -------------------------------------------------------------------------
    % ------------------------Plot some worm tracks----------------------------
    % -------------------------------------------------------------------------



    % matlab default colours
    c = [     0    0.4470    0.7410;
         0.8500    0.3250    0.0980;
         0.9290    0.6940    0.1250;
         0.4940    0.1840    0.5560;
         0.4660    0.6740    0.1880;
         0.3010    0.7450    0.9330;
         0.6350    0.0780    0.1840];

    figure
    % plot each of the tracks on one plot
    for ii = 1:numel(uniqueInds)
        % get indices for current track
        currentInds = find(wormInds == uniqueInds(ii));

        % to avoid plotting too many skeletons, plot only every 10th time point
        currentInds = currentInds(1:1:end);

        % plot the skeletons of the current track
        plot(squeeze(skeletons(1, :, currentInds)), ...
            squeeze(skeletons(2, :, currentInds)), ...
            'Color', c(1 + mod(ii-1, 7), :))
        hold on
    end
    axis equal
    hold off



    % -------------------------------------------------------------------------
    % ---------------------Plot a body angle kymograph-------------------------
    % -------------------------------------------------------------------------


    % select a series of skeletons from a single track
    % trackInd = 2; % which track to plot
    skelX = squeeze(skeletons(1, :, wormInds == uniqueInds(trackInd)))';
    skelY = squeeze(skeletons(2, :, wormInds == uniqueInds(trackInd)))';


    % calculate the tangent angles and subtract the mean angle.  Following
    % Stephens et al. (2008) PLOS Comp Bio, this has similar information as the
    % skeleton curvature but doesn't involve a noisy derivative.

    % calculate the x and y differences
    dX = diff(skelX, 1, 2);
    dY = diff(skelY, 1, 2);

    % calculate tangent angles.  atan2 uses angles from -pi to pi
    angles = atan2(dY, dX);

    % need to deal with cases where angle changes discontinuously from -pi
    % to pi and pi to -pi.  
    angles = unwrap(angles, [],2);

    % rotate skeleton angles so that mean orientation is zero
    meanAngles = mean(angles,2);
    angles = angles - meanAngles(:, ones(1, size(skelX, 2) - 1));

    % % if you have Matlab version 2016a or later, you can do expansion of
    % % meanAngles implicitly:
    % angles = angles - mean(angles, 2);

    % plot the angle array as a kymogram
    figure
    imagesc(angles') % transpose so x-axis is time
    % colormap('cool')
    caxis([min(angles(:)), max(angles(:))] * 0.4) % adjust colour range
    % xlim([1, 1500])
    pbaspect([3 1 1])
    set(gca, 'FontSize', 18)
    xlabel('Frame Number')
    ylabel('Segment Number');
    % xlim([0,125]);
end

