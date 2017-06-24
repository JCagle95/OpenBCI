function ret = OpenBCI_printMessage( BCI_Obj , timeout )
%Display incoming UTF-8 Message on screen
%   OpenBCI_printMessage( BCI_Obj , timeout );
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

ret = 0;
IncomingMessage = uint8([36 36 36 32]);
startTime = tic;
while ~isequal(IncomingMessage(end-2:end),uint8([36 36 36]))
    pause(0.1);
    if BCI_Obj.ser.BytesAvailable > 0
        IncomingMessage = [IncomingMessage fread(BCI_Obj.ser, BCI_Obj.ser.BytesAvailable)'];
    end
    if toc(startTime) > timeout
        fprintf('TimedOut!\n');
        ret = -1;
        break;
    end
end

fprintf(native2unicode(IncomingMessage,'UTF-8'));
fprintf('\n');

end

