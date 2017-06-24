function [ Samples, BCI_Obj ] = OpenBCI_ReadBinary( BCI_Obj, nSample )
%The Standard protocol of reading OpenBCI Binary
%   [Sample, BCI_Obj] = OpenBCI_ReadBinary(BCI_Obj, nSample);
%
%   J. Cagle, University of Florida, 2017


maxSkip = 500;
packet_id = zeros(1,nSample);
eeg_data = zeros(BCI_Obj.eeg_channels_per_sample, nSample);
aux_data = zeros(BCI_Obj.aux_channels_per_sample, nSample);

for n = 1:nSample
    skip = 0;
    while skip < maxSkip

        % Search for Start Byte
        if BCI_Obj.read_state == 0
            Bytes = fread(BCI_Obj.ser, 1);
            if isequal(Bytes, BCI_Obj.opt.startByte)
                if skip ~= 0
                    warning('Skipped %d bytes before start found', skip);
                    skip = 0;
                end
                packet_id(n) = double(fread(BCI_Obj.ser, 1)) + BCI_Obj.CycleCounter * 256;
                if packet_id(n) < BCI_Obj.lastIndex
                    BCI_Obj.CycleCounter = BCI_Obj.CycleCounter + 1;
                    packet_id(n) = packet_id(n) + 256;
                end
                BCI_Obj.lastIndex = packet_id(n);
                BCI_Obj.read_state = 1;
            end

        % Search for Channel Data
        elseif BCI_Obj.read_state == 1
            for i = 1:BCI_Obj.eeg_channels_per_sample
                Bytes = fread(BCI_Obj.ser, 3);
                if Bytes(1) > 127
                    prefix = uint8(255);
                else
                    prefix = uint8(0);
                end
                Bytes = [prefix Bytes'];
                eeg_data(i,n) = double(swapbytes(typecast(Bytes, 'int32')));
            end
            BCI_Obj.read_state = 2;

        elseif BCI_Obj.read_state == 2
            for i = 1:BCI_Obj.aux_channels_per_sample
                Bytes = fread(BCI_Obj.ser, 2);
                aux_data(i,n) = double(swapbytes(typecast(uint8(Bytes)', 'int16')));
            end
            BCI_Obj.read_state = 3;

        elseif BCI_Obj.read_state == 3
            Bytes = fread(BCI_Obj.ser, 1);
            BCI_Obj.read_state = 0;
            if Bytes == BCI_Obj.opt.endByte
                BCI_Obj.packets_dropped = 0;
            else
                warning('ID:<%d> <Unexpected END_BYTE found <%s> instead of <%s>', packet_id, Bytes, BCI_Obj.opt.endByte);
            end
            break;
        end

        skip = skip + 1;
    end
end

Samples = struct('ID',packet_id, 'EEG', eeg_data, 'AUX', aux_data);

end

