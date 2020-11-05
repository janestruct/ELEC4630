%Aina Jauhara
%ELC4630 Assignment 1 Q1

clc;
clear all;
close all;

%Read Image
title('car 1');
Im = imread('numberplates/car2.jpg');
figure,imshow(Im);
title('Colour Image');

%Convert into Grayscale image
Im2 = rgb2gray(Im);
figure, imshow(Im2);
title('Grayscale Image');

Imcanny = edge(Im2,'Canny');
figure, imshow(Imcanny);
title('Car Canny Grayscale Image');

I = imcrop(Im2);

Imcanny = edge(I,'Canny');
figure, imshow(Imcanny);
title('Number Plate Canny Grayscale Image');

imgPath = 'template/';
imgType = '*.png';
images = dir([imgPath imgType]);

for idx = 1:length(images)
    
    Seq{idx} = imread([imgPath images(idx).name]);
    Seq2{idx} = rgb2gray(Seq{idx});
    
    Out1 = xcorr2(im2double(Imcanny), im2double(Seq2{idx}));
    figure, imshow(Out1/max(max(Out1)));
end

    bestLetter = Seq{idx};
    bestVal = max(max(Out1));
    templateNum = idx;
    
