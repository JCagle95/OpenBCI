function BCI_Obj = OpenBCI_Init( serial_port )
%Initialize OpenBCI Object with Serial Commands, modified from OpenBCI_V3.py
%   BCI_Obj = OpenBCI_Init( serial_port )
%   J. Cagle, University of Florida, 2017

BCI_Obj.isOpenBCI = true;
BCI_Obj.opt.Fs = 250.0;
BCI_Obj.opt.startByte = uint8(160);
BCI_Obj.opt.endByte = uint8(192);
BCI_Obj.opt.Vref = 4.5;
BCI_Obj.opt.Gain = 24.0;
BCI_Obj.opt.Gscale = 0.002 /(power(2,4));
BCI_Obj.opt.Vscale = BCI_Obj.opt.Vref / (power(2,23)-1) / BCI_Obj.opt.Gain; 

BCI_Obj.isStreaming = false;
BCI_Obj.filtering_data = true;
BCI_Obj.scaling_output = true;
BCI_Obj.eeg_channels_per_sample = 8;
BCI_Obj.aux_channels_per_sample = 3;
BCI_Obj.imp_channels_per_sample = 0;
BCI_Obj.read_state = 0;
BCI_Obj.daisy = false;
BCI_Obj.last_odd_sample = [];               % TODO: Add OpenBCISample Struct
BCI_Obj.log_packet_count = 0;
BCI_Obj.attempt_reconnect = false;
BCI_Obj.last_reconnect = 0;
BCI_Obj.reconnect_freq = 5;
BCI_Obj.packets_dropped = 0;
BCI_Obj.lastIndex = 0;
BCI_Obj.CycleCounter = 0;

BCI_Obj.log = true;
BCI_Obj.baudrate = 115200;
BCI_Obj.timeout = 0;
BCI_Obj.port = serial_port;
BCI_Obj.board_type = 'Cyton';
BCI_Obj.ser = serial(BCI_Obj.port, 'BaudRate', BCI_Obj.baudrate, 'InputBufferSize', 32000);
%BCI_Obj.ser.BytesAvailableFcnMode = 'byte';
%BCI_Obj.ser.BytesAvailableFcnCount = 6000;
%BCI_Obj.ser.BytesAvailableFcn = {@OpenBCI_ReadBinary_Callback, BCI_Obj, 100};

ret = -1;

while ret == -1
    % Initialize BCI Object
    fopen(BCI_Obj.ser);
    fprintf('Serial established...\n');
    pause(1);

    % Read Board Information
    OpenBCI_Config(BCI_Obj, 'SOFT_RESET');
    pause(1);
    ret = OpenBCI_printMessage(BCI_Obj, 5);
    if ret == -1
        OpenBCI_Config(BCI_Obj, 'STOP');
        fclose(BCI_Obj.ser);
        fprintf('Reconnection...\n');
        pause(1);
    end
end

%IncomingMessage = native2unicode(fread(BCI_Obj.ser, BCI_Obj.ser.BytesAvailable), 'UTF-8');


end

