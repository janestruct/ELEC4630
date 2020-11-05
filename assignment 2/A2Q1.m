%Aina Jauhara
%ELC4630 Assignment 2 Taj Mahal

clc ; 
clear all;
close all;

%%Image Processing

%Read Original Image
original = imread('tajmahal.jpg');
figure, imshow(original);
title('Original Taj Mahal');

%Read Segmented Image
taj = imread('taj.png');
figure, imshow(taj) ; 
title ('Segmented Taj Mahal');

%Sharpened Image
tajsharp = imsharpen(taj);
figure, imshow(tajsharp) ;
title ('Sharpen Image');

%Convert to grayscale
tajgrey = rgb2gray (tajsharp) ;
figure, imshow(tajgrey) ;
title ('Grayscale Image');

%Apply Gaussian filter
tajfilter = imgaussfilt(tajgrey,5);
figure, imshow(tajfilter);
title ('Filtered Image');

%Binarize
%tajbin = im2bw (tajgrey,0.55) ;
%figure, imshow(tajbin) ;

%%Edge Detection
%Sobel Edge Detector
tajedge = edge(tajfilter,'Sobel');
figure, imshow(tajedge);
title ('Sobel Edge Detected Image');

%%Hough Transform 
[H,theta,rho] = hough(tajedge,'RhoResolution',4,'Theta',-65:2:65);
peaks  = houghpeaks(H,10);
lines = houghlines(tajedge,theta,rho,peaks,'FillGap',10,'MinLength',150);


% Highlight (by changing color) the lines found by MATLAB
figure, imshow(taj),
hold on
for k = 1:numel(lines)
    x1 = lines(k).point1(1);
    y1 = lines(k).point1(2);
    x2 = lines(k).point2(1);
    y2 = lines(k).point2(2);
    plot([x1 x2],[y1 y2],'Color','g','LineWidth', 2)
end
hold off


% Identify the angles of the lines. 
% The following command shows the angle of the 2nd line found by the Hough
% Transform
lines(1).theta
lines(2).theta





