
%% Function Header
%**************************************************************************
%Defintion: % This takes 200 frames at 10fps from the c270 camera and saves the avi into
% diskLogger defined path into non volatile memory.
%Parameters: quality is a string input either "LD" or "HD" for 640x480 and
%1280x720 resolution respectively. vidFileName is the name of the file the
%user wants the video saved into.
%Output: Saved uncompressed .avi file with desired quality at desired
%file name.
%***************************************************************************
%% Image Acquisition
function c270Acquire(vidFileName, quality)

    if(quality == "LD")
        vid = videoinput('winvideo', 2, 'I420_1280x720');
    else
        vid = videoinput('winvideo', 2, 'I420_1280x720');
    end
    src = getselectedsource(vid); % src is not used however it is good for code flexibility and changes.
    vid.FramesPerTrigger = 200; %Frames per function call
    vid.ReturnedColorspace = 'rgb'; %Color space of .avi
    vid.LoggingMode = 'disk'; %Determines how the file is saved
    %writes video file to the filesAVI folder
    diskLogger = VideoWriter(['C:\Users\Stephen More\Documents\MATLAB\Jr Design FP\filesAVI\', sprintf('%s.avi',vidFileName)], 'Uncompressed AVI');
    vid.DiskLogger = diskLogger;
    %sets fps to 10
    diskLogger.FrameRate = 10;
    start(vid);

    stoppreview(vid);
    
end