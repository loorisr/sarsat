function hex_string = bits_to_hex(bit_vector)
	% convert array of bit to hex
    len = length(bit_vector);
    if mod(len, 4) ~= 0
        % Pad with leading zeros to make length a multiple of 4
        padded_bits = [zeros(1, 4 - mod(len, 4)), bit_vector];
    else
        padded_bits = bit_vector;
    end

    hex_string = '';
    num_nibbles = length(padded_bits) / 4;

    for i = 0:(num_nibbles-1)
        nibble_bits = padded_bits( (i*4)+1 : (i*4)+4 );
        decimal_val = bi2de(nibble_bits, 'left-msb'); % MSB first for conversion
        hex_string = [hex_string, dec2hex(decimal_val, 1)]; %#ok<AGROW>
    end
end
