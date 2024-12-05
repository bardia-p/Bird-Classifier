%{
data = csvread('[insert path].csv', 1, 0); % Skip the first row (headers)

% Spectrograms are of size 257 x 2813 (time vs. frequency)
numTimePoints = size(data, 1); % rows
numFrequencies = size(data, 2); % columns

% Define the time and frequency ranges (adjust as per your data)
time = linspace(0, 60, numTimePoints); % 60 seconds
frequency = linspace(0, 28130, numFrequencies); % Assuming 28310 is max. frequency

% Plot the spectrogram
figure;
imagesc(time, frequency, data);
axis xy; % Flip the Y-axis so low frequencies are at the bottom
set(gca, 'XTick', []);
set(gca, 'YTick', []);
%xlabel('Time (s)');
%ax = gca;           % Get current axes
%ax.YAxis.Exponent = 0;  % Disable the scientific notation
%ylabel('Frequency (Hz)');
ylim([0 23500]);
%title('Spectrogram');

% Apply the jet colormap
colormap('jet');
%}

clear

% Define the input and output directories
inputFolder = '[insert path]';   % Folder where your CSV files are
outputFolder = '[insert path]'; % Folder where you want to save the plots

% Get list of all CSV files in the 'SPEC' folder
csvFiles = dir(fullfile(inputFolder, '*.csv'));

% Loop through each CSV file
for i = 1:length(csvFiles)
    % Get the current file name
    fileName = csvFiles(i).name;
    
    % Read the CSV file, skipping the first row (headers)
    data = csvread(fullfile(inputFolder, fileName), 1, 0); 

    % Spectrograms are of size 257 x 2813 (time vs. frequency)
    numTimePoints = size(data, 1); % rows
    numFrequencies = size(data, 2); % columns

    % Define the time and frequency ranges
    time = linspace(0, 60, numTimePoints); % 60 seconds
    frequency = linspace(0, 28130, numFrequencies); % Assuming 28130 is max. frequency

    % Create the figure
    figure;

    % Plot the spectrogram
    imagesc(time, frequency, data);
    axis xy; % Flip the Y-axis so low frequencies are at the bottom
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    ylim([0 23500]);

    % Apply the 'jet' colormap
    colormap('jet');
    
    % Save the figure as a PNG file with the same name in the output folder
    outputFileName = fullfile(outputFolder, [fileName(1:end-4), '.png']); % Remove .csv extension
    saveas(gcf, outputFileName);
    
    % Close the figure to avoid memory issues
    close(gcf);
end





