% This code removes the white borders from the spectrogram .png files created by audio_noiseRemoval.m

input_folder = '[insert path]';
output_folder = '[insert path]';

specs = dir(fullfile(input_folder, '*.png'));

for i = 1:length(specs)

    file_name = specs(i).name;
    file_path = fullfile(input_folder, file_name);

    image = imread(file_path); % read image from path
    cropped_image = imcrop(image, [154, 75, 902, 704]); % crop image to remove the white borders

    cropped_image_save_path = fullfile(output_folder, strcat(file_name(1:end-4), '.png')); % output folder
    imwrite(cropped_image, cropped_image_save_path) % save the cropped image
end
