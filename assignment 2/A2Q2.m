%Aina Jauhara
%ELC4630 Assignment 2 MRI 

clc ; 
clear all;
close all;

%%Read Image 

img = {};

img{1} = imread ('1.png');
img{2} = imread ('2.png');
img{3} = imread ('3.png');
img{4} = imread ('4.png');
img{5} = imread ('5.png');
img{6} = imread ('6.png');
img{7} = imread ('7.png');
img{8} = imread ('8.png');
img{9} = imread ('9.png');
img{10} = imread ('10.png');
img{11} = imread ('11.png');
img{12} = imread ('12.png');
img{13} = imread ('13.png');
img{14} = imread ('14.png');
img{15} = imread ('15.png');
img{16} = imread ('16.png');

%%Pre Processing
h = {};
for j = 1:length(img)
    h{j} = adapthisteq(img{j},'clipLimit',0.3);
    h{j} = imsharpen(h{j},'Radius', 10 , 'Amount' , 1);
    %h{j} = imgaussfilt(h{j}, 5);
    %mri4{j} = edge (mri3{j}, 'canny');
    %figure , imshow(h{j});
end

mid = round(size(h{1}/2));
mid = [mid(2), mid(1)];
cirSize = 100; 

%Coordinate around circle 

cirx = [];
ciry = [];

for deg = 0:15:360
    cirx = [cirx; (mid(1)+cirSize*cosd(deg))];
    ciry = [ciry; (mid(2)+cirSize*sind(deg))];
end

%Coordinate inside the circle

fillx = [];
filly = [];
numpoints = 30;

for j = 1:size(cirx)
    tempx = [];
    tempy = [];
    [tempx , tempy] = filllline(mid, [cirx(j), ciry(j)], numpoints);
    fillx = [fillx ; tempx];
    filly = [filly ; tempy];
end

%Show Trellis 

mri = h{1};
trel = []; 

for i = 1:size(cirx)
        for j = 1:size(fillx,2)
                c = fillx(i,j);
                r = filly(i,j);
                b = mri(floor(r),floor(c));
                trel(j,i) = b;
        end
end

trel = struct('depth',trel,'length',size(trel,1),'width',size(trel,2));
trel.e = edge(uint8(trel.d), ' canny');
imshow (imresize(uint8(trel.e),4));
             




