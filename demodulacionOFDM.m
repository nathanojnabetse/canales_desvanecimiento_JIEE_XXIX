function [simbolosOFDM_datos]=demodulacionOFDM(signal,PC)
    
    %se extrae el prefijo ciclico
    signal_No_PC=signal(PC+1:end,:);
    %se obtiene la transformada directa de fourier
    simbolosOFDM_datos=fft(signal_No_PC);

end
