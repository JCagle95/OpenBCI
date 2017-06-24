function varargout = OpenBCI_GUI(varargin)
% Using OpenBCI with MATLAB using Graphical User Interfaces
%       OpenBCI_GUI;
%
%       More to be implemented.
%
%   J. Cagle, University of Florida, 2017

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OpenBCI_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @OpenBCI_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% --- Executes just before OpenBCI_GUI is made visible.
function OpenBCI_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OpenBCI_GUI (see VARARGIN)

% Choose default command line output for OpenBCI_GUI
handles.output = hObject;

% Default Parameters
handles.SerialPort = '';
handles.BCI_Obj.isOpenBCI = false;
handles.logging = false;

% Update handles structure
SerialPorts = instrhwinfo('serial');
handles.SelectSerial.String = [{'Available Serial Ports'}, SerialPorts.AvailableSerialPorts];

guidata(hObject, handles);

% UIWAIT makes OpenBCI_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OpenBCI_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%            Select COM Ports for connection         %%%%%%%
function SelectSerial_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSerial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
handles.SerialPort = contents{get(hObject,'Value')};
guidata(hObject, handles);

%%%%            Connect or Disconnect                           %%%%%%%
function InitButton_Callback(hObject, eventdata, handles)
% hObject    handle to InitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.BCI_Obj.isOpenBCI
    handles.InitButton.String = 'Disconnect';
    handles.BCI_Obj = OpenBCI_Init(handles.SerialPort);
    guidata(hObject, handles);
else
    OpenBCI_End(handles.BCI_Obj);
    handles.BCI_Obj.isOpenBCI = false;
    handles.InitButton.String = 'Connect';
    guidata(hObject, handles);
end

%%%%            For Data Display                           %%%%%%%
function StreamingButton_Callback(hObject, eventdata, handles)
% hObject    handle to StreamingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.BCI_Obj.isOpenBCI
    fprintf('Error, OpenBCI is not connected\n');
