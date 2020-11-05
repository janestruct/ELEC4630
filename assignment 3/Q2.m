
%Aina Jauhara
%ELC4630 Assignment 3 Q2 

clc ; 
clear all;
close all;

%  Add Image 
string1 = {struct()};
string2 = {struct()}; 
string3 = {struct()};
addpath('string');
diff = 5 ;

for image = 1:15 
    if image <= 5 
                                      
        string1{image}.o = (rgb2gray(imread(['String1_' int2str(image) '.jpg'])));
    elseif image <= 10 
       
        string2{image-diff}.o = (rgb2gray(imread(['String2_' int2str(image-diff) '.jpg'])));
    else
        
        string3{image-(diff*2)}.o = (rgb2gray(imread(['String3_' int2str(image-(diff*2)) '.jpg'])));
    end
end

% Given String Length
string1{1}.len = 130; 
string2{1}.len = 155;
clc



% Image Segmentation
edge = 3; f = fspecial('gaussian', [500 500], 50);
for image = 1:15 
    if image <= 5 
       
        i = string1{image}.o;
        i = i-(imfilter(i,f));
        [r, c] = ind2sub(size(i), find(edge(i, 'sobel')));
        rmin = min(r)-edge; rmax = max(r)+edge;
        cmin = min(c)-edge; cmax = max(c)+edge;
        
        % Create border for the edge
        
        if rmin<1, rmin=1; 
        end
        if rmax>size(i,1),rmax=size(i,1); 
        end
        if cmin<1, cmin=1; 
        end
        if cmax>size(i,2), cmax=size(i,2); 
        end
        t(:,:) = i(rmin:rmax, cmin:cmax);
        
        string1{image}.p = t;
        
    elseif image <= 10
        
        
        i = string2{image-diff}.o;
        i = i-(imfilter(i,f));
        [r, c] = ind2sub(size(i), find(edge(i, 'sobel')));
        rmin = min(r)-edge; 
        rmax = max(r)+edge; 
        cmin = min(c)-edge; 
        cmax = max(c)+edge;
        
        % Make sure we don't try to go off the edge.
        if rmin<1, rmin=1; 
        end
        if rmax>size(i,1), rmax=size(i,1); 
        end
        if cmin<1, cmin=1; 
        end
        if cmax>size(i,2), cmax=size(i,2); 
        end
        t(:,:) = i(rmin:rmax, cmin:cmax);
        string2{image-diff}.p = t;
    else
        
        i = string3{image-(diff*2)}.o;
        i = i-(imfilter(i,f));
        [r, c] = ind2sub(size(i), find(edge(i, 'sobel', 0.02)));
        rmin = min(r)-edge; 
        rmax = max(r)+edge; 
        cmin = min(c)-edge; 
        cmax = max(c)+edge;
        
        % Make sure we don't try to go off the edge.
        if rmin<1, rmin=1; 
        end
        if rmax>size(i,1), rmax=size(i,1); 
        end
        if cmin<1, cmin=1; 
        end
        if cmax>size(i,2), cmax=size(i,2); 
        end
        t(:,:) = i(rmin:rmax, cmin:cmax);
      
        string3{image-(diff*2)}.p = t;
    end
%      figure, imshow(t);
    clearvars t i
end

% First step is to find the pixel length of the str1&2 in the provided
% pictures
% This then gives us something to go with for the rest of the images

disp('Clear console');

clc ; 
close all;

