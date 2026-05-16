%% Task 2: Data Transmission with M-QAM - Auto Build Simulink Model (R2022b friendly)
% Builds a Simulink model for README Task 2.
% Focus: compatibility with MATLAB R2022b and avoiding niche/custom blocks.

modelName = 'task2_mqam_txrx';

% Clean up old model
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
if exist([modelName '.slx'], 'file')
    delete([modelName '.slx']);
end

% Create model
new_system(modelName);
open_system(modelName);

%% Parameters
M = 16;                   % 4 / 16 / 64
k = log2(M);              % bits/symbol
EbNo_dB = 12;             % representative noisy case
symRate = 1e5;            % symbols/s
frameSymbols = 5000;      % symbols/frame
seed = 12345;

% Model workspace variables
mws = get_param(modelName, 'ModelWorkspace');
assignin(mws, 'M', M);
assignin(mws, 'k', k);
assignin(mws, 'EbNo_dB', EbNo_dB);
assignin(mws, 'symRate', symRate);
assignin(mws, 'frameSymbols', frameSymbols);
assignin(mws, 'seed', seed);
assignin(mws, 'snr_dB', 'EbNo_dB + 10*log10(k)');

%% Add blocks (with fallback candidates for version compatibility)
blkRand = [modelName '/Random Integer Generator'];
add_block_try({ ...
    'commrndsrc3/Random Integer Generator', ...
    'commsrcs2/Random Integer Generator', ...
    'commsources/Random Integer Generator'}, blkRand, ...
    {'M','M','InitialSeed','seed','SampleTime','1/symRate','SamplesPerFrame','frameSymbols'}, ...
    [50 120 230 180]);

blkQamMod = [modelName '/Rectangular QAM Modulator Baseband'];
add_block_try({ ...
    'commdigbbndmod/Rectangular QAM Modulator Baseband', ...
    'commqammod/Rectangular QAM Modulator Baseband'}, blkQamMod, ...
    {'M','M','NormalizationMethod','Average power'}, [280 110 520 190]);

blkAWGN = [modelName '/AWGN Channel'];
add_block_try({ ...
    'commchan2/AWGN Channel', ...
    'commchannels/AWGN Channel'}, blkAWGN, ...
    {'Mode','Signal to noise ratio (SNR)','SNR','snr_dB'}, [570 110 760 190]);

blkConst = [modelName '/Constellation Diagram'];
add_block_try({ ...
    'commscope/Constellation Diagram', ...
    'commscopesink2/Constellation Diagram'}, blkConst, {}, [800 20 1030 160]);

blkQamDemod = [modelName '/Rectangular QAM Demodulator Baseband'];
add_block_try({ ...
    'commdigbbnddemod/Rectangular QAM Demodulator Baseband', ...
    'commqamdemod/Rectangular QAM Demodulator Baseband'}, blkQamDemod, ...
    {'M','M','NormalizationMethod','Average power'}, [800 190 1030 270]);

blkInt2BitTx = [modelName '/Integer to Bit Converter (TX ref)'];
add_block_try({ ...
    'commcnvrt2/Integer to Bit Converter', ...
    'commutils/Integer to Bit Converter'}, blkInt2BitTx, ...
    {'BitsPerInteger','k'}, [280 280 520 360]);

blkInt2BitRx = [modelName '/Integer to Bit Converter (RX)'];
add_block_try({ ...
    'commcnvrt2/Integer to Bit Converter', ...
    'commutils/Integer to Bit Converter'}, blkInt2BitRx, ...
    {'BitsPerInteger','k'}, [1080 190 1290 270]);

blkErr = [modelName '/Error Rate Calculation'];
add_block_try({ ...
    'commerrorrate/Error Rate Calculation', ...
    'commutils/Error Rate Calculation'}, blkErr, ...
    {'ReceiveDelay','0','ComputationDelay','0'}, [1330 230 1540 310]);

add_block('simulink/Sinks/Display', [modelName '/Display BER'], 'Position', [1600 245 1700 295]);
add_block('simulink/Sinks/Scope', [modelName '/Time Scope TX'], 'Position', [570 260 760 340]);
add_block('simulink/Sinks/Scope', [modelName '/Time Scope RX'], 'Position', [1080 300 1260 380]);

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

%% ------- Local helper -------
function add_block_try(candidateLibPaths, dstPath, paramCell, pos)
% Try multiple library paths for the same block to improve version compatibility.
lastErr = '';
for i = 1:numel(candidateLibPaths)
    try
        add_block(candidateLibPaths{i}, dstPath, 'Position', pos);
        if ~isempty(paramCell)
            set_param(dstPath, paramCell{:});
        end
        return;
    catch ME
        lastErr = ME.message;
    end
end

msg = sprintf(['Failed to add block for "%s".\n', ...
    'Tried candidates:\n  - %s\n', ...
    'Last error:\n%s\n\n', ...
    'Tip: open Simulink Library Browser and search this block name, then replace candidate paths.'], ...
    dstPath, strjoin(candidateLibPaths, '\n  - '), lastErr);
error(msg);
end
