function [d_cell, nx, ny, nz, H_range] = extract_variables(mumax_script_filename)
% Extracting variable values using regular expressions
fid = fopen(mumax_script_filename, 'r'); % Open the script file for reading
fileContent = fscanf(fid, '%c'); % Read the file content
fclose(fid); % Close the file

d_cellPattern = 'd_cell\s*:=\s*(-?\d*\.?\d*(?:e-?\d+)?)';
d_cellMatch = regexp(fileContent, d_cellPattern, 'tokens', 'once');
d_cell = str2double(d_cellMatch{1});

H_minPattern = 'Bmin\s*:=\s*(-?\d*\.?\d*(?:e-?\d+)?)';
H_minMatch = regexp(fileContent, H_minPattern, 'tokens', 'once');
H_min = str2double(H_minMatch{1});

H_stepPattern = 'Bstep\s*:=\s*(-?\d*\.?\d*(?:e-?\d+)?)';
H_stepMatch = regexp(fileContent, H_stepPattern, 'tokens', 'once');
H_step = str2double(H_stepMatch{1});

H_maxPattern = 'Bmax\s*:=\s*(-?\d*\.?\d*(?:e-?\d+)?)';
H_maxMatch = regexp(fileContent, H_maxPattern, 'tokens', 'once');
H_max = str2double(H_maxMatch{1});

nxPattern = 'cell_count_x\s*:=\s*(-?\d+)';
nxMatch = regexp(fileContent, nxPattern, 'tokens', 'once');
nx = str2double(nxMatch{1});

nyPattern = 'cell_count_y\s*:=\s*(-?\d+)';
nyMatch = regexp(fileContent, nyPattern, 'tokens', 'once');
ny = str2double(nyMatch{1});

nzPattern = 'cell_count_z\s*:=\s*(-?\d+)';
nzMatch = regexp(fileContent, nzPattern, 'tokens', 'once');
nz = str2double(nzMatch{1});

H_range = H_min:H_step:(H_max-H_step);
end

