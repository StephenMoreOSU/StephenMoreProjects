%% Script Header
%******************************************************************
%Defintion: This script allows for the user to view different layers of
%image processing using an AVI file input.
%PreConditions: Calibrated camera intrinsics and extrinsics if using BEV
%Outputs: Processed frame by frame footage of inputted .avi file
%******************************************************************
%% AVI Input and Pre Processing Conditions

addpath('filesAVI');
%vidReader.path = 'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\filesAVI';
vidReader = VideoReader('c270Capture0003.avi');
vidReader.CurrentTime = 0;
promptMessage = sprintf('What kind of filtering do you want?');
button = questdlg(promptMessage, 'Save this filter?', '1', '2', '3', '3');
imageProcVar = 4;
saveFlag = 0;
%Threshold for coin to be considered a penny
Rthresh = 5;
if strcmp(button, '1')
    imageProcVar = 1;
elseif strcmp(button, '2')
    imageProcVar = 2;
elseif strcmp(button, '3')
    imageProcVar = 3;
end
% Estimate Optical Flow Using Farneback Method
promptMessage = sprintf('Do you want to save the filtered AVI file?');
button = questdlg(promptMessage, 'Save this filter?', 'Yes', 'No', 'Yes');
if strcmp(button, 'Yes')
    saveFlag = 1;
end
if(imageProcVar == 1)
    imageProcessingLayer = "Optical Flow";
elseif(imageProcVar == 2)
    imageProcessingLayer = "Edge Detection";
    if(saveFlag == 1)
        v = VideoWriter('edgeFilter.avi','Uncompressed AVI');
    end
elseif(imageProcVar == 3)
    imageProcessingLayer = "Object Detection";
    if(saveFlag == 1)
        v = VideoWriter('objFilter.avi','Uncompressed AVI');
    end
elseif(imageProcVar == 4)
    imageProcessingLayer = "Segmented BW Filtering";
    if(saveFlag == 1)
        v = VideoWriter('BWFilter.avi','Uncompressed AVI');
    end
end
if(saveFlag == 1)
    open(v);
end
BEVFlag = 1;
croppingFlag = 0;
% Cropping Parameters
%TopLeftPixelX = 381;
%TopLeftPixelY = 0;
%cropWidth = size(BEV,2)-TopLeftPixelX;
%cropHeight = 720;

if (imageProcessingLayer == "Optical Flow")
    flowFlag = 1;
    edgeFlag = 0;
    objFlag = 0;
    SUPERFLAG = 0;
    opticFlow = opticalFlowFarneback;
    h = figure;
    movegui(h);
    hViewPanel = uipanel(h, 'Title',sprintf('Plotted %s',imageProcessingLayer));
    hPlot = axes(hViewPanel);
elseif (imageProcessingLayer == "Edge Detection")
    edgeFlag = 1;
    flowFlag = 0;
    objFlag = 0; 
    SUPERFLAG = 0;
elseif (imageProcessingLayer == "Object Detection")
    objFlag = 1;
    flowFlag = 0;
    edgeFlag = 0;
    SUPERFLAG = 0;
    
    h = figure;
    movegui(h);
    hViewPanel = uipanel(h, 'Title',sprintf('Plotted %s',imageProcessingLayer));
    hPlot = axes(hViewPanel);
elseif (imageProcessingLayer == "Segmented BW Filtering")
    objFlag = 0;
    flowFlag = 0;
    edgeFlag = 0;
    SUPERFLAG = 1;
end

