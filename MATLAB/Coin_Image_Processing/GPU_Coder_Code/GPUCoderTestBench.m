%% Header
% Description: This is a test bench function to connect to, interact with, and generate C++/Cuda Code for Nvidia
% Jetson Nano Board
% Parameters: sudoFlag - if you want to sign in as root enter 1
% usbFlag - if you are sshing over usb c enter 1
% codegenFlag - if you want code to be generated enter 1
% matlabFileName - enter the name of the matlab file you wish to generate
% code for.
%% Test Bench
function GPUCoderTestBench(sudoFlag, usbFlag, codegenFlag, matlabFileName)
if (sudoFlag == 1)
    hwobj= jetson('10.0.0.207','root','root');
else
    if (usbFlag == 1)  
        hwobj= jetson('192.168.55.1','nvidia','nvidia');
    else
        hwobj= jetson('10.0.0.207','nvidia','nvidia');
    end
end
%Generation of CUDA Code using GPU Coder --------
%Create the config object for generating .exe
cfg = coder.gpuConfig('exe');
%Assign Hardware to config
cfg.Hardware = coder.hardware('NVIDIA Jetson');
%Specify Build Directory
cfg.Hardware.BuildDir = '~/remoteBuildDir';
%Generate example C++ code
cfg.GenerateExampleMain = 'GenerateCodeAndCompile';
if (codegenFlag == 1)
    codegen('-config ',cfg, matlabFileName,'-report');
end