
%Aina Jauhara 
%ELEC4630 Assignment 4 Q2

close all, 
clear,
clc

%% Image Pre Processing 


imgType = '*.bmp'; 
addpath('faces');
for j = 1:6
    imgPath = ['Faces/' int2str(j) '/'];
    images  = dir([imgPath imgType]);
    for idx = 1:length(images)
        [img, map] = imread([imgPath images(idx).name], 'bmp');
        f{j}{idx}.img = im2double(rgb2gray(ind2rgb(img, map)));
    end
end


% Include training face

imgType = '*.bmp'; 
addpath('faces');
images  = dir(['Faces/eig/' imgType]);
for idx = 1:length(images)
    
    [i,m] = imread(['Faces/eig/' images(idx).name], 'bmp');
    tmp = im2double(rgb2gray( ind2rgb(i, m)));
    trn(:,:,idx) = tmp;
    
end


%Compute the image difference

[h,w,d] = size(trn); 
n = h*w;
trn = reshape(trn,[n d]);
m = mean(trn,2);
for i = 1:length(images)
    dif(:,i) = trn(:,i) - m; 
end



[U,S,V] = svd(dif);

s = max(S);

for i=1:length(images) 
    
    tmp = (dif*V);
    u(:,i) = (1/s(1,i)).* tmp(:,i);
end

wght = u'*dif; % find  weights
faces={};
for i=1:length(images), 
    faces{i} = reshape(u(:,i), [h,w]);
    tmp = faces{i};
    t_min = min(min(tmp));
    tmp = tmp-t_min;
    t_max = max(max(tmp));
    tmp = (tmp)./t_max;
    figure, imshow(tmp);

end



face = 4;
disp(['Reconstructed face :' int2str(face)])
re = m;
for i = 1:length(images)
    weighting = wght(i,face);
    re = re + weighting * u(:,i);
    figure, imshow(reshape(re, [h,w]))
end
re = reshape(re, [h,w]);

imshow(re)




clearvars -except f wght S s U u V m trn

disp('Proceeding to match all previously loaded images to training faces')
totalCount = 0;
correctCount = 0;
for person = 1:length(f)
    for face = 1:length(f{person}) 
        totalCount = totalCount+1;
        
        img = f{person}{face}.img;
        [h,w,d] = size(img); n = h*w;
        i = reshape(img, [n d]);
        i = i-m;                   
        
        wi = u'*i;                  % compute the weight
        f{person}{face}.w = wi;

        
        
        for tface = 1:size(wght,2)
            dif(tface) = sum((wght(:,tface) - wi).^2);
        end
        
        match = find(dif==min(dif));
        f{person}{face}.d = dif;
        
        str = ['Person ' int2str(person) '''s picture :' int2str(face) 'matches training face :' int2str(match) ' with ' sprintf('%f', min(dif)) ' difference'];
        
        disp(str)
        
        if (match == person), correctCount = correctCount+1; 
        else
         
            disp(['     The distance between this and the correct face was: ' sprintf('%f', dif(person))])
        end
        
    end
    disp('.')
end
disp(['Match Percentage : ' sprintf('%f', correctCount/totalCount*100)]);



res = questdlg('Would you like to load a different picture?');
if (strcmp('Yes', res))
while(1)
    
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
    
    for tface = 1:size(wght,2)
        dif(tface) = sum((wght(:,tface) - wi).^2);
    end
    match = find(dif==min(dif));
    
    disp(['Your picture was matched to the other face in the figure with a distance of ' sprintf('%f',min(dif))])
    figure, subplot(1,2,1), imshow(rgb2gray(ind2rgb(picked, map)));
            subplot(1,2,2), imshow(reshape(trn(:,match), [h,w]));
    
    res = questdlg('Would you like to load another picture for analysis?');
    if (strcmp('No', res)), break; end
    if (strcmp('Cancel', res)), break; end
end
end
