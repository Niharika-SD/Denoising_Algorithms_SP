close all;
clear all;

input = imread('cameraman.tif');

figure;imshow(input);
title('original image')

h=fspecial('gaussian',[5 5],10);
I=im2double(input);
inp_img=imfilter(I,h,'conv');

figure;imshow(inp_img);
title('noisy image')

small_wind_side =1;
patch_side =3;

center = (patch_side - small_wind_side)/2; %index of beginning of center patch
[Rows,Cols] = size(inp_img);

a = rem(Cols, patch_side);
p1 = patch_side - a; %number of extra columns which need to be added on the right    
    
b = rem(Rows, patch_side);
p2 = patch_side - b; %number of extra rows which need to be added below the image
    
img_padded = padarray(inp_img,[p2,p1],'replicate','post'); % pads the image with extra rows and columns

[rows_p,cols_p] = size(img_padded);
assert(rem(rows_p,patch_side)==0 || rem(cols_p,patch_side)==0,'Padding incorrect'); % condition for incorrect padding

figure;imshow(img_padded);
title('padded image')

%% creating dictionary of patches

no_patches = (rows_p/patch_side)*(cols_p/patch_side);

patch_temp = img_padded(1:patch_side,1:patch_side);
patch_dictionary = reshape(patch_temp,[1,patch_side^2]);

horz_patch = cols_p/patch_side;
vert_patch = rows_p/patch_side;

for i = 1: vert_patch
    for j = 1: horz_patch
   
    patch_temp = img_padded((i-1)*patch_side+1:(i-1)*patch_side+patch_side,(j-1)*patch_side+1:(j-1)*patch_side+patch_side);
    patch_flat = reshape(patch_temp,[1,patch_side^2]);
    patch_dictionary = vertcat(patch_dictionary,patch_flat);
   
    end
end
patch_dictionary = double(patch_dictionary(2:end,:));

%% computing weight matrix for each patch using non local criteria

patch_dict_mod = patch_dictionary; % modify this copy of the buffer

numel = size(patch_dict_mod,1); % number of patches

for i = 1: numel
    weight = zeros(numel,1);
    for j = 1: numel
        if (j==i)
            weight(j) = 0;
        else
            weight(j) = compute_weight_nl(i,j,patch_dictionary(j,:),patch_dictionary(i,:),horz_patch,vert_patch);
        end 
    end
    weight = weight / sum(weight);
    %weight_mat =((weight')*ones(numel,patch_side^2));
    patch_dict_mod(i,:) = (weight')*double(patch_dictionary);
end

%% Reconstructing patches 

patch_recons = patch_dictionary;

%replacement of center 3x3 patch
for i = 1:numel
    patch_rec_temp = reshape(patch_dict_mod(i,:),[patch_side,patch_side]);
    patch_cent_extract = reshape(patch_dictionary(i,:),[patch_side,patch_side]);
    patch_rec_temp(center+1:center+small_wind_side,center+1:center+small_wind_side) = patch_cent_extract(center+1:center+small_wind_side,center+1:center+small_wind_side);
    patch_flat = reshape(patch_rec_temp,[1,patch_side^2]);
    patch_recons(i,:) =patch_flat;
end

%% Reconstruction of image

out_img = zeros(size(img_padded));

for i = 1: vert_patch
    for j = 1: horz_patch
    temp_patch = reshape(patch_recons(((i-1)*vert_patch+j),:),[patch_side,patch_side]);
    out_img((i-1)*patch_side+1:(i-1)*patch_side+patch_side,(j-1)*patch_side+1:(j-1)*patch_side+patch_side) = temp_patch;
    end
end

figure;imshow(out_img,[])
title('denoised image')