else
    
    if handles.BCI_Obj.isStreaming
        handles.StreamingButton.String = 'Start Streaming';
        handles.BCI_Obj.isStreaming = false;
        guidata(hObject, handles);
    else
        [b,a] = butter(5, 1*2/handles.BCI_Obj.opt.Fs, 'high');
        
        handles.StreamingButton.String = 'Stop Streaming';
        handles.BCI_Obj.isStreaming = true;
        set(handles.AUX, 'XTickLabel', {'-3', '-2', '-1', '0'});
        
        MaxRunTime = handles.BCI_Obj.opt.Fs * 5;
        XFrame = handles.BCI_Obj.opt.Fs * 5;
        nSample = 50;
        handles.BCI_Obj.lastIndex = 0;
        handles.BCI_Obj.CycleCounter = 0;
        guidata(hObject, handles);

        Sample_ID = zeros(1,MaxRunTime*2);
        EEG_Sample = zeros(handles.BCI_Obj.eeg_channels_per_sample,MaxRunTime*2);
        AUX_Sample = zeros(handles.BCI_Obj.aux_channels_per_sample,MaxRunTime*2);
        Shifter = zeros(XFrame, handles.BCI_Obj.eeg_channels_per_sample);
        for channel = 1:handles.BCI_Obj.eeg_channels_per_sample
            Shifter(:,channel) = (8 - channel) * 0.005;
        end
        
        n = XFrame + 1 + nSample - rem(XFrame, nSample);
        handles.EEGlineObj = plot(handles.EEG, 1:XFrame, zeros(XFrame, handles.BCI_Obj.eeg_channels_per_sample), 'linewidth', 1.5);
        axis(handles.EEG, [0 XFrame -0.005 0.04]);
        set(handles.EEG, 'YTick', flip(Shifter(1,:)), 'YTickLabel', strsplit(num2str(handles.BCI_Obj.eeg_channels_per_sample:-1:1)), ...
                                            'XTick', 0:handles.BCI_Obj.opt.Fs:XFrame, 'XTickLabel', {'-5', '-4', '-3', '-2', '-1', '0'});
        xlabel(handles.EEG, 'Time (s)', 'fontsize',15);
        ylabel(handles.EEG, 'Channel', 'fontsize', 15);
        xlabel(handles.AUX, 'Time (s)', 'fontsize', 15);
        ylabel(handles.AUX, 'Acceleration (g)', 'fontsize', 15);
        
        % Data Logging
        if handles.logging
            folderPath = handles.DataDir.String;
            fileName = sprintf('/OpenBCI_%.4d%.2d%.2d%.2d%.2d%.2d.bin',round(clock)); 
            fid = fopen([folderPath,fileName] ,'wb');
            fwrite(fid, nSample, 'integer*4');
            fwrite(fid, handles.BCI_Obj.eeg_channels_per_sample, 'integer*4');
            fwrite(fid, handles.BCI_Obj.aux_channels_per_sample, 'integer*4');
        end
        
        % Start Streaming
        OpenBCI_Config(handles.BCI_Obj, 'START');
        while strcmp(handles.StreamingButton.String, 'Stop Streaming');

            [Sample, handles.BCI_Obj] = OpenBCI_ReadBinary(handles.BCI_Obj, nSample);
            if handles.logging
                fwrite(fid, Sample.ID, 'integer*4');
                fwrite(fid, Sample.EEG, 'integer*4');
                fwrite(fid, Sample.AUX, 'integer*2');
            end
            Sample_ID(n:n+nSample-1) = Sample.ID;
            EEG_Sample(:,n:n+nSample-1) = Sample.EEG * handles.BCI_Obj.opt.Vscale;
            AUX_Sample(:,n:n+nSample-1) = Sample.AUX * handles.BCI_Obj.opt.Gscale;
            n = n + nSample;
            
            % Wrapping Around
            if n > MaxRunTime * 2
                Sample_ID(:,1:MaxRunTime) = Sample_ID(:,MaxRunTime+1:end);
                EEG_Sample(:,1:MaxRunTime) = EEG_Sample(:,MaxRunTime+1:end);
                AUX_Sample(:,1:MaxRunTime) = AUX_Sample(:,MaxRunTime+1:end);
                n = MaxRunTime + 1;
            end
            
            % Visualize AUX
            selectAux = find(AUX_Sample(1,n-XFrame:n-1) ~= 0) - 1;
            plot(handles.AUX, Sample_ID(:,n-XFrame + selectAux), AUX_Sample(:,n-XFrame + selectAux)');
            xlim(handles.AUX, [Sample_ID([n-XFrame n-1])]);
            set(handles.AUX, 'XTick', [Sample_ID(n-XFrame) : handles.BCI_Obj.opt.Fs : Sample_ID(n-1)], ...
                                                'XTickLabel', {'-5','-4','-3', '-2', '-1', '0'});
            
            % Visualize EEG
            if handles.BCI_Obj.filtering_data
                Data = filtfilt(b,a,EEG_Sample(:,n-XFrame:n-1)') + Shifter;
            else
                Data = EEG_Sample(:,n-XFrame:n-1)' + Shifter;
            end
            for channel = 1:8
                handles.EEGlineObj(channel).YData = Data(:,channel);
            end
                                            
            disp(handles.BCI_Obj.ser.BytesAvailable);
            if handles.BCI_Obj.ser.BytesAvailable < 5000 
                drawnow;
            end
        end
        OpenBCI_Config(handles.BCI_Obj, 'STOP');
        if handles.logging
            fclose(fid);
        end
        disp('Finished');
    end
end


% --- Executes on button press in DataDir_Selection.
function DataDir_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to DataDir_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Dir = uigetdir();
if Dir == 0
    handles.logging = false;
    handles.DataDir.String = 'No Directory Selected. No Data Storage.';
else
    handles.logging = true;
    handles.DataDir.String = Dir;
end
guidata(hObject, handles);