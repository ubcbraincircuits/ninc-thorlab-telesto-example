%% This section unzips the oct data folders.

%update this variable for the particular experiment to be analyzed
the_folder='C:\OCTData\C57_October5_OCT-26_SWELLING\';

listing=dir([the_folder '*Mode3D.oct']);


for i=1:numel(listing)
   unzip_folder=listing(i).name(1:end-4);
   unzip([the_folder listing(i).name],[the_folder unzip_folder])
   disp(['     >Unzipping file: ' listing(i).name]);
end



%% read in the data
%notes...
unzip_folder=listing(1).name(1:end-4);
header_path=[the_folder unzip_folder '\'];
head_oct = xml2struct([header_path, 'Header.xml']);

% %This was from Leann but it stopped working.
% n_x=str2num(head_oct.Ocity.Image.SizePixel.SizeX.Text);
% n_y=str2num(head_oct.Ocity.Image.SizePixel.SizeY.Text);
% n_z=str2num(head_oct.Ocity.Image.SizePixel.SizeZ.Text);

%  With Ray we found the same information in a different place in the XML
n_x=str2num(head_oct.Children(2).Children(6).Attributes(5).Value);
n_y=str2num(head_oct.Children(2).Children(6).Attributes(6).Value);
n_z=str2num(head_oct.Children(2).Children(6).Attributes(7).Value);
%make a matrix to store all the data.

best_plane=88;
range_slices=best_plane-6:best_plane+6;
n_files=numel(listing);

dat=zeros(n_files,n_z,n_x,numel(range_slices));

for i=1:n_files
    unzip_folder=listing(i).name(1:end-4);
    fid=fopen([the_folder unzip_folder '\data\Intensity.data'],'r');
    tmp=fread(fid,'float32');
    fclose(fid);
    tmp=reshape(tmp,[n_z,n_x,n_y]);
    
    dat(i,:,:,:)=tmp(:,:,range_slices);
    disp(['     >Reading file: ' listing(i).name]);
end

% %% do some plots, etc
% 
% hFig = figure;
% set(hFig, 'Position', [0 0 n_x n_z])
% clims=[35 60];
% imagesc(squeeze(mean(dat(10,:,:,:),4)),clims)
% colormap(gray)

%% average over the range of slices and save a movie

dat=mean(dat,4);
dat=permute(dat,[2 3 1]);
fid=fopen('C57_October5_OCT-26_SWELLING_03-031.raw','w','b');
fwrite(fid,dat,'float32');
fclose(fid);

