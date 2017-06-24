function OpenBCI_Config( BCI_Obj, Command, varargin )
%Send Configuration Command to OpenBCI Board
%   OpenBCI_Config( BCI_Obj, 'START')
%   OpenBCI_Config( BCI_Obj, 'STOP')
%   OpenBCI_Config( BCI_Obj, 'SOFT_RESET')
%   OpenBCI_Config( BCI_Obj, 'CHANNEL_ON', Channel)
%   OpenBCI_Config( BCI_Obj, 'CHANNEL_OFF', Channel)
%
%   J. Cagle, University of Florida, 2017

% Check BCI Object
if ~isfield(BCI_Obj, 'isOpenBCI')
    error('OpenBCI Object Incorrect');
end

% Check BCI Serial Object
if ~strcmp(BCI_Obj.ser.Status,'open')
    error('OpenBCI Serial Object is closed. Please reconnect before configuration');
end

% Stop Streaming
if strcmpi(Command, 'STOP') 
    fwrite(BCI_Obj.ser, uint8('s'));
    
% Start Streaming
elseif strcmpi(Command, 'START')
    fwrite(BCI_Obj.ser, uint8('b'));

% Soft Reset / Initialization
elseif strcmpi(Command, 'SOFT_RESET')
    fwrite(BCI_Obj.ser, uint8('v'));

% Turn off recording channels
elseif strcmpi(Command, 'CHANNEL_OFF')
    for n = 1:length(varargin)
        switch varargin{n}
            case 1
                fwrite(BCI_Obj.ser, uint8('1'));
            case 2
                fwrite(BCI_Obj.ser, uint8('2'));
            case 3
                fwrite(BCI_Obj.ser, uint8('3'));
            case 4
                fwrite(BCI_Obj.ser, uint8('4'));
            case 5
                fwrite(BCI_Obj.ser, uint8('5'));
            case 6
                fwrite(BCI_Obj.ser, uint8('6'));
            case 7
                fwrite(BCI_Obj.ser, uint8('7'));
            case 8
                fwrite(BCI_Obj.ser, uint8('8'));
            case 9
                fwrite(BCI_Obj.ser, uint8('q'));
            case 10
                fwrite(BCI_Obj.ser, uint8('w'));
            case 11
                fwrite(BCI_Obj.ser, uint8('e'));
            case 12
                fwrite(BCI_Obj.ser, uint8('r'));
            case 13
                fwrite(BCI_Obj.ser, uint8('t'));
            case 14
                fwrite(BCI_Obj.ser, uint8('y'));
            case 15
                fwrite(BCI_Obj.ser, uint8('u'));
            case 16
                fwrite(BCI_Obj.ser, uint8('i'));
            otherwise
                warning(['Unknown Channel Number: ', num2str(varargin)]);
        end
    end

% Turn on recording channels 
elseif strcmpi(Command, 'CHANNEL_ON')
    for n = 1:length(varargin)
        switch varargin{n}
            case 1
                fwrite(BCI_Obj.ser, uint8('!'));
            case 2
                fwrite(BCI_Obj.ser, uint8('@'));
            case 3
                fwrite(BCI_Obj.ser, uint8('#'));
            case 4
                fwrite(BCI_Obj.ser, uint8('$'));
            case 5
                fwrite(BCI_Obj.ser, uint8('%'));
            case 6
                fwrite(BCI_Obj.ser, uint8('^'));
            case 7
                fwrite(BCI_Obj.ser, uint8('&'));
            case 8
                fwrite(BCI_Obj.ser, uint8('*'));
            case 9
                fwrite(BCI_Obj.ser, uint8('Q'));
            case 10
                fwrite(BCI_Obj.ser, uint8('W'));
            case 11
                fwrite(BCI_Obj.ser, uint8('E'));
            case 12
                fwrite(BCI_Obj.ser, uint8('R'));
            case 13
                fwrite(BCI_Obj.ser, uint8('T'));
            case 14
                fwrite(BCI_Obj.ser, uint8('Y'));
            case 15
                fwrite(BCI_Obj.ser, uint8('U'));
            case 16
                fwrite(BCI_Obj.ser, uint8('I'));
            otherwise
                warning(['Unknown Channel Number: ', num2str(varargin)]);
        end
    end
    
elseif strcmpi(Command, 'QUERY')
    fwrite(BCI_Obj.ser, uint8('?'));
    pause(1);
    IncomingMessage = uint8([36 36 36 32]);
    while ~isequal(IncomingMessage(end-2:end),uint8([36 36 36]))
        pause(0.1);
        if BCI_Obj.ser.BytesAvailable > 0
            IncomingMessage = [IncomingMessage fread(BCI_Obj.ser, BCI_Obj.ser.BytesAvailable)'];
        end
    end
    fprintf(native2unicode(IncomingMessage,'UTF-8'));
    fprintf('\n');

% Unknown
else
    error('Unknown Command');
end

end
