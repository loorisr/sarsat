function trame = sarsat_trame_generator(beacon_id_decimal, latitude, longitude)
  % --- Sync Pattern (15 bits) ---
  sync_pattern = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]; % Standard 15-bit sync

  % --- Frame Sync Pattern (9 bits) ---
  frame_sync_pattern = [0, 1, 1, 0, 1, 0, 0, 0, 0]; % Normal Mode: 000101111 Self-Test: 011010000

  % --- Message Data Block (88 bits = 1 Format Flag + 87 Data Fields) ---
  format_flag = [1]; % '1' for Long Message Format
  protocol_flag = [0]; % '0' Standard Location ELT/EPIRB/PLB
  country_code_decimal = 227; % France
  country_code_bin = de2bi(country_code_decimal, 10, 'left-msb');
  protocol_code = [0, 0, 1, 1]; % Std Loc. ELT 24-bit Address Protocol
  beacon_id_bin = de2bi(beacon_id_decimal, 24, 'left-msb');
  latitude_bin = de2bi(round(abs(latitude*4)), 9, 'left-msb');
  if (latitude > 0)
      latitude_bin = [0, latitude_bin];
    else
      latitude_bin = [1, latitude_bin];
  endif

  longitude_bin = de2bi(round(abs(longitude*4)), 10, 'left-msb');
  if (longitude > 0)
      longitude_bin = [0, longitude_bin];
    else
      longitude_bin = [1, longitude_bin];
  endif

  location_data_bin = [latitude_bin, longitude_bin];

  m_bits = [format_flag, protocol_flag, country_code_bin, protocol_code, beacon_id_bin, location_data_bin];

  %%%%%
  trame = [sync_pattern, frame_sync_pattern, m_bits];

  if length(trame) ~= 85, error('m_bits length is not 85.'); end

  % --- BCH Code Calculation  ---
  g21_poly_coeffs= [1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1];

  m1_bits_for_bch1 = trame(25:85);
  bch1_code = calculate_bch_remainder(m1_bits_for_bch1, g21_poly_coeffs); % 21 bits
  if length(bch1_code) ~= 21, error('BCH-1 not 21 bits.'); end
  trame = [trame, bch1_code];


  specific_beacon_type_bin = [1, 1, 0, 1, 1]; % '10'
  homing_121_5_present_bin = [0]; % '1' for present

  latitude_delta = latitude-round(latitude*4)/4;
  min_delta = abs(latitude_delta - fix(latitude_delta)) * 60;

  latitude_minute_bin = de2bi(fix(min_delta), 5, 'left-msb');
  if (latitude_delta > 0)
      latitude_minute_bin = [1, latitude_minute_bin];
    else
      latitude_minute_bin = [0, latitude_minute_bin];
  endif

  second_delta = abs(min_delta - fix(min_delta)) * 60;
  latitude_second_bin = de2bi(fix(second_delta/4), 4, 'left-msb');


  longitude_delta = longitude-round(longitude*4)/4;
  min_delta = abs(longitude_delta - fix(longitude_delta)) * 60;

  longitude_minute_bin = de2bi(fix(min_delta), 5, 'left-msb');
  if (longitude_delta > 0)
      longitude_minute_bin = [1, longitude_minute_bin];
    else
      longitude_minute_bin = [0, longitude_minute_bin];
  endif

  second_delta = abs(min_delta - fix(min_delta)) * 60;
  longitude_second_bin = de2bi(fix(second_delta/4), 4, 'left-msb');

  m_bits = [specific_beacon_type_bin, homing_121_5_present_bin, latitude_minute_bin, latitude_second_bin, longitude_minute_bin, longitude_second_bin];

  trame = [trame, m_bits];

  g12_poly_coeffs= [1,0,1,0,1,0,0,1,1,1,0,0,1];
  m2_bits_for_bch2 = trame(107:132);
  bch2_code = calculate_bch_remainder(m2_bits_for_bch2, g12_poly_coeffs); % 12 bits
  if length(bch2_code) ~= 12, error('BCH-2 not 12 bits.'); end

  trame = [trame, bch2_code];
end
