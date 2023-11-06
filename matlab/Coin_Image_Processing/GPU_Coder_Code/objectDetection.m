%#codegen

%% Function Header
%************************************************************************
%Function: objectDetection
%Parameters: None
%Outputs: Performs object detection on the jetson nano after codgen
%function is run.
function objectDetection()
%defines the hwobj as well as the camObj and dispObj, these only need to be
%done once.
hwobj = jetson;
camObj = camera(hwobj,"UVC Camera (046d:0825)",[640 480]);
dispObj = imageDisplay(hwobj);
%Define constants for the function as well as loading in compile time
%constants
threshR = 0.3;
%test = coder.load('test.mat','test');
%open the g code file which we will be writing commands to


%FIND A FUNCTION THAT IS EQUIVILANT TO EXIST THAT CAN BE GENERATED
%if ~exist('straight_line.g','file')
            %w+ enables read/write authority and makes a new file if one
            %doesnt exist.
%        	fileID = fopen('gcodeTest.g','w+','UTF-8');
%else
%            fileID = fopen('gcodeTest.g','r+','n','UTF-8');
%end
%% Live Image Processing

%This loop controls the image processing of each frame.
for k = 1:500
    % Capture the image from the camera on hardware.
    img = snapshot(camObj);
    
    frameBEV = img;
    %frameBEV = transformImage(birdsEye,img);
    
    %Extract RGB matricies from frame
    frameR = frameBEV(:,:,1);
    frameG = frameBEV(:,:,2);
    frameB = frameBEV(:,:,3);
    
    %Convert RGB mats to BW images
    f1 = imbinarize(frameR,threshR);
    f2 = imbinarize(frameG,threshR);
    f3 = imbinarize(frameB,threshR);
    
    %Sum of all BW images
    frameSum = (f1&f2&f3);
    %Removes all patches of pixels less than 150 W
    frameSumCleaned = bwareaopen(frameSum, 150);
    %**********************************************************************
    %% Perform Morphological Operations
    [labeled, frameNumObjects] = bwlabel(frameSumCleaned,4);
    %frameStats = struct('Eccentricity',zeros(frameNumObjects,1),'Area',zeros(frameNumObjects,1),'BoundingBox',zeros(frameNumObjects,1), 'Centroid',zeros(frameNumObjects,1), 'MajorAxisLength', zeros(frameNumObjects,1),'MinorAxisLength',zeros(frameNumObjects,1));
    frameStats = regionprops(labeled,'Eccentricity', 'Area', 'BoundingBox', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
    %preallocate memory for object data arrays
    frameEccentricities = zeros(frameNumObjects,1);
    %coder.varsize bounds the variables
    coder.varsize('frameRectangleValues',[300 4]);
    coder.varsize('frameCenters', [300 2]);
    coder.varsize('radii',[300,1]);
    %coder.varsize('frameRect', [480 640 3]);
    for j = 1:frameNumObjects
        frameEccentricities(j,1) = [frameStats(j).Eccentricity];
    end
    %Finds the index of Non zero eccentricities
    idxOfObjects = find(frameEccentricities);
    frameNonZeroStats = frameStats(idxOfObjects);
    %************************************************
    %% Object Size Filtering
     frameRectangleValues = zeros(length(idxOfObjects),4);
     frameCenters = zeros(length(idxOfObjects),2);
     idxOfSizeBoundedObjects = zeros(length(idxOfObjects),1);
     frameQuarterBoxes = zeros(length(idxOfObjects),4);
     frameDimeBoxes = zeros(length(idxOfObjects),4);
        threshSizeInPixelsHi = 60;
        threshSizeInPixelsLo = 20;
        %Filter height and width values by the threshold height/width in pixels
        for idx = 1 : length(idxOfObjects)
            if( ((frameNonZeroStats(idx).BoundingBox(3) < threshSizeInPixelsHi) && (frameNonZeroStats(idx).BoundingBox(4) < threshSizeInPixelsHi)) && (frameNonZeroStats(idx).BoundingBox(3) > threshSizeInPixelsLo) && (frameNonZeroStats(idx).BoundingBox(4) > threshSizeInPixelsLo) )
                frameRectangleValues(idx,:) = frameNonZeroStats(idx).BoundingBox;
                frameCenters(idx,:) = frameNonZeroStats(idx).Centroid;
                idxOfSizeBoundedObjects(idx) = idx;
            else
                %Assign the value of -1 to all rows that need to be deleted
                frameRectangleValues(idx,:) = -1;
                frameCenters(idx,:) = -1;
                idxOfSizeBoundedObjects(idx) = -1;
            end
        end
        %Create a logical array
        idx = (frameRectangleValues == -1);
        idx2 = (frameCenters == -1);
        idx3 = (idxOfSizeBoundedObjects == -1);
        %use "find" to find where logical index is 1
        [delRows, ~] = find(idx);
        [delRows2, ~] = find(idx2);
        [delRows3, ~] = find(idx3);
        %Delete Rows
        
        frameRectangleValues(delRows,:) = [];
        frameCenters(delRows2,:) = [];
        idxOfSizeBoundedObjects(delRows3) = [];
  
        numObjects = length(frameRectangleValues);
        frameBoundedStats = frameNonZeroStats(idxOfSizeBoundedObjects);
    %**********************************************************************    
    %frameRectangleValues and meanR go from left to right of the image
    meanR = zeros(numObjects,1);
    radii = zeros(numObjects,1);
    %centers = zeros(numObjects,2);
    %radii = zeros(numObjects);
    for idx = 1:numObjects
        %This section finds pennies by cropping 
        frameCropped = imcrop(frameBEV,frameRectangleValues(idx:idx,1:4));
        frameCroppedR = frameCropped(:,:,1);
        meanR(idx) = mean(mean(frameCroppedR));
        radii(idx) = (length(frameCropped)/2);
        
        %Write x y centers of the coins to straight_line.g
        %Need to perform pixel to real world distance calculation
        
    end
    

    %mask = zeros(size(img));
    %circleROI = roipoly
    %bwActiveContour = activecontour(img, 
    %**********************************************************************
    frameSumCleaned = frameSumCleaned*255;
    %FrameSumCleaned is the binary white image with all objects of size
    %less than 150 pixels removed
    frameSumCleaned = uint8(frameSumCleaned);
    %Inserts bounding boxes into the image
    %% Perform Image Segmentation
    
    frameRect = insertMarker(frameBEV, frameCenters, 'Color', [255 0 0]);
    %frameRect = insertShape(frameRect, 'Rectangle', frameRectangleValues, 'Color', [0 255 0]);
    frameRect = insertShape(frameRect, 'FilledCircle', [frameCenters, radii], 'Color', [0 0 255], 'Opacity', 0.7);
    %********************************************************
    
    
    
    %********************************************************
    %Display BW image.
    %image(dispObj,frameSumCleaned);
    
    %Display RGB image
    %image(dispObj,img);
    
    %Display BoundingBoxes on RGB image
    image(dispObj,frameSumCleaned);
end
end