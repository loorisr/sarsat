function remainder = calculate_bch_remainder(message_bits, g_poly_coeffs)
    % Calculates BCH remainder using polynomial division (CRC-like).
    % message_bits: 1xK row vector of message bits.
    % g_poly_coeffs: 1x(M+1) row vector of generator polynomial coefficients (degree M).
    % remainder: 1xM row vector of BCH bits.

    k = length(message_bits);
    m = length(g_poly_coeffs) - 1; % Degree of generator polynomial

    % Append M zeros to the message (multiply by x^M)
    data_to_divide = [message_bits, zeros(1, m)];

    % Perform polynomial division (XOR operations)
    % In this loop, 'data_to_divide' acts as the register being modified.
    for i = 1:k
        if data_to_divide(i) == 1
            % XOR the g_poly with the current part of data_to_divide
            data_to_divide(i : i+m) = bitxor(data_to_divide(i : i+m), g_poly_coeffs);
        end
    end

    % The remainder is the last M bits
    remainder = data_to_divide(k+1 : end);
end
