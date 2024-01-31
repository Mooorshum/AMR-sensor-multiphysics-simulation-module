%% Matlab pdeModeler + Mumax3 AMR sensor silumation module
% Please see the README.txt file for more information

clc;
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Material parameters
rho_cond = 200e-10;
d_cond = 20e-9;
rho0 = 220e-9;
MR_ratio = 0.022;
V1 = 5;
V2 = 0;

% File location folders
mumax_script_filename = 'PNG_MAG.mx3';
mag_data_folder = 'PNG_MAG.out/';
FM_image_filename = 'magnetic_mask.png';
COND_image_filename = 'conductive_mask.png';
CONTACTS_image_filename = 'contacts_mask.png';
save_location = 'Calculations/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating Vout(H)
plot_E = false; % OPTIONAL - Plot the electic field distribution in sample
plot_V = true; % OPTIONAL - Plot the resulting signal
sweep_data = calc_Vout(d_cond, rho0, rho_cond, MR_ratio, V1, V2, plot_E, plot_V, mumax_script_filename, mag_data_folder, FM_image_filename, COND_image_filename, CONTACTS_image_filename, save_location);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualizing the current distribution inside sample for a specific mumax output file
mag_file = 'mag_data_1.ovf';
[Ex, Ey, Ez, rho] = E_field_distrib(d_cond, rho0, rho_cond, MR_ratio, V1, V2, mumax_script_filename, FM_image_filename, COND_image_filename, CONTACTS_image_filename, save_location, mag_data_folder, mag_file);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%