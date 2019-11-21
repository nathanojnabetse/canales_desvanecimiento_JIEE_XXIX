function bits = demodulacion(simbolos,m)

    M = 2^m;
    switch M
        case 2
            puntos = pskdemod(simbolos,M);
        case 4
            puntos = pskdemod(simbolos,M,pi/M);
        case 16
            puntos = qamdemod(simbolos,M);
        case 64
            puntos = qamdemod(simbolos,M);
    end
    bits_agrupados = de2bi(puntos,m,'left-msb');
    bits = vec2mat(bits_agrupados,numel(bits_agrupados));
    
end
