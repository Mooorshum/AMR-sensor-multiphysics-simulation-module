function result = get_geometry_matrix(image_FM,image_COND)


%% Generating polyshapes of magnetic and conductive layers
poly_FM = get_polyform_from_image(image_FM);
poly_COND = get_polyform_from_image(image_COND);



%% Constructive Solid Geometry (CSG) of magnetic and conductive layers to
% form a single PDE geometry

% Getting magnetic layer vertex representation
start_X_FM = poly_FM.Vertices(:,1);
start_Y_FM = poly_FM.Vertices(:,2);
FM.shape = [2
    size(poly_FM.Vertices,1)
    start_X_FM
    start_Y_FM];
length_max = 0;
for i = 1:length(poly_COND)
    length_max_current = length(poly_COND(i).Vertices);
    if length_max_current > length_max
        length_max = length_max_current;
    end
end
length_max = length_max*2+2;
FM.shape = [FM.shape; zeros(length_max - length(FM.shape),1)];
gd = [FM.shape];
ns = char('film');

% Iteratively adding each conductive region to the film
all_cond_str = ns;
for i = 1:length(poly_COND)
    start_X_COND = poly_COND(i).Vertices(:,1);
    start_Y_COND = poly_COND(i).Vertices(:,2);
    COND(i).shape = [2
        size(poly_COND(i).Vertices,1)
        start_X_COND
        start_Y_COND];
    COND(i).shape = [COND(i).shape; zeros(length(FM.shape) - length(COND(i).shape),1)];
    gd = [gd, COND(i).shape];
    ns = char(ns, strcat('cond',num2str(i)));
    cond_str = strcat('cond',num2str(i));
    all_cond_str = strcat(all_cond_str, '+', cond_str);
end
ns = ns';
sf = all_cond_str;

result = decsg(gd,sf,ns);


end

