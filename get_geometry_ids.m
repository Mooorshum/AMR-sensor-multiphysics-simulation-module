function [FM_cell_ids, COND_extrude_ids, COND_cell_ids, CONTACT_point_ids] = get_geometry_ids(film_geometry, image_COND, image_CONTACTS)
    
    warning('off')

    % Initializing normalized geometry
    model = createpde();
    geometryFromEdges(model,film_geometry);
    model.Geometry = extrude(model.Geometry,1);

    % Getting conductive face ids at surface of magnetic film
    poly_COND = get_polyform_from_image(image_COND); % Getting conductive layer polyshapes from image
    % Looping through each polyshape to get coordinates of it's centre
    for i = 1:length(poly_COND)
        [x,y] = centroid(poly_COND(i)); % Getting centre of single polyshape
        COND_extrude_ids(i) = nearestFace(model.Geometry, [x,y,1]); % Locating face closest to polycell centre
    end

    % Getting conductive cells ids on top of magnetic film
    cell_count_FM_only = model.Geometry.NumCells; % Number of cells before extrusion
    model.Geometry = extrude(model.Geometry, COND_extrude_ids, 10); % Creating conductive layer on top of magnetic film
    % Looping through new cells
    for i = 1:(model.Geometry.NumCells-cell_count_FM_only)
        COND_cell_ids(i) = cell_count_FM_only + i;
    end

    % Getting contact point face ids
    poly_CONTACT = get_polyform_from_image(image_CONTACTS); 
    % Looping through each polyshape to get coordinates of it's centre
    for i = 1:length(poly_CONTACT)
        [x,y] = centroid(poly_CONTACT(i)); % Getting centre of single polyshape
        CONTACT_point_ids(i) = nearestFace(model.Geometry, [x,y,1+10]); % Locating face closest to polycell centre
    end

    % Getting cell ids of ferromagnetic medium
    for i = 1:cell_count_FM_only
        FM_cell_ids(i) = i;
    end

end

