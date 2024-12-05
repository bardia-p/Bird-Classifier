% References:
% https://www.mathworks.com/matlabcentral/answers/463016-create-a-spectrogram-from-wav-file
% https://www.mathworks.com/matlabcentral/answers/320944-proper-butterworth-bandpass-filter

input_folder = '[insert path]';
output_folder_audio = '[insert path]';
output_folder_spec = '[insert path]';

mp3_files = dir(fullfile(input_folder, '*.mp3'));

for i = 1:length(mp3_files)
    %% Noise Removal %%
    file_name = mp3_files(i).name;

    file_path = fullfile(input_folder, file_name);

    [audio, fs] = audioread(file_path);

    fs = 48000; % ensure the sampling rate is 48000 Hz
    
    fL = 3000; % filter low cutoff frequency, Hz
    fH = 8000; % filter high cutoff frequency, Hz
    order = 3; % filter order
    
    [b, a] = butter(order, [fL, fH] / (fs / 2), 'bandpass'); % retrieve filter coeffs from butterworth filter
    
    noise_removed_audio = filter(b, a, audio); % filter and apply filter coeffs

    normalized_audio = noise_removed_audio / max(abs(noise_removed_audio)); % normalize the audio to avoid clipping

    noise_removed_audio_path = fullfile(output_folder_audio, strcat(file_name(1:end-4), '.wav'));
    audiowrite(noise_removed_audio_path, normalized_audio, fs); % save the audio to output folder
    
    %% Spectrograms %%
    window = hamming(512); % window with size of 512 points
    noverlap = 256; % the number of points for repeating the window
    nfft = 1024; % size of the fft
    spectrogram(normalized_audio, window, noverlap, nfft, fs, 'yaxis'); % no outputs specified will create a convenience plot
    colormap('jet');
    
    ax = gca;
    ax.XColor = 'none'; % remove x axis ticks and labels
    ax.YColor = 'none'; % remove y-axis ticks and labels
    colorbar off; % remove the colorbar
    ylim([1.5 9.5]); % 1500 Hz buffer from bandpass filter

    noise_removed_spec_path = fullfile(output_folder_spec, strcat(file_name(1:end-4), '.png')); % output folder
    saveas(gcf, noise_removed_spec_path); % save generated spectrogram
    
    close(gcf); % close image

end
