% Pipeline
BCI_Obj = OpenBCI_Init('COM5');
%[ Sample_ID, EEG_Sample, AUX_Sample ] = OpenBCI_Streaming( BCI_Obj );
OpenBCI_Config(BCI_Obj, 'START');
OpenBCI_Config(BCI_Obj, 'STOP');
OpenBCI_End(BCI_Obj);