function sweep_data = calc_Vout(d_cond, rho0, rho_cond, MR_ratio, V1, V2, plot_E, plot_V, mumax_script_filename, mag_data_folder, FM_image_filename, COND_image_filename, CONTACTS_image_filename, save_location)

% Extracting variable values from mumax script
[d_cell, nx, ny, nz, H_range] = extract_variables(mumax_script_filename);

% Resizing the original images to match the magnetic data resolution
FM_resized_1_4 = resize_image(FM_image_filename, nx, ny);
COND_resized_1_4 = resize_image(COND_image_filename, nx, ny);
CONTACTS_resized_1_4 = resize_image(CONTACTS_image_filename, nx, ny);
FM_resized_2_3 = flipdim(resize_image(FM_image_filename, nx, ny), 2);
COND_resized_2_3 = flipdim(resize_image(COND_image_filename, nx, ny), 2);
CONTACTS_resized_2_3 = flipdim(resize_image(CONTACTS_image_filename, nx, ny), 2);

% Generating the magnetic film geometry from images (without the conductive layer)
film_geometry_1_4 = get_geometry_matrix(FM_resized_1_4,COND_resized_1_4);
film_geometry_2_3 = get_geometry_matrix(FM_resized_2_3,COND_resized_2_3);

% Getting CellID of conductive cells and FaceID of contact points
[FM_cell_ids_1_4, COND_extrude_ids_1_4, COND_cell_ids_1_4, CONTACT_point_ids_1_4] = get_geometry_ids(film_geometry_1_4, COND_resized_1_4, CONTACTS_resized_1_4);
[FM_cell_ids_2_3, COND_extrude_ids_2_3, COND_cell_ids_2_3, CONTACT_point_ids_2_3] = get_geometry_ids(film_geometry_2_3, COND_resized_2_3, CONTACTS_resized_2_3);




% Solving PDE for given .png geometry
for i = 1:length(H_range)
    disp('****************************************************************');
    disp(strcat('*** Step: ', num2str(i),'/',num2str(length(H_range)),' ***'));
    filename_mag_data = strcat(mag_data_folder,'mag_data_',num2str(i),'.ovf');
    disp('* Films 1 and 4: *');
    [Ex_1_4, Ey_1_4, Ez_1_4, rho_1_4] = solve_electrostatic_system_for_png_geometry(d_cell, d_cond, rho0, rho_cond, MR_ratio, V1, V2, FM_cell_ids_1_4, COND_extrude_ids_1_4, CONTACT_point_ids_1_4, COND_cell_ids_1_4, film_geometry_1_4, filename_mag_data, nx, ny, nz, plot_E);
    disp('* Films 2 and 3: *');
    [Ex_2_3, Ey_2_3, Ez_2_3, rho_2_3] = solve_electrostatic_system_for_png_geometry(d_cell, d_cond, rho0, rho_cond, MR_ratio, V1, V2, FM_cell_ids_2_3, COND_extrude_ids_2_3, CONTACT_point_ids_2_3, COND_cell_ids_2_3, film_geometry_2_3, filename_mag_data, nx, ny, nz, plot_E);
    
    sweep_data(i).Ex_1_4 = Ex_1_4;
    sweep_data(i).Ey_1_4 = Ey_1_4;
    sweep_data(i).Ez_1_4 = Ez_1_4;
    sweep_data(i).Ex_2_3 = Ex_2_3;
    sweep_data(i).Ey_2_3 = Ey_2_3;
    sweep_data(i).Ez_2_3 = Ez_2_3;
    sweep_data(i).rho_1_4 = rho_1_4;
    sweep_data(i).rho_2_3 = rho_2_3;
    sweep_data(i).rho_mean_1_4 = mean(nonzeros(rho_1_4), "all");
    sweep_data(i).rho_mean_2_3 = mean(nonzeros(rho_2_3), "all");
    sweep_data(i).H_range = H_range(i);
    sweep_data(i).V_out = (V2-V1)*(sweep_data(i).rho_mean_2_3  - sweep_data(i).rho_mean_1_4)/(sweep_data(i).rho_mean_2_3  + sweep_data(i).rho_mean_1_4);
    
    V_plot(i) = sweep_data(i).V_out;
    rho_plot_1_4(i) = sweep_data(i).rho_mean_1_4;
    rho_plot_2_3(i) = sweep_data(i).rho_mean_2_3;
    H_plot(i) = H_range(i);
end
save(fullfile(save_location, 'Field_sweep_data.mat'), 'sweep_data');

% Plotting results
if plot_V == true
    figure;
    hold on;
    plot(H_plot, V_plot);
    hold off;
    xlabel('Hext, T')
    ylabel('Vout, V')
    title('Vout(Hext)');
    grid on;
    saveas(gcf, fullfile(save_location, 'Vout_Hext.png'));
    saveas(gcf, fullfile(save_location, 'Vout_Hext.fig'));

    % figure;
    % hold on;
    % plot(H_plot, rho_plot_1_4);
    % plot(H_plot, rho_plot_2_3);
    % hold off;
    % xlabel('Hext, T')
    % ylabel('rho, Ohms')
    % grid on;

end









end





