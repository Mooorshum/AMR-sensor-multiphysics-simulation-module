function film_mask = get_film_mask(filename_mag_data)
warning('off')
filename = strcat(filename_mag_data); % getting mumax3 output file
data = omf2matlab(filename); % importing mumax3 .ovf data to matlab
m_data.mx = data.datax;
m_data.my = data.datay;
m_data.mz = data.dataz;

film_mask = sqrt( m_data.mx.^2 + m_data.my.^2 + m_data.mz.^2 ); % creating a mask of the magnetic medium

end