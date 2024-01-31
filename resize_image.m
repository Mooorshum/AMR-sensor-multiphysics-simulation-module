function resizedImage = resize_image(image_filename, nx, ny)

% Read the original image
originalImage = imread(image_filename); % Provide the path to your original image

% Resize the image
resizedImage = imresize(originalImage, [ny nx]);

end

