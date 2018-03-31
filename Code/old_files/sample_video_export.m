% Load frames from videos, overlay (optionally) outlines, skeletons, and
% head location, and save as new video.


% set image annotation type. If lineplot is true, worm outlines and
% skeletons are plotted as lines over the image which is then exported. The
% output resolution will be based on screen resolution.  This option makes
% it easier to change colours and the line widths of annotations. Skeletons
% are also plotted as smoothed lines.
% If lineplot is false, the worm outlines are annotated at the pixel level 
% and the image is exported at the original resolution.  This option 
% maintains resolution but is less flexible.
lineplot = false;

% set the directory name
directoryVid = 'D:\Work\Leeds\Movies\Tierpsy\20180328\MaskedVideos\';
filenameVid = 'Basler acA4024-29um (22602116)_20180328_105333684.hdf5';

directoryFeat = 'D:\Work\Leeds\Movies\Tierpsy\20180328\Results\';
filenameFeat = 'Basler acA4024-29um (22602116)_20180328_105333684_features.hdf5';

% get the dimensions of the video
fileInfo = h5info([directoryVid, filenameVid]);
dims = fileInfo.Datasets(3).Dataspace.Size;

% get the pixels to micron scale
muPerPix =  h5readatt([directoryVid, filenameVid], ...
    '/mask', 'microns_per_pixel');


% load the corresponding skeletons, dorsal contours, and ventral
% contours
skeletons = h5read([directoryFeat, filenameFeat], ...
    '/coordinates/skeletons');
dContour = h5read([directoryFeat, filenameFeat], ...
    '/coordinates/dorsal_contours');
vContour = h5read([directoryFeat, filenameFeat], ...
    '/coordinates/ventral_contours');

% get the timestamps
trajData = h5read([directoryFeat, filenameFeat],'/trajectories_data/');
timeStamps = trajData.frame_number + 1;
skelIds = trajData.skeleton_id + 1;

% list of frame indices to be exported
frameInds = 17450:17550; %2160:2180; %[844, 1274, 2244, 3694, 4694, 17484];

% initialise video
vidObj = VideoWriter([directoryVid strrep(filenameVid, '.hdf5', '') ...
    '_sample.mp4'], 'MPEG-4');
vidObj.Quality = 100;
open(vidObj);

% loop through frames
for ii = 1:numel(frameInds)    
    % load a frame
    frameI = ...
        h5read([directoryVid, filenameVid], ...
        '/mask', [1, 1, frameInds(ii)], [dims(1), dims(2), 1]);
    
    if lineplot
        % -----------------------------------------------------------------
        % Plot lines and export figure
        % -----------------------------------------------------------------
        
        % plot the frame
        imshow(frameI, [])
        hold on
        
        % get the skeleton indices with the current frame number
        rowIds = find(timeStamps == frameInds(ii));
        frameSkelIds = skelIds(rowIds);
        frameSkelIds = frameSkelIds(frameSkelIds>0);
        
        % loop through skeletons to plot
        for jj = 1:numel(frameSkelIds)
            % get the current skeleton and outline (add one to switch to 
            % Matlab indexing from zero indexing)
            skel = skeletons(:, :, frameSkelIds(jj)) / muPerPix + 1;
            vCont = vContour(:, :, frameSkelIds(jj)) / muPerPix + 1;
            dCont = dContour(:, :, frameSkelIds(jj)) / muPerPix + 1;
            
            plot(skel(2, :), skel(1, :), 'LineWidth', 1)
            plot(vCont(2, :), vCont(1, :), 'LineWidth', 1, 'Color', [0.9 0.6 0.3])
            plot(dCont(2, :), dCont(1, :), 'LineWidth', 1, 'Color', [0.9 0.6 0.3])
        end
        
        % add frame to video
        frame = getframe(gcf);
        writeVideo(vidObj, frame);
        
        hold off        
    else
        disp(ii/numel(frameInds))
        % -----------------------------------------------------------------
        % Change pixels at borders values and export image directly
        % -----------------------------------------------------------------
        
        % convert image to rgb
        frameRGB = cat(3, frameI, frameI, frameI);
        
        % get the skeleton indices with the current frame number
        rowIds = find(timeStamps == frameInds(ii));
        frameSkelIds = skelIds(rowIds);
        frameSkelIds = frameSkelIds(frameSkelIds>0);
        
        BW = false(dims(1), dims(2));
        
        for jj = 1:numel(frameSkelIds)
            % get the current outline (add one to switch to 
            % Matlab indexing from zero indexing)
            vCont = round(vContour(:, :, frameSkelIds(jj)) / muPerPix + 1);
            dCont = round(dContour(:, :, frameSkelIds(jj)) / muPerPix + 1);
            
            % some contour values are NaN (e.g. coiled worms)
            if isnan(vCont(1,1))
                continue
            end
            
            % make head a different colour
            frameRGB(vCont(1, 1), vCont(2, 1), 1) = 0;
            frameRGB(vCont(1, 1), vCont(2, 1), 2) = 255;
            frameRGB(vCont(1, 1), vCont(2, 1), 3) = 0;
            
            frameRGB(vCont(1, 1) + 1, vCont(2, 1), 1) = 0;
            frameRGB(vCont(1, 1) + 1, vCont(2, 1), 2) = 255;
            frameRGB(vCont(1, 1) + 1, vCont(2, 1), 3) = 0;
            
            frameRGB(vCont(1, 1), vCont(2, 1) + 1, 1) = 0;
            frameRGB(vCont(1, 1), vCont(2, 1) + 1, 2) = 255;
            frameRGB(vCont(1, 1), vCont(2, 1) + 1, 3) = 0;
            
            frameRGB(vCont(1, 1) - 1, vCont(2, 1), 1) = 0;
            frameRGB(vCont(1, 1) - 1, vCont(2, 1), 2) = 255;
            frameRGB(vCont(1, 1) - 1, vCont(2, 1), 3) = 0;
            
            frameRGB(vCont(1, 1), vCont(2, 1) - 1, 1) = 0;
            frameRGB(vCont(1, 1), vCont(2, 1) - 1, 2) = 255;
            frameRGB(vCont(1, 1), vCont(2, 1) - 1, 3) = 0;
            
            % convert outline to mask
            [~, ~, currentMask, xi, yi] = roipoly(frameI, ...
                [vCont(1, :), dCont(1, end:-1:1)], ...
                [vCont(2, :), dCont(2, end:-1:1)]);
            
            % update frame mask
            BW = BW | currentMask;
        end
        
        % trace the boundaries of all worms
        B = bwboundaries(BW);
        
        % colour pixels along boundaries
        for jj = 1:numel(B)
            % set RGB channels individually
            frameRGB(sub2ind([dims(1), dims(2), 3], ...
                B{jj}(:, 2), B{jj}(:, 1), ...
                1*ones(size(B{jj}(:, 2))))) = 240;
            frameRGB(sub2ind([dims(1), dims(2), 3], ...
                B{jj}(:, 2), B{jj}(:, 1), ...
                2*ones(size(B{jj}(:, 2))))) = 150;
            frameRGB(sub2ind([dims(1), dims(2), 3], ...
                B{jj}(:, 2), B{jj}(:, 1), ...
                3*ones(size(B{jj}(:, 2))))) = 40;            
        end
        
        % add frame to video
        writeVideo(vidObj, frameRGB);
    end
end

close(vidObj)
