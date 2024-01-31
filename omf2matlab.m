function [data]=omf2matlab(fileToRead)
% The function imports vector file archives from oommf [1], mumax3 [2]
% Boris [3] into Matlab arrays.
% 
% The file is inspired by H. Corte and his function oommf2matlab.m
% https://mathworks.com/matlabcentral/fileexchange/44187-oommf-vector-data-file-to-matlab-array
% https://thebrickinthesky.wordpress.com/?s=OOMMF
% ChatGPT [4] was used also.
% 
% The main modification: fileToRead is processed with fileread function,
% not line-by-line. It works much faster for large files (100+Mb)
% 
% Oommf vector files must be writen with the output Specifications "text %g"
% instead of the default "binary 4" option.
% And the type of grid must be rectangular.
% In Boris use ns.saveovf2mag('text', output_file, bufferCommand=True)
% https://groups.google.com/g/boris-computational-spintronics/c/B4YLoLqqsvQ
% 
% Vector files will be imported into the object "data" which will have this
% fields (if exist in fileToRead):
%           datax: component x of vector on data file
%           datay: component y of vector on data file
%           dataz: component z of vector on data file
%           time: total simulation time
%           xmin: minimum x value
%           xnodes: number of nodes used along x
%           xmax: maximum x value
%           ymin: minimum y value
%           ynodes: number of nodes used along y
%           ymax: maximum y value
%           zmin: minimum z value
%           znodes: number of nodes used along z
%           zmax: maximum z value
%           positionx: x positions of vectors
%           positiony: y positions of vectors
%           positionz: z positions of vectors
% The number of fields could be extended easily
% 
%   Example: Plot 2D images from all files in directory:
% 
%     %% read file names
%     dir_name = './DirName/';
%     file_extention = '*.ovf'; % .omf is also good
%     f_n = dir([dir_name file_extention]);
%     %% sort files by date
%     [~,idx] = sort([f_n.datenum]);
%     f_n = f_n(idx);
%     fileNames = {f_n.name};    
%     %%
%     mult = 1e6; % switch dimentions to microns
%     for ff = 1:length(fileNames)  
%         dataOMF = oommf2matlab_fileread([dir_name fileNames{ff}]);
%         Xvector = mult* linspace(dataOMF.xmin, dataOMF.xmax, dataOMF.xnodes);
%         Yvector = mult* linspace(dataOMF.ymin, dataOMF.ymax, dataOMF.ynodes);
%         Magn_z = dataOMF.dataz
%         imagesc(Xvector, Yvector, Magn_z');
%         drawnow;
%     end;    
% 
%  References:
%  [1] OOMMF: Object Oriented MicroMagnetic Framework, NIST,
%      http://math.nist.gov/oommf/
%  [2] mumax3, a GPU-accelerated micromagnetic simulation
%      https://mumax.github.io/
%  [3] Boris Computational Spintronics, 
%      Multi-physics magnetisation dynamics and spin transport simulations,
%      http://www.boris-spintronics.uk/
%  [4] ChatGPT https://chat.openai.com/
% 
% This function was written by N. Khokhlov
% https://www.scopus.com/authid/detail.uri?authorId=57213491467
% https://publons.com/researcher/2337219/nikolai-e-khokhlov/
% https://scholar.google.com/citations?user=YKEZQLIAAAAJ&hl=en
% https://www.researchgate.net/profile/N-Khokhlov
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%We open the data file and start reading lines. The first lines are the
%header with information about the simulation. On this version not all the
%information is stracted, but is quite easy to do
file_content = fileread(fileToRead);

%%%% get total simulation time %%%%
pattern = '# Desc:  Total simulation time:\s*([-+]?[\d.]+(?:e[-+]?\d+)?)';
% expression \s*([-+]?[\d.]+(?:e[-+]?\d+)?) returns all numerical values in
% scientific format until the end of the line
matches = regexp(file_content, pattern, 'tokens');
if ~isempty(matches)
    data.time = str2double(matches{1}{1});
end

%%%% Build the grid %%%%
% xmin
pattern = '# xmin:\s*([-+]?[\d.]+(?:e[-+]?\d+)?)';
matches = regexp(file_content, pattern, 'tokens');
if ~isempty(matches)
    data.xmin = str2double(matches{1}{1});
end

%ymin
pattern = '# ymin:\s*([-+]?[\d.]+(?:e[-+]?\d+)?)';
matches = regexp(file_content, pattern, 'tokens');
if ~isempty(matches)
    data.ymin = str2double(matches{1}{1});
end

%zmin
pattern = '# zmin:\s*([-+]?[\d.]+(?:e[-+]?\d+)?)';
matches = regexp(file_content, pattern, 'tokens');
if ~isempty(matches)
    data.zmin = str2double(matches{1}{1});
end

% xmax
pattern = '# xmax:\s*([-+]?[\d.]+(?:e[-+]?\d+)?)';
matches = regexp(file_content, pattern, 'tokens');
if ~isempty(matches)
    data.xmax = str2double(matches{1}{1});
end

%ymax
pattern = '# ymax:\s([-+]?[\d.]+(?:e[-+]?\d+)?)';
matches = regexp(file_content, pattern, 'tokens');
if ~isempty(matches)
    data.ymax = str2double(matches{1}{1});
end

%zmax
pattern = '# zmax:\s([-+]?[\d.]+(?:e[-+]?\d+)?)';
matches = regexp(file_content, pattern, 'tokens');
if ~isempty(matches)
    data.zmax = str2double(matches{1}{1});
end

%xnodes
pattern = '# xnodes:\s([-+]?[\d.]+(?:e[-+]?\d+)?)';
matches = regexp(file_content, pattern, 'tokens');
if ~isempty(matches)
    data.xnodes = str2double(matches{1}{1});
end

%ynodes
pattern = '# ynodes:\s([-+]?[\d.]+(?:e[-+]?\d+)?)';
matches = regexp(file_content, pattern, 'tokens');
if ~isempty(matches)
    data.ynodes = str2double(matches{1}{1});
end

%znodes
pattern = '# znodes:\s([-+]?[\d.]+(?:e[-+]?\d+)?)';
matches = regexp(file_content, pattern, 'tokens');
if ~isempty(matches)
    data.znodes = str2double(matches{1}{1});
end

%We have already the data about the grid, size and number of nodes,
%thus we can create the arrays containing the coordinates of the points on the
%grid. It is necesary here that the simulation grid is rectangular.
x=linspace(data.xmin, data.xmax, data.xnodes);
y=linspace(data.ymin, data.ymax, data.ynodes);
z=linspace(data.zmin, data.zmax, data.znodes);
[X,Y,Z] = meshgrid(x,y,z);
data.datax =0.*permute(X,[2,1,3]);%Gives the proper size to datax
data.datay =0.*permute(Y,[2,1,3]);%Gives the proper size to datay
data.dataz =0.*permute(Z,[2,1,3]);%Gives the proper size to dataz
data.positionx =permute(X,[2,1,3]);
data.positiony =permute(Y,[2,1,3]);
data.positionz =permute(Z,[2,1,3]);

%%%% bulding 2d arrays of components x,y,z %%%%
% Search the data between "# Begin: data text" and "# End: data text"
start_pattern = '# Begin: Data Text';
end_pattern = '# End: Data Text';
start_idx = regexp(file_content, start_pattern, 'end');
end_idx = regexp(file_content, end_pattern, 'start');

if isempty(start_idx) && isempty(end_idx)
    start_pattern = '# Begin: data text';
    end_pattern = '# End: data text';
    start_idx = regexp(file_content, start_pattern, 'end');
    end_idx = regexp(file_content, end_pattern, 'start');
end

if ~isempty(start_idx) && ~isempty(end_idx)
    % get the data between the strings
    data_section = file_content(start_idx+1:end_idx-1);
    
    s=textscan(data_section,'%f \t%f \t%f');
    S=cell2mat(s);
    data.datax(:)=S(:,1);
    data.datay(:)=S(:,2);
    data.dataz(:)=S(:,3);
end

end