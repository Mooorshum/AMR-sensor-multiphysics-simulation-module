function [Ex, Ey, Ez, rho] = E_field_distrib(d_cond, rho0, rho_cond, MR_ratio, V1, V2, mumax_script_filename, FM_image_filename, COND_image_filename, CONTACTS_image_filename, save_location, mag_data_folder, mag_file)

% Visualizing the current distribution inside sample
% Extracting variable values from mumax script
[d_cell, nx, ny, nz, ~] = extract_variables(mumax_script_filename);

% Resizing the original images to match the magnetic data resolution
FM_resized = resize_image(FM_image_filename, nx, ny);
COND_resized = resize_image(COND_image_filename, nx, ny);
CONTACTS_resized = resize_image(CONTACTS_image_filename, nx, ny);

% Generating the magnetic film geometry from images (without the conductive layer)
film_geometry = get_geometry_matrix(FM_resized,COND_resized);

% Getting CellID of conductive cells and FaceID of contact points
[FM_cell_ids, COND_extrude_ids, COND_cell_ids, CONTACT_point_ids] = get_geometry_ids(film_geometry, COND_resized, CONTACTS_resized);
[Ex, Ey, Ez, rho] = solve_electrostatic_system_for_png_geometry(d_cell, d_cond, rho0, rho_cond, MR_ratio, V1, V2, FM_cell_ids, COND_extrude_ids, CONTACT_point_ids, COND_cell_ids, film_geometry, strcat(mag_data_folder, mag_file), nx, ny, nz, false);

% Plotting E field vectors
% Recreating PDE model geometry
model = createpde();
geometryFromEdges(model,film_geometry);
model.Geometry = extrude(model.Geometry,nz);
model.Geometry = scale(model.Geometry, d_cell);
model.Geometry = extrude(model.Geometry, COND_extrude_ids, d_cond);
[X, Y, Z] = meshgrid(d_cell:d_cell:nx*d_cell, d_cell:d_cell:ny*d_cell, d_cell:d_cell:nz*d_cell);
% Downsampling meshgrid and vector component matrices
downsample_factor = ny/15;
X_downsampled = X(1:downsample_factor:end, 1:downsample_factor:end, 1:downsample_factor:end);
Y_downsampled = Y(1:downsample_factor:end, 1:downsample_factor:end, 1:downsample_factor:end);
Z_downsampled = Z(1:downsample_factor:end, 1:downsample_factor:end, 1:downsample_factor:end);
Ex_downsampled = Ex(1:downsample_factor:end, 1:downsample_factor:end, 1:downsample_factor:end);
Ey_downsampled = Ey(1:downsample_factor:end, 1:downsample_factor:end, 1:downsample_factor:end);
Ez_downsampled = Ez(1:downsample_factor:end, 1:downsample_factor:end, 1:downsample_factor:end);
% Plotting distribution of electric field throughout the PDE model geometry
disp('Plotting E vectors ...');
figure;
hold on;
% Plotting electric field vectors
quiver3(X_downsampled,Y_downsampled,Z_downsampled, Ex_downsampled,Ey_downsampled,Ez_downsampled, 2, 'Color', 'r');
% Plotting PDE model geometry
pdegplot(model, "FaceAlpha",0.2);
hold off;
xlabel('X');
ylabel('Y');
zlabel('Z');
xlim([-50*d_cell + d_cell, nx*d_cell + 50*d_cell]);
ylim([-50*d_cell + d_cell, ny*d_cell + 50*d_cell]);
zlim([-50*d_cell + d_cell, nz*d_cell + 50*d_cell]);
title('Electric Field Vectors in sample');
view(0, 90);
grid on;
saveas(gcf, fullfile(save_location, strcat('Electric_field_distribution_', mag_file, '.fig')));
saveas(gcf, fullfile(save_location, strcat('Electric_field_distribution_', mag_file, '.png')));

end