%Aina Jauhara
%ELC4630 Assignment 2 Taj Mahal

clc ; 
clear all;
close all;

%%Read Image
taj = imread("tajmahal.jpg");
figure, imshow(taj) ; 
title ('Taj Mahal');

%%Convert to grayscale
tajgrey = rgb2gray (taj) ;
figure, imshow(tajgrey) ;

%%Apply Gaussian filter
tajfilter = imgaussfilt(tajgrey,10);
figure, imshow(tajfilter);

%%Sobel edge detection
tajedge = edge(tajfilter,'Sobel');
figure, imshow(tajedge);


[H,theta,rho] = hough(tajedge,'Theta', 44:1:60); %Theta and Rho value set to default .  [H,T,R] = hough(BW,'Theta',44:0.5:46);
peaks  = houghpeaks(H,4);
lines = houghlines(tajedge,theta,rho,peaks);

subplot(2,1,1);
imshow(taj);
title('tajmahal');
subplot(2,1,2);
imshow(imadjust(rescale(H)),'XData',theta,'YData',rho,'InitialMagnification','fit');
title('Hough transform of tajmahal');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gca,hot);

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
%lines(1).theta
%lines(2).theta






