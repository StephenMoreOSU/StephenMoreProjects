%% Function Header
%*************************************************
%Defintion: This function calibrates a logitech c270 Camera
%Parameters: quality is a string input either "LD" or "HD" for 640x480 and
%1280x720 resolution respectively.
%Output: pitch,height,camIntrinsics,calibrationResolution, imageSize,
%coinsI, all of these combined allow for a user to see which surface the
%camera is calibrated for, perform inverse perspective mapping, and map
%pixels to real world distances.
%*************************************************
%% c270 Camera Calibration
function [birdsEye, pitch, height, cameraParams, coinsI] = c270Calibrate(quality, distAheadi, spaceToOneSidei, bottomOffseti)
    
   
    HD = '1280x720';
    LD = '640x480';
    if(quality == "LD")
        calibrationResolution = LD;
    else
        calibrationResolution = HD;
    end
    % Define images to process
    imageFileNames640x480 = {
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\GPUImages\640x480GPUCheckerboard.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\WIN_20200122_16_38_58_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\WIN_20200122_16_39_09_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\WIN_20200122_16_39_14_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\WIN_20200122_16_39_27_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\WIN_20200122_16_39_32_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\WIN_20200122_16_39_40_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\WIN_20200122_16_39_54_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\WIN_20200122_16_40_04_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\WIN_20200122_16_40_30_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\WIN_20200122_16_40_51_Pro.jpg',...
        };
    %Put images which are of objects on the calibrated surface
    coinImageFileNames640x480 = {
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\GPUImages\640x480GPUCoinsImage_1.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\GPUImages\640x480GPUCoinsImage_1.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins1.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins2.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins3.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins4.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins5.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins6.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins7.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins8.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins9.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins10.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\CaliWCoins11.jpg',...
        };
    imageFileNames1280x720 = {'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_19_58_40_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_19_59_13_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_00_02_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_00_59_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_01_02_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_01_25_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_01_29_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_01_50_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_01_54_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_02_09_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_02_16_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_02_34_Pro.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\WIN_20200123_20_03_02_Pro.jpg',...
        };
    coinImageFileNames1280x720 = { 'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\coins1.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\coins2.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\coins3.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\coins4.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\coins5.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\coins6.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\coins7.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\coins8.jpg',...
        'C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\c270VideosandImages\CameraCaliCheckerBoard\1280x720\coins9.jpg',...
        };
    %% Compute Camera Intrinsic and Extrinsic Parameters
    
    % Display one of each calibration images to the user
    %640x480
    magnification = 25;
    I = imread(imageFileNames640x480{1});
    figure; imshow(I, 'InitialMagnification', magnification);
    title('640x480 Calibration Image');
    %1280x720
    IHD = imread(imageFileNames1280x720{3});
    figure; imshow(IHD, 'InitialMagnification', magnification);
    title('1280x720 Calibration Image');
    % Detect checkerboards in images
    if strcmp(calibrationResolution,LD)
        [imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames640x480);
        imageFileNames640x480 = imageFileNames640x480(imagesUsed);

        % Read the first image to obtain image size
        originalImage = imread(imageFileNames640x480{1});
        [mrows, ncols, ~] = size(originalImage);
    else
        [imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames640x480);
        imageFileNames1280x720 = imageFileNames1280x720(imagesUsed);

        % Read the first image to obtain image size
        originalImage = imread(imageFileNames1280x720{1});
        [mrows, ncols, ~] = size(originalImage);
    end


    % Generate world coordinates of the corners of the squares
    squareSize = 24;  % in units of 'millimeters'
    worldPoints = generateCheckerboardPoints(boardSize, squareSize);

    % Calibrate the camera, Images used and estimation errors are not used
    % but are useful to have for flexibility in code.
    [cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
        'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
        'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
        'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
        'ImageSize', [mrows, ncols]);

    %however is useful if you want to manually input intrinsic vals)
    camIntrinsics = cameraIntrinsics(cameraParams.Intrinsics.FocalLength,cameraParams.Intrinsics.PrincipalPoint,cameraParams.Intrinsics.ImageSize);
    % Now make sure the extrinsic Qualities are correct
    %Load an image with a checkerboard placed on ground for calibration
    %SET I TO THE IMAGE YOU NEED TO CALCULATE CAMERA EXTRINSICS FOR!
    if strcmp(calibrationResolution,LD)
        I = imread(imageFileNames640x480{1});
        coinsI = imread(coinImageFileNames640x480{1});
    else
        I = imread(imageFileNames1280x720{3});
        coinsI = imread(coinImageFileNames1280x720{3});
    end
    %This function returns the image points on cornerse of checkerboard
    [imagePoints,boardSize] = detectCheckerboardPoints(I);
    
    squareSize = 0.024; % Square size in meters
    %This function generates world distances from image points
    worldPoints = generateCheckerboardPoints(boardSize,squareSize);
    
    %set patternOriginHeight to 0 if checkerboard is on ground
    patternOriginHeight = 0;
    %I am using monocamera so I use the function to estimate its
    %parameters.
    [pitch,~,~,height] = estimateMonoCameraParameters(camIntrinsics,imagePoints,worldPoints,patternOriginHeight);
    %% Compute Birds Eye View Image and display to User to Verify Calibration
    %This allows the last 3 parameters to be optional inputs
    if (~exist('distAheadi','var') || ~exist('distAhead','var') || ~exist('distanceAheadi','var'))
        if strcmp(calibrationResolution,LD)
            distAhead = .6;%1
            spaceToOneSide = .3;
            bottomOffset = 0.15;
        else
            distAhead = 0.4; %.4
            spaceToOneSide = 0.5;%0.5;
            bottomOffset = 0;
        end
    else
        distAhead = distAheadi;
        spaceToOneSide = spaceToOneSidei;
        bottomOffset = bottomOffseti;
    end
    %Sets output view for inverse perspective mapping in meters
    outView = [bottomOffset,distAhead,-spaceToOneSide,spaceToOneSide];
    %Sets output view for inverse perspective mapping in pixels
    outImageSize = cameraParams.Intrinsics.ImageSize;
    
    sensor = monoCamera(camIntrinsics,height,'Pitch',pitch);
    birdsEye = birdsEyeView(sensor,outView,outImageSize);
    %Outputs a montage of RGB Birds Eye View images to the user to check
    %for accuracy
    BEV = transformImage(birdsEye,coinsI);
    multi = cat(3,coinsI,BEV);
    figure;
    montage(multi);
    return;