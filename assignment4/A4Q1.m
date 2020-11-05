
%Aina Jauhara 
%ELEC4630 Assignment 4 Q1



close all, 
clear, 
clc

%% Image Pre Processing

imgType = '*.jpg'; 
addpath('dino');
imgPath = ['dino/'];
images  = dir([imgPath imgType]);

for idx = 1:length(images)
    
    [img, map] = imread([imgPath images(idx).name], 'jpg');
    cam{idx}.img = im2double(img);
end


Dino_projection_matrices()              %include projection matrix
for idx = 1:length(images)
    
    cam{idx}.p = eval(['P' int2str(idx-1)]);
    
end

clearvars -except cam


disp('Dinosaur outline for cut out')
for i = 1:length(cam)
    
    t = rgb2hsv(cam{i}.img);
    cam{i}.cut = t(:,:,1)>0.7 | t(:,:,1)<0.3; %cut out border
    cam{i}.cut = imclearborder(cam{i}.cut);   %clear border
    cam{i}.cut = imfill(cam{i}.cut, 'holes'); 

end

% Carving Setup 

minX = -180; 
maxX = 90;
minY = -80; 
maxY = 70;
minZ = 20; 
maxZ = 460;


vol = dist(minX,maxX) * dist(minY,maxY) * dist(minZ,maxZ);      %calculate volumetric geometry

numVox = vol/5;                         %voxels
V.res = (vol/numVox)^(1/3);


x = minX:V.res:maxX;                %create meshgrid
y = minY:V.res:maxY;
z = minZ:V.res:maxZ;

[V.X, V.Y, V.Z] = meshgrid(x, y, z); 
V.val = ones(numel(V.X),1);         %carving parameter

%% Carving Process

for i = 1:length(cam)
    
    
    c = cam{i}; 
    
    z = c.p(3,1) * V.X + c.p(3,2) * V.Y + c.p(3,3) * V.Z + c.p(3,4);

    yplane = round((c.p(2,1) * V.X + c.p(2,2) * V.Y + c.p(2,3) * V.Z + c.p(2,4)) ./ z);

    xplane = round( (c.p(1,1) * V.X + c.p(1,2) * V.Y + c.p(1,3) * V.Z + c.p(1,4)) ./ z);

    % Get rid pixels outside model boundary
    
    [height,weight,depth] = size(c.img);
    point = find( (xplane>=1) & (xplane<=weight) & (yplane>=1) & (yplane<=height) );
    xplane = xplane(point); 
    yplane = yplane(point);
    
    ind = sub2ind([height,weight], round(yplane), round(xplane) );
    point = point(c.cut(ind) >= 1);

    V.X = V.X(point);
    V.Y = V.Y(point);
    V.Z = V.Z(point);
    V.val = V.val(point);
    

end


disp('Preparing to and then printing: ')


uniquex = unique(V.X); uniquey = unique(V.Y); uniquez = unique(V.Z); %voxel grid


uniquex = [uniquex(1)-V.res; uniquex; uniquex(end)+V.res];          %expand model
uniquey = [uniquey(1)-V.res; uniquey; uniquey(end)+V.res];
uniquez = [uniquez(1)-V.res; uniquez; uniquez(end)+V.res];

[X,~,~] = meshgrid( uniquex, uniquey, uniquez );

% Create an empty voxel grid, then fill only those elements in voxels
v = zeros(size(X));

%Flip voxels
for i_i=1:numel(V.X)
    i_x = (uniquex == V.X(i_i));
    i_y = flipud(uniquey == V.Y(i_i));
    i_z = flipud(uniquez == V.Z(i_i));
    v(i_y,i_x,i_z) = V.val(i_i);
end

% Reconstructed Model Plot
figure; p = patch(isosurface(v, 0.5));
set( p, 'FaceColor', 'b', 'EdgeColor', 'none' );
set(gca,'DataAspectRatio',[1 1 1]);
xlabel('X'); ylabel('Y'); zlabel('Z');
view(-140,22); axis('tight')
lighting('gouraud')
camlight(0,22); 
camlight(180,22);












