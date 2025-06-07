% MATLAB Script to Generate 406 MHz Beacon IQ Signal
% with Valid LONG Message Structure and BCH Codes (FGB 144-bit Format)
% Includes Hex output of the message and adjusted plot zoom.

clear;
clc;

pkg load communications

%% --- Parameters ---
% RF and Signal Parameters
data_rate = 400; % bps
phase_modulation_rad = 1.1; % Radians (+/- 1.1 rad)
amplitude = 1.0; % Arbitrary amplitude for the IQ signal

% Timing (Preamble)
preamble_duration_s = 0.160; % 160 ms unmodulated carrier preamble

% Sampling Parameters
fs = 40000; % Sampling frequency in Hz (40kHz -> 100 samples/bit)
samples_per_bit = round(fs / data_rate);
if mod(samples_per_bit, 2) ~= 0
    samples_per_bit = floor(samples_per_bit / 2) * 2;
    warning('Adjusted samples_per_bit to be even: %d. Consider adjusting fs.', samples_per_bit);
end
samples_per_half_bit = samples_per_bit / 2;

%% --- 1. Construct Valid COSPAS-SARSAT LONG Message (144 bits total) ---

full_beacon_transmission_bits = sarsat_trame_generator(123456, 41.412, 2.442);

% --- Assemble the full 144-bit message for modulation ---
num_total_modulated_bits = length(full_beacon_transmission_bits);
if num_total_modulated_bits ~= 144, error('Total modulated bits not 144.'); end

fprintf('Successfully constructed 144-bit valid long beacon message.\n');
% Convert full_beacon_transmission_bits to Hex
hex_message_string = bits_to_hex(full_beacon_transmission_bits);
fprintf('  Full 144-bit transmission sequence (Sync + Msg + BCH) in Hex: %s\n', hex_message_string);


%% --- 2. Generate Preamble (Unmodulated Carrier) ---
num_preamble_samples = round(preamble_duration_s * fs);
preamble_iq = amplitude * ones(1, num_preamble_samples) + 0j;

%% --- 3. Generate Modulated Message using Bi-Phase L and PSK ---
biphase_L_modulated_iq = zeros(1, num_total_modulated_bits * samples_per_bit);
%current_phase = phase_modulation_rad;
current_sample_index = 1;

for i = 1:num_total_modulated_bits
    bit_val = full_beacon_transmission_bits(i); % Renamed 'bit' to 'bit_val' to avoid conflict with function name
    if bit_val == 1
        phase_segment_first_half = phase_modulation_rad * ones(1, samples_per_half_bit);
        phase_segment_second_half = -phase_modulation_rad * ones(1, samples_per_half_bit);
        phase_segment = [phase_segment_first_half, phase_segment_second_half];
    else
        phase_segment_first_half = -phase_modulation_rad * ones(1, samples_per_half_bit);
        phase_segment_second_half = phase_modulation_rad * ones(1, samples_per_half_bit);
        phase_segment = [phase_segment_first_half, phase_segment_second_half];
    end
    iq_segment = amplitude * exp(1j * phase_segment);
    biphase_L_modulated_iq(current_sample_index : current_sample_index + samples_per_bit - 1) = iq_segment;
    current_sample_index = current_sample_index + samples_per_bit;
end

%% --- 4. Combine Preamble and Modulated Message ---
iq_signal = [preamble_iq, biphase_L_modulated_iq];

% --- Signal Information ---
modulated_part_duration_s = num_total_modulated_bits / data_rate;
total_duration_s = preamble_duration_s + modulated_part_duration_s;
fprintf('\n--- Generated IQ Signal Details ---\n');
fprintf('Sampling freq: %.2f kHz, Data rate: %d bps\n', fs/1000, data_rate);
fprintf('Preamble: %.3f s (%d samples)\n', preamble_duration_s, num_preamble_samples);
fprintf('Modulated message: %.3f s (%d bits, %d samples)\n', ...
        modulated_part_duration_s, num_total_modulated_bits, length(biphase_L_modulated_iq));
fprintf('Total signal duration: %.3f s, Total samples: %d\n', total_duration_s, length(iq_signal));

%% --- 5. Save to IQ File (Optional) ---
output_filename = 'beacon_signal_406mhz_long_msg_144bit.iq';
fid = fopen(output_filename, 'wb');
if fid == -1, error('Cannot open file for writing: %s', output_filename); end
iq_interleaved = zeros(1, 2 * length(iq_signal));
iq_interleaved(1:2:end) = real(iq_signal);
iq_interleaved(2:2:end) = imag(iq_signal);
fwrite(fid, iq_interleaved, 'float32');
fclose(fid);
fprintf('IQ signal saved to %s as interleaved float32.\n', output_filename);

%% --- 6. Plotting (Optional) ---
t = (0:length(iq_signal)-1) / fs;
figure;
plot(t, real(iq_signal), 'b', t, imag(iq_signal), 'r');
xlabel('Time (s)'); ylabel('Amplitude');
title({'IQ Components of Generated Beacon Signal (Long Message 144-bit)'; ...
       'Note: For \pm1.1rad PSK, I_{msg} \approx const, Q_{msg} changes sign.'});
legend('In-Phase (I)', 'Quadrature (Q)'); grid on;

% Adjusted X-axis limits for better visibility of preamble-to-message transition and message modulation
xlim_plot_start = preamble_duration_s - 0.005; % Show 5ms of preamble end
xlim_plot_end = total_duration_s;   % Show 25ms (10 bits) of message start
xlim([xlim_plot_start xlim_plot_end]);
ylim([-amplitude*1.1 amplitude*1.1]); % Ensure Q changes are visible

