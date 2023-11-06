%% Script Header 
%*********************************************
%Defintion: This script takes in the c270 calibration data and uses it to
%detect all of the coins in an image as well as deploying various image
%processing methods.
%PreCondtions: This script cannot be executed before the c270Calibration
%function.
%Outputs: XY coordinates in meters of coin centers, number of each coin,
%and total value in USD.
%*********************************************
    %% Image Pre Processing
    BEV = transformImage(birdsEye,coinsI);
    TopLeftPixelX = 381;%612;
    TopLeftPixelY = 0;%277;
    cropWidth = size(BEV,2)-TopLeftPixelX;%396;
    cropHeight = 720;%325;
    %Perform Cropping
    if(0)
        BEVc = imcrop(BEV,[138 16 454 446]);
    else
        %BEVc = imcrop(BEV,[455 180 768 478]);
        BEVc = imcrop(BEV,[TopLeftPixelX TopLeftPixelY cropWidth cropHeight]);
        %BEVc = imcrop(BEV,[450 0 820 720]);
    end
    %Color space analysis
    Im = BEV;

    rmat = Im(:,:,1); % matrix of R pixel values 0-255
    gmat = Im(:,:,2); % matrix of G pixel values 0-255
    bmat = Im(:,:,3); % matrix of B pixel values 0-255

    %Plot RGB matricies
    figure;
    subplot(2,2,1), imshow(rmat);
    title('Red Plane');
    subplot(2,2,2), imshow(gmat);
    title('Green Plane');
    subplot(2,2,3), imshow(bmat);
    title('Blue Plane');
    subplot(2,2,4), imshow(Im);
    title('Original Image');

    threshR = 0.3;
    threshG = 0.3;
    threshB = 0.3;
    %i1 = im2bw(rmat,threshR);
    %i2 = im2bw(gmat,threshG);
    %i3 = im2bw(bmat,threshB);
    i1 = imbinarize(rmat,threshR);
    i2 = imbinarize(gmat,threshG);
    i3 = imbinarize(bmat,threshB);
    
    Isum = (i1&i2&i3); % sums up all binary images

    %Plot of color data
    figure;
    subplot(2,2,1), imshow(i1);
    title('Red Plane');
    subplot(2,2,2), imshow(i1);
    title('Green Plane');
    subplot(2,2,3), imshow(i1);
    title('Blue Plane');
    subplot(2,2,4), imshow(i1);
    title('Sum of all Planes');
    %%
    %figure
    %imshow(Isum);
    BW = Isum;
    CC = bwconncomp(Isum);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [biggest,idx] = max(numPixels);
    BW(CC.PixelIdxList{idx}) = 0;
    figure
    imshow(BW);
    %hold on;
    %% Feature analysis 
    Ifilled = imfill(BW, 'holes');
    %figure, 
    imshow(Ifilled);
    title('Filled Image');
    
    
    % Extract features
    Iregion = regionprops(Ifilled, 'Centroid');
    [labeled] = bwlabel(Ifilled,4);
    stats = regionprops(labeled,'Eccentricity', 'Area', 'BoundingBox', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
    areas = [stats.Area];
    eccentricities = [stats.Eccentricity];

    %se = strel('disk', 6);
    %Iopenned = imopen(Ifilled,se);
    %imshowpair(Iopenned, Ifilled);
    %figure;
    %imshow(Iopenned);
    
    %closeBW = imclose(Iopenned,se);
    %figure, imshow(closeBW)

    idxOfObjects = find(eccentricities);
    statsDefects = stats(idxOfObjects);

   
%%
    %imArr = zeros(size(BEVc));
    %figure; imshow(BEVc);
    figure; imshow(BEV);
    hold on;
    
    rectangleValues = zeros(length(idxOfObjects),4);
    threshSizeInPixelsHi = 50;
    threshSizeInPixelsLo = 20;
    %Filter height and width values by the threshold height/width in pixels
        for idx = 1 : length(idxOfObjects)
            if( ((statsDefects(idx).BoundingBox(3) < threshSizeInPixelsHi) && (statsDefects(idx).BoundingBox(4) < threshSizeInPixelsHi)) && (statsDefects(idx).BoundingBox(3) > threshSizeInPixelsLo) && (statsDefects(idx).BoundingBox(4) > threshSizeInPixelsLo) )
                rectangleValues(idx,:) = statsDefects(idx).BoundingBox;
            else
                %Assign the value of -1 to all rows that need to be deleted
                rectangleValues(idx,:) = -1;
            end
        end
        %Create a logical array
        idx = (rectangleValues == -1);
        %use "find" to find where logical index is 1
        [delRows, ~] = find(idx);
        %Delete Rows
        rectangleValues(delRows,:) = [];
        
    numObjects = length(rectangleValues);
    meanRGB = zeros(numObjects,4);
    %DO THIS LATER ITS WAY FASTER TO PREALLOCATE STRUCTS
    %coinStruct = struct('meanRGB', cell(numObjects, 4), 'boundingBox', cell(numObjects, 10));
    %Crop boxes around coins
    for idx = 1 : numObjects

            h = rectangle('Position',statsDefects(idx).BoundingBox,'LineWidth',2);
            set(h,'EdgeColor',[0 1 0]);
            hold on;
            %First method to calculate radii and diameter of coins

            imCurr = imcrop(BEV,rectangleValues(idx:idx,1:4));
            imCurrR = imCurr(:,:,1);
            imCurrG = imCurr(:,:,2);
            imCurrB = imCurr(:,:,3);
            meanR = mean(mean(imCurrR));
            meanG = mean(mean(imCurrG));
            meanB = mean(mean(imCurrB));
            meanRGB(idx,1) = meanR;
            meanRGB(idx,2) = meanG;
            meanRGB(idx,3) = meanG;
            if (meanRGB(idx,1) > meanRGB(idx,2) && meanRGB(idx,1) > meanRGB(idx,3))
                meanRGB(idx,4) = 1;
            elseif (meanRGB(idx,2) > meanRGB(idx,1) && meanRGB(idx,2) > meanRGB(idx,3))
                meanRGB(idx,4) = 2;
                else
                meanRGB(idx,4) = 3;
            end
            coinStruct(idx).meanRGB = meanRGB(idx,:);
            coinStruct(idx).boundingBox = rectangleValues(idx:idx,:);
            coinStruct(idx).centers.morph = stats(idx).Centroid;
            coinStruct(idx).diameters.morph = mean([stats(idx).MajorAxisLength stats(idx).MinorAxisLength],2);
            coinStruct(idx).radii.morph = coinStruct(idx).diameters.morph/2;
            coinStruct(idx).eccentricity = stats(idx).Eccentricity;
            coinStruct(idx).area = stats(idx).Area;
            coinStruct(idx).coinIdx = idx;
            %subplot(2,length(idxOfObjects)/2,idx), imshow(imCurr);
            hold on;
    end
    if idx > 10
    title(['There are ', num2str(numObjects), ' objects in the image!']);
    end
    hold off;


    %se = strel('disk', 8);
    %Iopenned = imopen(Isum, se);
    %imshow(Iopenned);
    %title('Disk Morphologically Modified Image');

    %coinsIgrey = rgb2gray(BEVc);
    %BW_in = im2bw(coinsI);
    %imshow(coinsI);
    %figure;
    %imshow(coinsIgrey);
    %figure;
    %IHC = histeq(coinsIgrey);
    %imshow(IHC);
    %figure;
    %BW_in = im2bw(coinsIgrey);
    %BW_in = imfill(BW_in,'holes');
    %imshow(BW_in);
    %% Pixel coordinates to real world distance
    %In the bird's-eye-view image, place a meter marker directly in front of the sensor. Use the vehicleToImage function to specify the location of the marker in vehicle coordinates. Display the marker on the bird's-eye-view image.
    %The code below puts the desired marker points into a format that can be
    %used by the insertMarker Function
    horizInterval = 0.05;
    invertCount = 0;
    NumPoints = 5;
    imagePointCellMat = zeros(2*NumPoints^2,2);
    distanceVal = zeros(1,2*(NumPoints^2));
    startingMarkerDistance = .05;
    markerDistanceInterval = 1/16;
    for h = 1:2
        for k = 1:NumPoints
            for i = 1:NumPoints
                if (h == 2 && invertCount == 0)
                    horizInterval = horizInterval * (-1);
                    invertCount = invertCount+1;
                end
                % The rows term of the VehicleToImage 2nd Parameter always
                % needs to equal the distanceVal to reflect accurate
                % measurements!
                tempPos = vehicleToImage(birdsEye,[startingMarkerDistance+(i*markerDistanceInterval) horizInterval*(k-1)]);
                distanceVal(1,(i+NumPoints*(k-1)+(h-1)*NumPoints^2)) = startingMarkerDistance+(i*markerDistanceInterval);
                for j = 1:2
                    imagePointCellMat((i+NumPoints*(k-1)+(h-1)*NumPoints^2),j) = tempPos(1,j);
                end
            end
        end
    end
    %imagePoint = vehicleToImage(birdsEye,[0.5 0]);
    %imagePoint2 = vehicleToImage(birdsEye,[1 0]);
    annotatedBEV = insertMarker(BEV, imagePointCellMat);
    %annotatedBEV = insertMarker(BEV, imagePoint2);
    annotatedBEV = insertText(annotatedBEV, imagePointCellMat + 5, distanceVal);
    %annotatedBEV = insertText(annotatedBEV, imagePoint2 + 5, '1 meters');
    figure
    imshow(annotatedBEV);
    title('Birds''s-EyeView Image: vehicleToImage');
    % Cropped image Image to World Distance
    %OriginalPixelDistanceVals = croppedPixelDistanceValues + TopLeftPixelValues
    %% Coin Recognition
    %figure;
    calibrationResoltuion = "HD";
    imshow(BEV);
    [centers,radii] = imfindcircles(Ifilled,[8 100]); 
    numCoins = size(radii,1);
    %[dimeCenters, dimeRadii] = imfindcircles(BW_in, [50,64]);
    %[pennyCenters, pennyRadii] = imfindcircles(BW_in, [65,70]);
    %[nickleCenters, nickleRadii] = imfindcircles(BW_in, [70,79]);
    %[quarterCenters, quarterRadii] = imfindcircles(BW_in, [80,85]);
    
    dimeCircles = zeros(numCoins,3);
    pennyCircles = zeros(numCoins,3);
    nickleCircles = zeros(numCoins,3);
    quarterCircles = zeros(numCoins,3);
    
    dimeCenters = zeros(numCoins,2);
    pennyCenters = zeros(numCoins,2);
    dimeOrPennyCenters = zeros(numCoins,2);
    nickleCenters = zeros(numCoins,2);
    quarterCenters = zeros(numCoins,2);
    dimeRadii = zeros(numCoins,1);
    pennyRadii = zeros(numCoins,1);
    dimeOrPennyRadii = zeros(numCoins,1);
    nickleRadii = zeros(numCoins,1);
    quarterRadii = zeros(numCoins,1);
    dimeCount = 0;
    pennyCount = 0;
    dimeOrPennyCount = 0;
    nickleCount = 0;
    quarterCount = 0;

    %convert center x y pixel values from cropped to image to original image
    %centersBEV = zeros(length(centers),2);
    %for i=1:length(centers)
    %    centersBEV(i,1) = (centers(i,1) + TopLeftPixelX);
    %    centersBEV(i,2) = (centers(i,1) + TopLeftPixelY);
    %end
    
    annotatedBEV = insertMarker(BEV, centers);
    %for i = 1:numCoins
    %    annotatedBEV = insertText(annotatedBEV,worldDistanceOnImage + 5, ("Xpos in m:" + num2str(WorldCoordinateMat(i,2)) + newline + "Ypos in m:" + num2str(WorldCoordinateMat(i,1))));
    %end
    %figure;
    imshow(annotatedBEV);
    dimeRadiiThreshHD = 12.7;% 14.5 Commented Values used from edge detection
    pennyRadiiThreshHD = 13.5;% 16.5
    nickleRadiiThreshHD = 15.5;% 18
    dimeOrPennyRadiiThreshHD = 13.5;
    
    dimmeOrPennyRadiiThreshLD = 11;
    nickleRadiiThreshLD = 12;
    %***********************************************************
    circles = [centers, radii];
    circles = sortrows(circles,1); %Now the circles are displayed Left to Right (x = 0 to x = x1)
    
    WorldCoordinateMat = imageToVehicle(birdsEye,circles(:,1:2)); %Real world distance values
    worldDistanceOnImage = vehicleToImage(birdsEye,WorldCoordinateMat);
    for i = 1:numCoins
        coinStruct(i).circles.imfind = circles(i,:);
        coinStruct(i).centers.imfind = centers(i,:);
        coinStruct(i).radii.imfind = coinStruct(i).circles.imfind(3);
    end
    %***********************************************************
    %This code looks at all bounding boxes if needed
              %for j = 1:numCoins
                    %if((dimeOrPennyCenters(k,1) >= (rectangleValues(j,1) + rectangleValues(j,3))) && (dimeOrPennyCenters(k,2) >= (rectangleValues(j,2)+ rectangleValues(j,4))) )
              %      if((dimeOrPennyCenters(k,1) <= (coinStruct(j).boundingBox(1) + coinStruct(j).boundingBox(3))) && (dimeOrPennyCenters(k,2) <= (coinStruct(j).boundingBox(2) + coinStruct(j).boundingBox(4))) )
              %          %The coin center values are inside of the bounding box
              %              if( coinStruct(j).meanRGB(j,4) == 1) %&& (coinStruct(j).meanRGB(1) > coinsStruct(j).meanRGB(3)) )
              %                  coinStruct(j).coinType = "Penny";
              %              else
              %                  coinStruct(j).coinType = "Dime";
              %              end
              %              break;
              %      end
              % end


    %***********************************************************
    % This section sorts the coins by radii size
    % Sometimes confuses dimes with pennies
    if strcmp(calibrationResolution,"LD")   
        for k=1:numCoins
           if (coinStruct(k).radii.imfind < dimeOrPennyRadiiThreshLD)
                %dimeOrPennyCenters(k,:) = coinStruct(k).centers.imfind;
                %dimeOrPennyRadii(k) = coinStruct(k).radii.imfind;
                 if( coinStruct(k).meanRGB(4) == 1)
                    coinStruct(k).coinType = "Penny";
                    pennyCircles(k,:) = coinStruct(k).circles.imfind;
                    pennyCount = pennyCount + 1;
                 else
                    coinStruct(k).coinType = "Dime";
                    dimeCircles(k,:) = coinStruct(k).circles.imfind;
                    dimeCount = dimeCount + 1;
                 end   
           elseif ((coinStruct(k).radii.imfind > dimeOrPennyRadiiThreshLD) && (coinStruct(k).radii.imfind < nickleRadiiThreshLD))
                coinStruct(k).coinType = "Nickel";
                nickleCircles(k,:) = coinStruct(k).circles.imfind;
                nickleCount = nickleCount+1;
           else
                coinStruct(k).coinType = "Quarter";
                quarterCircles(k,:) = coinStruct(k).circles.imfind;
                quarterCount = quarterCount+1;
           end
        end 
    else
         for k=1:numCoins
           if (coinStruct(k).radii.imfind < dimeOrPennyRadiiThreshHD)
                %dimeOrPennyCenters(k,:) = coinStruct(k).centers.imfind;
                %dimeOrPennyRadii(k) = coinStruct(k).radii.imfind;
                 if( coinStruct(k).meanRGB(4) == 1)
                    coinStruct(k).coinType = "Penny";
                    pennyCircles(k,:) = coinStruct(k).circles.imfind;
                    pennyCount = pennyCount + 1;
                 else
                    coinStruct(k).coinType = "Dime";
                    dimeCircles(k,:) = coinStruct(k).circles.imfind;
                    dimeCount = dimeCount + 1;
                 end   
           elseif ((coinStruct(k).radii.imfind > dimeOrPennyRadiiThreshHD) && (coinStruct(k).radii.imfind < nickleRadiiThreshHD))
                coinStruct(k).coinType = "Nickel";
                nickleCircles(k,:) = coinStruct(k).circles.imfind;
                nickleCount = nickleCount+1;
           else
                coinStruct(k).coinType = "Quarter";
                quarterCircles(k,:) = coinStruct(k).circles.imfind;
                quarterCount = quarterCount+1;
           end
         end
    end
    viscircles(dimeCircles(:,1:2),dimeCircles(:,3), 'EdgeColor','b');
    viscircles(pennyCircles(:,1:2),pennyCircles(:,3), 'EdgeColor','r');
    viscircles(nickleCircles(:,1:2),nickleCircles(:,3), 'EdgeColor','g');
    viscircles(quarterCircles(:,1:2),quarterCircles(:,3), 'EdgeColor','c');
    
    totalUSD = 0.25*quarterCount + 0.05*nickleCount + 0.1*dimeCount + 0.01*pennyCount;
    coinMat = [totalUSD quarterCount dimeCount nickleCount pennyCount];
     
    promptMessage = sprintf('Do you want to save the coin values into csv files?');
        button = questdlg(promptMessage, 'Save coin values?', 'Yes', 'No', 'Yes');
        if strcmp(button, 'Yes')
            csvwrite('coinYXCoordinates.csv',WorldCoordinateMat);
            csvwrite('coinVals.csv',coinMat);
        end