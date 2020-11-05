% Script made by s4262468 as the solution to part 2 of the 4th assessment
% task of ELEC4630

close all, clear, clc

% Load all the images from all the folders
disp('load the faces')
imgType = '*.bmp'; % change based on image type
addpath('faces');
for j = 1:6, 
    imgPath = ['Faces/' int2str(j) '/'];
    images  = dir([imgPath imgType]);
    for idx = 1:length(images)
        [img, map] = imread([imgPath images(idx).name], 'bmp');
        f{j}{idx}.img = im2double(rgb2gray(ind2rgb(img, map)));
    end
end
disp('...done')


% Load training face
imgType = '*.bmp'; %Image are in bmp format.
addpath('faces');
images  = dir(['Faces/eig/' imgType]);
for idx = 1:length(images)
    [i,m] = imread(['Faces/eig/' images(idx).name], 'bmp');
    tmp = im2double(rgb2gray( ind2rgb(i, m)));
    trn(:,:,idx) = tmp;
end



disp('Find difference images')
[h,w,d] = size(trn); n = h*w;
trn = reshape(trn,[n d]);
m = mean(trn,2);
for i = 1:length(images), dif(:,i) = trn(:,i) - m; end
disp('...done')

disp('Covariance time and eigenfaces')
[U,S,V] = svd(dif);

s = max(S);
for i=1:length(images), 
    tmp = (dif*V);
    u(:,i) = (1/s(1,i)).* tmp(:,i);
end

wght = u'*dif; % find the weights
faces={};
for i=1:length(images), 
    faces{i} = reshape(u(:,i), [h,w]);
    tmp = faces{i};
    t_min = min(min(tmp));
    tmp = tmp-t_min;
    t_max = max(max(tmp));
    tmp = (tmp)./t_max;
    figure, imshow(tmp);
%     imwrite(tmp, ['eig' int2str(i) '.png'])
end

%Reconstructing of the face
faces = 4;
disp(['Face reconstrution#' int2str(faces)])
re = m;
for i = 1:length(images),
    weighting = wght(i,faces);
    re = re + weighting * u(:,i);
    figure, imshow(reshape(re, [h,w]))
end
re = reshape(re, [h,w]);

figure,imshow(re);
title('Reconstruction of faces')

clearvars -except f wght S s U u V m trn

%Matching the images to one another
totalCount = 0;
correctCount = 0;
for person = 1:length(f), 
    for faces = 1:length(f{person}), 
        totalCount = totalCount+1;
        
        img = f{person}{faces}.img;
        [h,w,d] = size(img); n = h*w;
        i = reshape(img, [n d]);
        % Difference vector operation
        i = i-m; 
        
        %Weight of the images
        wi = u'*i; 
        f{person}{faces}.w = wi;

        
        
        for tface = 1:size(wght,2),
            dif(tface) = sum((wght(:,tface) - wi).^2);
        end
        
        matchs = find(dif==min(dif));
        f{person}{faces}.d = dif;
        
        str = ['Person' int2str(person) '''s picture #' int2str(faces) ...
            ' matches training face #' int2str(matchs) ' with ' sprintf('%f', min(dif)) ' difference'];
        
        disp(str)
        
        if (matchs == person), correctCount = correctCount+1; 
        else
          
            disp(['     The distance between this and the correct face was: ' sprintf('%f', dif(person))])
        end
        
    end
    disp('.')
end
disp(['Percentage match: ' sprintf('%f', correctCount/totalCount*100)]);

disp('...done')

res = questdlg('Would you like to load a different picture?');
if (strcmp('Yes', res)),
while(1),
    close all
    disp('Opening dialog for checking of specific files')
    [filename, pathname, filterindex] = uigetfile('*.*', 'Load a picture to check against');
    [picked, map] = imread([pathname filename]);
    i = im2double(rgb2gray(ind2rgb(picked, map)));
    disp('Loaded picture')

    [h,w,d] = size(i); n = h*w;
    i = reshape(i, [n d]);
    i = i-m; % get the difference vector
    wi = u'*i; % the weights
    
    for tface = 1:size(wght,2),
        dif(tface) = sum((wght(:,tface) - wi).^2);
    end
    matchs = find(dif==min(dif));
    
    disp(['Your picture was matched to the other face in the figure with a distance of ' sprintf('%f',min(dif))])
    figure, subplot(1,2,1), imshow(rgb2gray(ind2rgb(picked, map)));
            subplot(1,2,2), imshow(reshape(trn(:,matchs), [h,w]));
    
    res = questdlg('Would you like to load another picture for analysis?');
    if (strcmp('No', res)), break; end
    if (strcmp('Cancel', res)), break; end
end
end
disp('...finished face detection script')