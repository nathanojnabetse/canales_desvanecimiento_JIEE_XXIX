function [prefijo_matriz] = modulacionOFDM(signal,N,PC)
   
    % calculamos la transformada inversa rapida de fourier
    simbolos_ifft = ifft(signal,N);
    % Añadir prefijo ciclico
    prefijo_matriz=zeros(N+PC,1);
    prefijo_matriz(1:PC,:) = simbolos_ifft(N-PC+1:N,:);
    for i=1:N
        prefijo_matriz(i+PC,:) = simbolos_ifft(i,:);  
    end
    
end