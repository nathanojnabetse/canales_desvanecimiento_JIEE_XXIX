clc
clear all
close all

%% Condiciones iniciales de la simulación
N = 128;         % Numero de subportadoras = {64 - 128}
PC = N/4;        % Longitud de prefijo cíclico
m = 2;          % Nivel de modulación: 2(QPSK), 4(16QAM)
M = 2^m;        % Número de bits por símbolo modulado
N_trials = 10;  % Número de simulaciones de MonteCarlo (al menos 1000)
SNR = 0:2:20;   % Valores de relación señal a ruido

%% Modelado de canales inalámbricos (PRIMERA FORMA)
fd = 100;          %Frecuencia doopler maxima para canal Rayleigh
ts = 1/(fd*1000);  %Parámetro de tiempo para Rayleigh
tau = [0 1.5 4];   %Perfil retardo-potencia
pdb = [0 -4 -8];
% RAYLEIGH
rayChan = rayleighchan(ts,fd,tau,pdb);
% RICIAN
k = 8;
ricianChan = ricianchan(ts,fd,k,tau,pdb);
%% INICIO DE LAS SIMULACIONES DE MONTE CARLO

for i=1:N_trials

% FUENTE
% Generación de bits aleatorios
bits_fuente = randi([0 1],1,N*m);     
% Modulación de la secuencia de bits
simbolos_Tx = modulacion(bits_fuente,m); 
% Conversión serie-paralelo
simbolos_Tx_paralelo = serieParalelo(simbolos_Tx);
% Bloque OFDM: se obtiene la ifft y se añade el PC
simbolo_OFDM_paralelo = modulacionOFDM(simbolos_Tx_paralelo,N,PC);
% Conversión paralelo-serie
Tx = paraleloSerie(simbolo_OFDM_paralelo);
%% Adición del desvanecimiento
% FORMA 1
Tx_ray = filter(rayChan,Tx);
Tx_ric = filter(ricianChan,Tx);
%% Adición de ruido AWGN y procesamiento de la señal en el receptor
for j=1:length(SNR)
    
    clc
    % Mostrar el numero de la simulación de MonteCarlo
    % Ejecutándose actualmente
    disp(i); 
    % CANAL
    Rx = awgn(Tx,SNR(j),'measured'); % AWGN
    Rx_ray = awgn(Tx_ray,SNR(j),'measured'); % RAYLEIGH
    Rx_ric = awgn(Tx_ric,SNR(j),'measured'); % RICIAN
    
    % RECEPTOR
    % Conversión serie/paralelo del simbolo OFDM recibido
    simbolo_Rx_paralelo = serieParalelo(Rx);
    simbolo_Rx_paralelo_ray = serieParalelo(Rx_ray);
    simbolo_Rx_paralelo_ric = serieParalelo(Rx_ric);
    % DEMODULADOR OFDM: se extrae el PC y se obtiene la fft
    simbolo_Rx_OFDM = demodulacionOFDM(simbolo_Rx_paralelo,PC);
    simbolo_Rx_OFDM_ray = demodulacionOFDM(simbolo_Rx_paralelo_ray,PC);
    simbolo_Rx_OFDM_ric = demodulacionOFDM(simbolo_Rx_paralelo_ric,PC);
    % Conversión paralelo/serie
    simbolos_Rx_serie = paraleloSerie(simbolo_Rx_OFDM);
    simbolos_Rx_serie_ray = paraleloSerie(simbolo_Rx_OFDM_ray);
    simbolos_Rx_serie_ric = paraleloSerie(simbolo_Rx_OFDM_ric);
    % Demodulación
    bits_Rx = demodulacion(simbolos_Rx_serie,m);
    bits_Rx_ray = demodulacion(simbolos_Rx_serie_ray,m);
    bits_Rx_ric = demodulacion(simbolos_Rx_serie_ric,m);
    % Calculo del BER, para cada valor de SNR
    [~,tasa] = biterr(bits_fuente,bits_Rx);
    BER(i,j) = tasa;
    [~,tasa] = biterr(bits_fuente,bits_Rx_ray);
    BER_ray(i,j) = tasa;
    [~,tasa] = biterr(bits_fuente,bits_Rx_ric);
    BER_ric(i,j) = tasa;
        
end

end
%% OBTENCIÓN de la BER promedio y la gráfica de BER vs SNR
BER_promedio = mean(BER);
BER_promedio_ray = mean(BER_ray);
BER_promedio_ric = mean(BER_ric);
semilogy(SNR,BER_promedio,'g-h','linewidth',1.5)
hold on
semilogy(SNR,BER_promedio_ray,'m-h','linewidth',1.5)
semilogy(SNR,BER_promedio_ric,'b-h','linewidth',1.5)
grid
xlim([0 20])
ylim([1e-3 1e0])
xlabel('SNR [dB]','Fontname','Century Gothic');
ylabel('BER [dB]','Fontname','Century Gothic');
legend('BER AWGN','BER RAYLEIGH','BER RICIAN');
if (m==2)
    title(['BER vs SNR para Q-PSK, N= ',num2str(N),' y PC= ',num2str(PC)],'Fontname','Century Gothic');
else
    title(['BER vs SNR para 16-QAM, N= ',num2str(N),' y PC= ',num2str(PC)],'Fontname','Century Gothic');
end 