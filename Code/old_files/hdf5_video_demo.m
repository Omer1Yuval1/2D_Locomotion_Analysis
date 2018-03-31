% This script first loads frames from a single-worm tracker video created 
% using WormTracker 2.0 that has been analysed using Tierpsy Tracker and 
% saved as a masked video in hdf5 format.  Using the stage motion data
% saved by the tracker, the script then does an approximate reconstruction
% of the worm's motion on the plate and displays a video.

% set the file name
fileName = ['./sample_single-worm_hdf5_videos/' ...
    'N2 on food L_2010_04_08__11_25_23___8___1.hdf5'];

% how many frames should be plotted?
startFrame = 1;
frameInterval = 10; % only plot every frameInterval'th frame in movie
frameNum = 2500; % max number of frames to plot
ds = 2; % pixel downsample factor for movie

% should a grid be plotted over the movie
plotGrid = true;

% get the dimensions of the video
fileInfo = h5info(fileName);
dims = fileInfo.Datasets(3).Dataspace.Size;

% load the stage position coordinates to convert video frames to lab
% coordinates
stageCoords = h5read(fileName, '/stage_position_pix');

% during actual stage motions, stageCoords is NaN. Get approximation by
% linearly interpolating over x and y

% interpolate over NaN values
xy = stageCoords;
for ii = 1:size(stageCoords, 1)
    pAmp = stageCoords(ii, :);
    pAmp(isnan(pAmp)) = interp1(find(~isnan(pAmp)),...
        pAmp(~isnan(pAmp)), find(isnan(pAmp)),'linear', 'extrap');
    xy(ii, :) = pAmp;
end

minX = min(xy(1, startFrame:startFrame + frameNum - 1));
maxX = max(xy(1, startFrame:startFrame + frameNum - 1));

minY = min(xy(2, startFrame:startFrame + frameNum - 1));
maxY = max(xy(2, startFrame:startFrame + frameNum - 1));

xRange = round(abs(minX - maxX));
yRange = round(abs(minY - maxY));


% shift xy to fit in window of interest
xy(1, :) = xy(1, :) - minX;
xy(2, :) = xy(2, :) - minY;


for ii = startFrame:frameInterval:startFrame + frameNum - 1
    % load a frame
    frameI = ...
        h5read(fileName, '/mask', [1, 1, ii], [dims(1), dims(2), 1]);
    
    J = padarray(frameI, [round(xy(1, ii)), round(xy(2, ii))], 0, 'pre');
    J = padarray(J, [xRange - round(xy(1, ii)), yRange - round(xy(2, ii))], 0, 'post');
    
    if plotGrid
        J(1:round(size(J, 1)/10):end, 1:round(size(J, 1)/10):end) = 255;
    end
    
    imshow(J(1:ds:end, 1:ds:end), [])
    axis equal
    getframe;
end
hold off
