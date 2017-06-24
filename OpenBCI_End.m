function OpenBCI_End( BCI_Obj )
%Terminate OpenBCI Object and free up the port
%   OpenBCI_End( BCI_Obj )
%   J. Cagle, University of Florida, 2017

if BCI_Obj.isStreaming
    BCI_Obj.isStreaming = false;
    fwrite(BCI_Obj.ser,uint8('s'));
end

if strcmp(BCI_Obj.ser.Status,'open')
    fprintf('Closing Serial Connection...\n');
    fclose(BCI_Obj.ser);
end

end