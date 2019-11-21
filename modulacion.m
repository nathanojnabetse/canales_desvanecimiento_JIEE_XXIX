function simbolos = modulacion(bits,m)
    
    bits_agrupados = vec2mat(bits,m);
    puntos = [bi2de(bits_agrupados,'left-msb')]';
    M = 2^m;
    switch M
        case 2
            simbolos = pskmod(puntos,M);
        case 4
            simbolos = pskmod(puntos,M,pi/M);
        case 16
            simbolos = qammod(puntos,M);
        case 64
            simbolos = qammod(puntos,M);
    end
end