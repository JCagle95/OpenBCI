function [ Data ] = OpenBCI_ReadData( varargin )
%Read the OpenBCI Data stored using Data Logging implemented in OpenBCI_GUI
%   Data = OpenBCI_ReadData;
%   Data = OpenBCI_ReadData(FullPath_FileName);
%
%       Data is a struct containing:
%           1. ID -> Sample ID as returned from OpenBCI Hardware
%           2. EEG -> EEG Data in 32-bit integer
%           3. AUX -> AUX Data in 16-bit integer
%
%   J. Cagle, University of Florida, 2017

if nargin > 1
    error('Incorrect number of arguments');
elseif nargin == 1
    FileFullPath = varargin{1};
else
    [FileName, Folder] = uigetfile('*.bin');
    if FileName == 0
        error('You must select one file');
    end
    FileFullPath = [Folder, FileName];
end

fid = fopen(FileFullPath, 'rb');
nSample = fread(fid, 1, 'int32');
nEEGChan = fread(fid, 1, 'int32');
nAUXChan = fread(fid, 1, 'int32');
rawData = uint8(fread(fid, inf, 'uint8'));
fclose(fid);

DataSize_perWrite = nSample*nEEGChan*4 + nSample*4 + nSample*2*nAUXChan; 
Block = length(rawData) / DataSize_perWrite;
if rem(length(rawData), DataSize_perWrite) ~= 0
    error('DataSize Mismatched, Possible Data Corruption');
end

SampleID = zeros(1, nSample*Block);
EEG_Data = zeros(nEEGChan, nSample*Block);
AUX_Data = zeros(nAUXChan, nSample*Block);

for i = 1:Block
    startIndex = (i-1)*DataSize_perWrite + 1;
    SampleID((i-1)*nSample+1:i*nSample) = typecast(rawData(startIndex:startIndex+4*nSample-1), 'int32');
    startIndex = (i-1)*DataSize_perWrite + 1 + 4*nSample;
    EEG_Data(:,(i-1)*nSample+1:i*nSample) = reshape(typecast(rawData(startIndex:startIndex+4*nEEGChan*nSample-1), 'int32'), [nEEGChan, nSample]);
    startIndex = (i-1)*DataSize_perWrite + 1 + 4*nSample + 4*nEEGChan*nSample;
    AUX_Data(:,(i-1)*nSample+1:i*nSample) = reshape(typecast(rawData(startIndex:startIndex+2*nAUXChan*nSample-1), 'int16'), [nAUXChan, nSample]);
end

Data = struct('ID',SampleID,'EEG',EEG_Data,'AUX',AUX_Data);
