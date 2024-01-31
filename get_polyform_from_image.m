function polyforms = get_polyform_from_image(image)
warning('off')
% Convert to binary image if necessary
if size(image, 3) == 3
    image = rgb2gray(image);
end

% Convert to binary image (0 for white, 1 for black)
bw_image = imbinarize(image);

% Invert the binary image so that black regions become white and vice versa
bw_image_inverted = ~bw_image;

% Find boundaries of black regions
boundaries = bwboundaries(bw_image_inverted);

for k = 1:length(boundaries)
    boundary = boundaries{k};
    % Create a polygon from the boundary coordinates
    polyform = polyshape(boundary(:,2), boundary(:,1));
    % Store the polyform
    polyforms(k) = polyform;
end

