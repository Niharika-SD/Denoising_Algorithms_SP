close all
clear all

patchsize = 21; %AE input patchsize
swind_hsize = 21;% half size of search window
s =(patchsize-1)/2 ; 
sim_wind = 3;   % measure of side of patch for similarity

img = imread('cameraman.tif');
[m,n,p] = size(img);
if (p == 3)
    img = rgb2gray(img);
end

img = mat2gray(img);
img = im2double(img);

img_padded = padarray(img,[swind_hsize,swind_hsize],'replicate');
imshow(img_padded);

%center of patch
r = swind_hsize+randi([s+1,m-s],1);
c = swind_hsize+randi([s+1,n-s],1);
 
search_window = img_padded(r-swind_hsize-s:r+swind_hsize+s,c-swind_hsize-s:c+swind_hsize+s);
figure;imshow(search_window)

temp_patch = img_padded(r-s:r+s,c-s:c+s);
temp_patch_copy = temp_patch;

figure;subplot(3,1,1) 
imshow(temp_patch)

patch_mod = modify_patch(temp_patch,search_window,sim_wind);
subplot(3,1,2); imshow(patch_mod)

patch_mod1 = patch_mod;

patch_mod1(s:s+2,s:s+2) = temp_patch_copy(s:s+2,s:s+2);
subplot(3,1,3); imshow(patch_mod1)