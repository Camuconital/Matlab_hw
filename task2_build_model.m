%% Task 2: Data Transmission with M-QAM - Auto Build Simulink Model
% This script programmatically builds the Simulink model required by Task 2.
% It creates a reusable model and configures key parameters.

modelName = 'task2_mqam_txrx';

% Clean up old model if already loaded
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
if exist([modelName '.slx'], 'file')
    delete([modelName '.slx']);
end

% Create and open new model
new_system(modelName);
open_system(modelName);

%% Parameters (you can tune these later)
M = 16;                   % Modulation order: 4,16,64
k = log2(M);              % Bits per symbol
EbNo_dB = 12;             % Representative Eb/No for noisy constellation
symRate = 1e5;            % Symbols/s (for efficiency calculations)
frameSymbols = 5000;      % Symbols per frame
seed = 12345;

% Put parameters into model workspace for easy sweeping
mws = get_param(modelName, 'ModelWorkspace');
assignin(mws, 'M', M);
assignin(mws, 'k', k);
assignin(mws, 'EbNo_dB', EbNo_dB);
assignin(mws, 'symRate', symRate);
assignin(mws, 'frameSymbols', frameSymbols);
assignin(mws, 'seed', seed);

% Convert Eb/No to SNR for symbol-rate complex baseband
% Es/No(dB) = Eb/No(dB) + 10*log10(k)
% For complex baseband, use Es/No as SNR per symbol sample.
assignin(mws, 'snr_dB', 'EbNo_dB + 10*log10(k)');

%% Add blocks
blkRand = [modelName '/Random Integer Generator'];
add_block('commrndsrc3/Random Integer Generator', blkRand, ...
    'M', 'M', ...
    'InitialSeed', 'seed', ...
    'SampleTime', '1/symRate', ...
    'SamplesPerFrame', 'frameSymbols', ...
    'Position', [50 120 220 180]);

blkQamMod = [modelName '/Rectangular QAM Modulator Baseband'];
add_block('commdigbbndmod/Rectangular QAM Modulator Baseband', blkQamMod, ...
    'M', 'M', ...
    'NormalizationMethod', 'Average power', ...
    'Position', [280 110 500 190]);

blkAWGN = [modelName '/AWGN Channel'];
add_block('commchan2/AWGN Channel', blkAWGN, ...
    'Mode', 'Signal to noise ratio (SNR)', ...
    'SNR', 'snr_dB', ...
    'Position', [560 110 740 190]);

blkConst = [modelName '/Constellation Diagram'];
add_block('commscope/Constellation Diagram', blkConst, ...
    'Position', [790 20 1020 160]);

blkQamDemod = [modelName '/Rectangular QAM Demodulator Baseband'];
add_block('commdigbbnddemod/Rectangular QAM Demodulator Baseband', blkQamDemod, ...
    'M', 'M', ...
    'NormalizationMethod', 'Average power', ...
    'Position', [790 190 1020 270]);

blkInt2BitTx = [modelName '/Integer to Bit Converter (TX ref)'];
add_block('commcnvrt2/Integer to Bit Converter', blkInt2BitTx, ...
    'BitsPerInteger', 'k', ...
    'Position', [280 280 500 360]);

blkInt2BitRx = [modelName '/Integer to Bit Converter (RX)'];
add_block('commcnvrt2/Integer to Bit Converter', blkInt2BitRx, ...
    'BitsPerInteger', 'k', ...
    'Position', [1080 190 1280 270]);

blkErr = [modelName '/Error Rate Calculation'];
add_block('commerrorrate/Error Rate Calculation', blkErr, ...
    'ReceiveDelay', '0', ...
    'ComputationDelay', '0', ...
    'Position', [1330 230 1540 310]);

blkDisp = [modelName '/Display BER'];
add_block('simulink/Sinks/Display', blkDisp, ...
    'Position', [1600 245 1700 295]);

blkScopeTx = [modelName '/Time Scope TX'];
add_block('simulink/Sinks/Scope', blkScopeTx, ...
    'Position', [560 260 740 340]);

blkScopeRx = [modelName '/Time Scope RX'];
add_block('simulink/Sinks/Scope', blkScopeRx, ...
    'Position', [1080 300 1260 380]);

%% Connect lines
add_line(modelName, 'Random Integer Generator/1', 'Rectangular QAM Modulator Baseband/1');
add_line(modelName, 'Rectangular QAM Modulator Baseband/1', 'AWGN Channel/1');
add_line(modelName, 'AWGN Channel/1', 'Constellation Diagram/1');
add_line(modelName, 'AWGN Channel/1', 'Rectangular QAM Demodulator Baseband/1');

add_line(modelName, 'Random Integer Generator/1', 'Integer to Bit Converter (TX ref)/1');
add_line(modelName, 'Rectangular QAM Demodulator Baseband/1', 'Integer to Bit Converter (RX)/1');

add_line(modelName, 'Integer to Bit Converter (TX ref)/1', 'Error Rate Calculation/1');
add_line(modelName, 'Integer to Bit Converter (RX)/1', 'Error Rate Calculation/2');
add_line(modelName, 'Error Rate Calculation/1', 'Display BER/1');

add_line(modelName, 'Rectangular QAM Modulator Baseband/1', 'Time Scope TX/1');
add_line(modelName, 'Rectangular QAM Demodulator Baseband/1', 'Time Scope RX/1');

%% Simulation settings
set_param(modelName, 'SolverType', 'Fixed-step');
set_param(modelName, 'StopTime', '0.5');
set_param(modelName, 'SignalLogging', 'on');
set_param(modelName, 'SignalLoggingName', 'logsout');

save_system(modelName);
fprintf('Model "%s" created and saved to %s.slx\n', modelName, modelName);

%% Optional: helper for quick M sweep
% for Mv = [4 16 64]
%     assignin(mws, 'M', Mv);
%     assignin(mws, 'k', log2(Mv));
%     simOut = sim(modelName);
% end