frameCounter = 0;
%BEGIN LOOPING THROUGH FRAMES
%% Frame by Frame Processing
while hasFrame(vidReader)
    %Read in RGB Frame
    frameRGB = readFrame(vidReader);
    frameGray = rgb2gray(frameRGB);  
    if(BEVFlag == 1)
        frameBEV = transformImage(birdsEye,frameRGB);
        frameGrayBEV = transformImage(birdsEye,frameGray);    
    end
    if(croppingFlag == 1)
       frameBEVc = imcrop(BEV,[TopLeftPixelX TopLeftPixelY cropWidth cropHeight]);
       frameGrayBEVc = rgb2gray(frameBEVc);
    end
    %% Optical Flow
    if(flowFlag == 1)
        if(croppingFlag == 1)
            flow = estimateFlow(opticFlow,frameGrayBEVc);
        else
            flow = estimateFlow(opticFlow,frameGrayBEV);
            imshow(frameBEV);
            hold on
            plot(flow,'DecimationFactor',[5 5],'ScaleFactor',2,'Parent',hPlot);
            hold off
        end
    end
    %% Edge Detection
    if(edgeFlag == 1)
        frameEdgeBEV = edge(frameGrayBEV,'sobel');
        imshow(frameEdgeBEV);
        title(sprintf('%s: Current Time = %.3f sec',imageProcessingLayer, vidReader.CurrentTime));
        hold on
        %writeVideo(v,frameEdgeBEV,'uint8');
    end
    %% Object Detection
    if(objFlag == 1)
        %Extract RGB matricies from frame
        frameR = frameBEV(:,:,1);
        frameG = frameBEV(:,:,2);
        frameB = frameBEV(:,:,3);
        %Threshold values for BW image
        threshR = 0.3;
        threshG = 0.3;
        threshB = 0.3;
        f1 = imbinarize(frameR,threshR);
        f2 = imbinarize(frameG,threshR);
        f3 = imbinarize(frameB,threshR);
        %Convert RGB image to BW image
        frameSum = (f1&f2&f3);
        %Convert BW image to BW image on black background
        frameOnBlack = frameSum;
        CC = bwconncomp(frameSum);
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [biggest,idx] = max(numPixels);
        frameOnBlack(CC.PixelIdxList{idx}) = 0;
        %Remove smaller white pixel areas in BW image
        frameSumCleaned = bwareaopen(frameOnBlack, 150);
        
        %se = strel('disk', 6);
        %frameOpenned = imopen(frameSumCleaned,se);
        %frameClosed = imerode(frameOpenned,strel('disk',1));
        
        
        frameRegion = regionprops(frameSumCleaned, 'Centroid');
        [labeled, frameNumObjects] = bwlabel(frameSumCleaned,4);
        
        frameStats = regionprops(labeled,'Eccentricity', 'Area', 'BoundingBox', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
        frameAreas = [frameStats.Area];
        frameEccentricities = [frameStats.Eccentricity];
        
        %Finds the index of Non zero eccentricities
        idxOfObjects = find(frameEccentricities);
        frameNonZeroStats = frameStats(idxOfObjects);
        
        frameRectangleValues = zeros(length(idxOfObjects),4);
        threshSizeInPixelsHi = 50;
        threshSizeInPixelsLo = 20;
        %Filter height and width values by the threshold height/width in pixels
        for idx = 1 : length(idxOfObjects)
            if( ((frameNonZeroStats(idx).BoundingBox(3) < threshSizeInPixelsHi) && (frameNonZeroStats(idx).BoundingBox(4) < threshSizeInPixelsHi)) && (frameNonZeroStats(idx).BoundingBox(3) > threshSizeInPixelsLo) && (frameNonZeroStats(idx).BoundingBox(4) > threshSizeInPixelsLo) )
                frameRectangleValues(idx,:) = frameNonZeroStats(idx).BoundingBox;
            else
                %Assign the value of -1 to all rows that need to be deleted
                frameRectangleValues(idx,:) = -1;
            end
        end
        %Create a logical array
        idx = (frameRectangleValues == -1);
        %use "find" to find where logical index is 1
        [delRows, ~] = find(idx);
        %Delete Rows
        frameRectangleValues(delRows,:) = [];
        
  
        numObjects = length(frameRectangleValues);
        %Color based processing loop
        
        %frameArrayCoinCrop = cell(1,numObjects);
        %The 10 in this loop means that this happens every 10 frames
        %if ~mod(frameCount,10)
        %    for k = 1:numObjects
        %        frameArrayCoinCrop(k) = {imcrop(frameBEV,frameRectangleValues(k,:))};
        %        frameCoinCrop = frameArrayCoinCrop{k};
        %        frameCoinCropR = frameCoinCrop(:,:,1);
        %        frameCoinCropG = frameCoinCrop(:,:,2);
        %        meanR = mean(mean(frameCoinCropR));
        %        meanG = mean(mean(frameCoinCropG));
        %        if meanR > (meanG + Rthresh)
        %            coinStruct(k).pennyFlag = 1;
        %        end
        %    end
        %end
        
        
        
        frameRectBEV = insertShape(frameBEV, 'Rectangle', frameRectangleValues, 'Color', 'g');
        imshow(frameRectBEV);
        hold on;
        if(saveFlag == 1)
            writeVideo(v,frameRectBEV);
        end
    end
    if (SUPERFLAG == 1)
        %*************************
        frameR = frameBEV(:,:,1);
        frameG = frameBEV(:,:,2);
        frameB = frameBEV(:,:,3);
        %Threshold values for BW image
        threshR = 0.3;
        threshG = 0.3;
        threshB = 0.3;
        f1 = imbinarize(frameR,threshR);
        f2 = imbinarize(frameG,threshR);
        f3 = imbinarize(frameB,threshR);
        %Convert RGB image to BW image
        frameSum = (f1&f2&f3);
        %Convert BW image to BW image on black background
        frameOnBlack = frameSum;
        CC = bwconncomp(frameSum);
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [biggest,idx] = max(numPixels);
        frameOnBlack(CC.PixelIdxList{idx}) = 0;
        %Remove smaller white pixel areas in BW image
        frameSumCleaned = bwareaopen(frameOnBlack, 150);
        imshow(frameSumCleaned);
        title(sprintf('%s: Current Time = %.3f sec',imageProcessingLayer, vidReader.CurrentTime));
        hold on;
        %************************
    end
    frameCounter = frameCounter + 1;
    pause(10^-4)
end
t = title("Video Processing Demo is Complete!");
hold on

