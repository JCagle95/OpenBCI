function [ Sample_ID, EEG_Sample, AUX_Sample ] = OpenBCI_Streaming( BCI_Obj, Duration )
%Streaming Data from OpenBCI to MATLAB
%   Detailed explanation goes here
%   J. Cagle, University of Florida, 2017

% Check BCI Object
if ~isfield(BCI_Obj, 'isOpenBCI')
    error('OpenBCI Object Incorrect');
end

% Check BCI Serial Object
if ~strcmp(BCI_Obj.ser.Status,'open')
    error('OpenBCI Serial Object is closed. Please reconnect before configuration');
end

[b,a] = butter(5, 1*2/BCI_Obj.opt.Fs, 'high');

RecordingTime = Duration;
MaxRunTime = BCI_Obj.opt.Fs * 10;
XFrame = BCI_Obj.opt.Fs * 3;
nSample = 100;

BCI_Obj.lastIndex = 0;
BCI_Obj.CycleCounter = 0;

n = XFrame + 1 + nSample - rem(XFrame, nSample);
Sample_ID = zeros(1,MaxRunTime*2);
EEG_Sample = zeros(BCI_Obj.eeg_channels_per_sample,MaxRunTime*2);
AUX_Sample = zeros(BCI_Obj.aux_channels_per_sample,MaxRunTime*2);

largeFigure(100,[1280 900]); clf;

% Start Streaming
startTime = tic;
OpenBCI_Config(BCI_Obj, 'START');
while toc(startTime) < RecordingTime
    [sample, BCI_Obj] = OpenBCI_ReadBinary(BCI_Obj, nSample);
    Sample_ID(n:n+nSample-1) = sample.ID;
    EEG_Sample(:,n:n+nSample-1) = sample.EEG;
    AUX_Sample(:,n:n+nSample-1) = sample.AUX;
    n = n + nSample;
    if n > MaxRunTime * 2
        Sample_ID(:,1:MaxRunTime) = Sample_ID(:,MaxRunTime+1:end);
        EEG_Sample(:,1:MaxRunTime) = EEG_Sample(:,MaxRunTime+1:end);
        AUX_Sample(:,1:MaxRunTime) = AUX_Sample(:,MaxRunTime+1:end);
        n = MaxRunTime + 1;
    end
    plot(Sample_ID(:,n-XFrame:n-1), filtfilt(b,a,EEG_Sample(:,n-XFrame:n-1)'));
    xlim([Sample_ID([n-XFrame n-1])]);
    drawnow;
    disp(BCI_Obj.ser.BytesAvailable);
end
OpenBCI_Config(BCI_Obj, 'STOP');

end