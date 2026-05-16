# Matlab_hw
matlab homework
## Section B: Simulation Tasks [60%]:

### Task 1: Speech Recording, Sampling, and Quantization in Simulink [15%]

The aim of this task is to investigate the effect of quantization level and sampling on speech quality using MATLAB Simulink.

• Record your voice into an audio file by reading the following sentence:

“My name is [Your Name] and I am recording this voice to study the speech digitization.”

If your recorded signal is a 2-channel stereo signal you need to convert it into 1-channel mono using Selector block (Simulink → Signal Routing).

• In Simulink, build a system model consisting of:

o From Multimedia File (speech source)

o Uniform Encoder / Quantizer block with different bit resolutions (e.g., 2, 4, 6, 8 bits). Adjust the Peak parameter to match the recorded signal.

o Integer-to-Bit Converter and reverse blocks to reconstruct the signal

o To Audio Device block to play reconstructed speech

• Use time scopes and spectrum analyzers to examine the input/output waveforms and spectra.

• Add a Downsample block (DSP System Toolbox → Signal Operations) to study the sampling rate.

In your response, please ensure that you address the following points:

• Simulink block diagram and key values of your simulations

• Plots of original vs. reconstructed waveforms and spectra

• Tables of SQNR values and transmission bandwidth for different quantization (i.e. 2, 4, 6, 8 bits). Explain how you calculate these parameters.

• Discuss the speech quality and quantization level trade-offs. Find the minimum sampling rate for your voice signal and explain the effect of down sampling on the quality of your voice signal.

### Task 2: Data Transmission with M-QAM [15%]

The aim of this task is to study signal characteristics and BER performance of QAM systems using MATLAB Simulink.

• In Simulink, build a system model consisting of:

o Random Integer Generator (Communications Toolbox → Sources)

o Rectangular QAM Modulator Baseband and Rectangular QAM Demodulator Baseband
(Communications Toolbox → Modulation)

o AWGN Channel (Communications Toolbox → Channels)

o Integer to Bit Converter (Communications Toolbox → Utilities) — used twice, one for transmitted integers, one for demodulated integers

o Error Rate Calculation (Communications Toolbox → Sinks / Utilities)

• Use Constellation Diagram (Communications Toolbox → Sinks) to examine the detected constellation.

In your response, please ensure that you address the following points:

• Simulink block diagrams and key simulation values.

• Plot the constellation diagrams (the generated signal sets with the bit-to-symbol mapping) and the corresponding waveforms for M= 4, 16, 64 in noiseless conditions and noisy channel conditions for representative values of Eb/No. Calculate the bandwidth efficiency for M=4, 16, 64.

• Plot BER vs Eb/No performance for M= 4, 16, 64, by simulation. You should show all the BER curves in one figure for ease of comparison.

• Comment on bandwidth efficiency and BER performance for each scheme.

### Task 3: Pulse Shaping and System Design [15%]

The aim of this task is to investigate the role of pulse shaping in digital transmission and demonstrate your ability to make and justify engineering design decisions using MATLAB Simulink.

• In Simulink, build a system model consisting of the blocks you learnt in Experiment 3. Use BPSK modulation scheme in your design.

• You can use time and frequency scopes, and constellation and eye diagrams to examine the effect of filtering and compare the input and output of the filters.

In your response, please ensure that you address the following points:

• Simulink block diagrams and key simulation values.

• Filter responses for different roll-off factors including 0.1, 0.5 and 1. Frequency spectrum before and after filtering at the receiver and transmitter, and eye diagram after the receiver. You also need to provide corresponding waveforms and constellation diagrams.

• Investigate the impact of mismatched pulse shaping filters by selecting different roll-off factors at the transmitter and receiver. Analyse how this mismatch affects inter-symbol interference (ISI) and bit error rate (BER), and provide a critical discussion supported by simulation results (e.g., eye diagrams, constellation plots, and BER curves).

• Discuss the impact of filter group delay on system performance and explain how it must be compensated for to ensure accurate BER calculations.

### Task 4: Basic OFDM Modulation [15%]

The aim of this task is to implement a basic OFDM transmitter and receiver using IFFT/FFT and evaluate symbol recovery under AWGN for different M-QAM schemes.

• Implement an OFDM system in MATLAB based on what you learnt in Experiment 5, including: random symbol generation, QAM modulation, IFFT, AWGN channel, FFT, and QAM demodulation.

• Run simulations for M = 4 and 16, SNR=10, 25 and 40 dB, and 32 subcarriers.

In your response, please ensure that you address the following points:

• Plots of the time-domain OFDM signals and constellation diagrams for the given values of SNR and M.

• Verify whether transmitted and received symbols match.

• Answer the conceptual questions provided below:

o Why is IFFT used in OFDM?

o What does each FFT bin represent physically?

o Why does OFDM simplify equalization?

o What happens when M increases in QAM?

o Why do we get perfect recovery at high SNR?

