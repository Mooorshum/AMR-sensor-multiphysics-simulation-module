function [Ex, Ey, Ez, rho] = solve_electrostatic_system_for_png_geometry(d_cell, d_cond, rho0, rho_cond, MR_ratio, V1, V2, FM_cell_ids, COND_extrude_ids, CONTACT_point_ids, COND_cell_ids, film_geometry, filename_mag_data, nx, ny, nz, plot_E)

    % Creating PDE model and geometry for electrostatic analysis
    model = createpde();
    geometryFromEdges(model,film_geometry);
    model.Geometry = extrude(model.Geometry,nz);
    model.Geometry = scale(model.Geometry, d_cell);
    model.Geometry = extrude(model.Geometry, COND_extrude_ids, d_cond);

    film_mask = rot90(get_film_mask(filename_mag_data));

    % Generating mesh 
    generateMesh(model);


    % Specifying pde coefficients
    sigma_FM = 1/rho0;
    sigma_COND = 1/rho_cond;


    specifyCoefficients(model,'m',0, 'd',0, 'c',-sigma_FM, 'a',0, 'f',0, 'Cell',FM_cell_ids);
    specifyCoefficients(model,'m',0, 'd',0, 'c',-sigma_COND, 'a',0, 'f',0, 'Cell',COND_cell_ids);

    % Setting Dirichlet boundary conditions for Voltage
    applyBoundaryCondition(model,'dirichlet','Face',CONTACT_point_ids(1),'u',V1);
    applyBoundaryCondition(model,'dirichlet','Face',CONTACT_point_ids(2),'u',V2);


    % Solving pde 
    disp('Solving electrostatic system for V ...');
    V = solvepde(model);
    disp('Found solution for V!');


    % Interpolating solution for micromagnetic grid
    disp('Calculating E at grid nodes ...');
    [X, Y, Z] = meshgrid(d_cell:d_cell:nx*d_cell, d_cell:d_cell:ny*d_cell, d_cell:d_cell:nz*d_cell);
    [Ex,Ey,Ez] = evaluateGradient(V,X,Y,Z);
    Ex = reshape(Ex,size(X));
    Ey = reshape(Ey,size(Y));
    Ez = reshape(Ez,size(Z));
    disp('E calculated!');


    % Calculating resistivity distribution
    filename = strcat(filename_mag_data); % getting mumax3 output file
    data = omf2matlab(filename); % importing mumax3 .ovf data to matlab
    mx = rot90(data.datax);
    my = rot90(data.datay);
    mz = rot90(data.dataz);
    disp('Calculating rho of magnetic cells ...');
    rho = zeros([ny nx nz]);
    for i = 1:ny
        for j = 1:nx
            for k = 1:nz
                if (film_mask(i,j,k) > 0.99) && ~isnan(Ex(i,j,k)) && ~isnan(Ey(i,j,k)) && ~isnan(Ez(i,j,k))
                    angle_m_j = acos( (Ex(i,j,k)*mx(i,j,k) + Ey(i,j,k)*my(i,j,k) + Ez(i,j,k)*mz(i,j,k)) / ( sqrt(Ex(i,j,k)^2+Ey(i,j,k)^2+Ez(i,j,k)^2)*sqrt(mx(i,j,k)^2+my(i,j,k)^2+mz(i,j,k)^2)  ));
                    rho(i,j,k) = rho0*(1 - MR_ratio*(sin(angle_m_j)^2));
                end
            end
        end
    end
    rho = rot90(rho);
    disp('rho calculated!');

    % Plotting E field vectors
    if plot_E == true
        % % Downsampling meshgrid and vector component matrices
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

    end

end