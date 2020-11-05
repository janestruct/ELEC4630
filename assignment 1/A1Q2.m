%Aina Jauhara
%ELC4630 Assignment 1 Q1

clc;
clear all;
close all;

v = VideoReader ('Eric.mov');

while hasFrame(v)
    video = readFrame(v);
end
whos video

vidHeight = v.Height;
vidWidth = v.Width;

currAxes = axes;
while hasFrame(v)
    vidFrame = readFrame(v);
    image(vidFrame,'Parent', currAxes);
    currAxes.Visible = 'off';
    pause(1/v.FrameRate);
end

mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),'colormap',[]);