strings = {string1, string2, string3}; 
for numstr = 1:3
    string = strings{numstr};
    for image = 1:5
        string{image}.bw = imclearborder(~(string{image}.p>30));
        string{image}.bw = string{image}.bw | (edge(string{image}.p, 'sobel'));
        string{image}.bw = bwareaopen(string{image}.bw, 10, 8);
        
        factor = 2;
        string{image}.bw = imresize(string{image}.bw, factor);
        string{image}.bw = imdilate(string{image}.bw, strel('disk', 1));
        string{image}.bw = imresize(string{image}.bw, 1/factor, 'box');
        string{image}.bw = ~bwareaopen(~string{image}.bw, 10, 4);
        
        % Skeletonisation
        skeleton = string{image}.bw;
        el1 = [-1 -1 -1;
                0  1  0;
                1  1  1]; 

        el2 = [0 -1 -1;
               1  1 -1;
               0  1  0];
        el = el1; 
        before = zeros(size(skeleton));
        while(1)
            before = skeleton;
            counter = 8;
            while(1)
                tmp = imerode(skeleton, el==1) & imerode(~skeleton, el==-1);
                skeleton = skeleton & ~logical(tmp);

                % Switch between the 2 rotating elements
                if el==el1 
                    el1 = rot90(el); 
                    el = el2; 
                else
                    el2 = rot90(el); 
                    el = el1; 
                end
                
                counter = counter-1;
                
                % break if we've been through this 8 times
                if counter == 0
                    break; 
                end
            end
            if isequal(before, skeleton) 
                break; 
            end
        end

        % Pruning
        pr1 = [-1 -1 -1; -1  1 -1; -1  0  0]; 

        pr2 = [-1 -1 -1; -1  1 -1; 0  0 -1];
        pr = el1;
        reps = 2; 
        counter = 8;
        while(1)
            tmp = imerode(skeleton,pr==1) & imerode(~skeleton, pr==-1);
            skeleton = skeleton & ~logical(tmp);

            if pr==pr1, pr1 = rot90(pr);
                pr = pr2; 
            else
                pr2 = rot90(pr);
                pr = pr1;
            end

            counter=counter-1;
            if counter==0
                reps=reps-1; 
                counter = 8; 
            end
            if reps==0
                break; 
            end
        end
        
        % Make an image of just "ending" points 
        % and look for closest for joining
        ends = zeros(size(skeleton)); 
        used = ends;
        el = [-1 -1 -1;
              -1  1 -1;
               0  0  0]; 
        
        while(1), r = 4;
            while r>0 % Find the ends
                ends = ends | imerode(skeleton, el==1) & imerode(~skeleton, el==-1);
                el = rot90(el); 
                r=r-1;
            end
            ends = ends & ~used; % ignore the ones we've used already
            % break if we have less than 4 end points
            if size(find(ends),1)<4 
                break; 
            end
            
            % if we have enough, lets connect the 2 points closest to
            % eachother
            [r,c] = ind2sub(size(ends), find(ends));
            closest = struct('d', 1000000);
            for j = 1:size(r,1)
                for k = 1:size(r,1)
                    if j==k 
                        continue, 
                    end
                    d = pdist([r(j) c(j); 
                        r(k) c(k)]);
                    if d<closest.d
                        closest.d = d;
                        closest.a = [r(j) c(j)];
                        closest.b = [r(k) c(k)];
                    end
                end
            end
            % Mark used points
            used(closest.a(1), closest.a(2)) = 1; 
            used(closest.b(1), closest.b(2)) = 1;

            % connect the 2 closest ends for reasons
            skeleton = func_DrawLine(skeleton, closest.a(1), closest.a(2),closest.b(1), closest.b(2),1);
        end
        
        % Count diagonals for Operation: #totes_precise length measurement
        el = [ 0  0 0; % this will trigger for every point that has a 
              -1  1 0; % diagonally adjacent point.
               1 -1 0]; 
        tmp1 = imerode(skeleton, el==1) & imerode(~skeleton, el==-1);
        tmp2 = imerode(skeleton, rot90(el)==1) & imerode(~skeleton, rot90(el)==-1);
        diagCount = size(find(tmp1 | tmp2), 1);
         
         
        numpx = size(find(skeleton),1); 
        if numstr ~= 3 && image == 1 
            string{1}.r = string{1}.len / (diagCount * 2^0.5 + (numpx - diagCount));
            
        %
        elseif numstr == 3 && image == 1 
            string{1}.r = strings{1}{1}.r/2 + strings{2}{1}.r/2;
            string{1}.len = (diagCount * 2^0.5 + (numpx - diagCount)) * string{1}.r;
        else
            string{image}.r = string{1}.r;
            string{image}.len = (diagCount * 2^0.5 + (numpx - diagCount)) * string{image}.r;
        end
        
        t = string{image}.p; 
        t(skeleton)=255;
        figure
        
        subplot(141), 
        imshow(t);
        title(['String' int2str(numstr) '-' int2str(image)]);
        %subplot(142), imshow(string{img}.p);
        subplot(142), imshow(string{image}.bw);  
        title(['Pixel Length: ' int2str(numpx)])
        subplot(144), imshow(skeleton);
        title([' Approximate Length: ' int2str(string{image}.len)]);  
        print(['String' int2str(numstr) '-' int2str(image)], '-djpeg90')
        disp(['Actual String Length' int2str(image) ' is:  ' int2str(string{image}.len)]);
        
    end
    
    strings{numstr} = string;
    avg = 0; 
    for j = 1:5, avg = string{j}.len + avg; 
    end
    avg=avg/5;
    %disp(['      Average Length: ' int2str(avg)]);
    print(['String' int2str(numstr) '-' int2str(image)], '-djpeg90')
    clearvars -except strings numstr itr 
    disp('    -Next String-    ')
end

pause 
close all