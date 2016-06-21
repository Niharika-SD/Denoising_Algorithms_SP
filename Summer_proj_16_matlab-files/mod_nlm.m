inp_img = imread('ILSVRC2012_test_00000001.JPEG');

% figure;imshow(input);
% title('original image')
% 
% h=fspecial('gaussian',[5 5],10);
% I=im2double(input);
% inp_img=imfilter(I,h,'conv');

figure;imshow(inp_img);
title('noisy image')

small_wind_side =3; % center replacement patch size
patch_side =21; % block size

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

horz_patch_ps = cols_p/patch_side;
vert_patch_ps = rows_p/patch_side;

%% creating dictionary of patches

sim_wind = 3;   % measure of side of patch for similarity
no_patches = (rows_p/sim_wind)*(cols_p/sim_wind);
patch_temp = img_padded(1:sim_wind,1:sim_wind);
patch_dictionary = reshape(patch_temp,[1,sim_wind^2]);

horz_patch = cols_p/sim_wind;
vert_patch = rows_p/sim_wind;

for i = 1: vert_patch
    for j = 1: horz_patch
   
    patch_temp = img_padded((i-1)*sim_wind+1:(i-1)*sim_wind+sim_wind,(j-1)*sim_wind+1:(j-1)*sim_wind+sim_wind);
    patch_flat = reshape(patch_temp,[1,sim_wind^2]);
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

patch_recons = patch_dict_mod;

%% Reconstruct image

out_img = zeros(size(img_padded));

for i = 1: vert_patch
    for j = 1: horz_patch
    temp_patch = reshape(patch_recons(((i-1)*vert_patch+j),:),[sim_wind,sim_wind]);
    out_img((i-1)*sim_wind+1:(i-1)*sim_wind+sim_wind,(j-1)*sim_wind+1:(j-1)*sim_wind+sim_wind) = temp_patch;
    end
end

figure;imshow(out_img,[])
title('nlm image')

%% Blocks for AE training
clear patch_dictionary
no_patches = (rows_p/patch_side)*(cols_p/patch_side);

patch_temp = out_img(1:patch_side,1:patch_side);
patch_dictionary_AE = reshape(patch_temp,[1,patch_side^2]);
patch_dictionary = patch_dictionary_AE;

for i = 1: vert_patch_ps
    for j = 1: horz_patch_ps
   
    %dictionary creation using patches from modified image    
    patch_temp = out_img((i-1)*patch_side+1:(i-1)*patch_side+patch_side,(j-1)*patch_side+1:(j-1)*patch_side+patch_side);
    patch_flat = reshape(patch_temp,[1,patch_side^2]);
    patch_dictionary_AE = vertcat(patch_dictionary_AE,patch_flat);
    
    %dictionary creation using patches from original image
    patch_temp_orig = img_padded((i-1)*patch_side+1:(i-1)*patch_side+patch_side,(j-1)*patch_side+1:(j-1)*patch_side+patch_side);
    patch_flat_orig = reshape(patch_temp,[1,patch_side^2]);
    patch_dictionary = vertcat(patch_dictionary,patch_flat_orig);
   
    end
end

patch_dictionary_AE = double(patch_dictionary_AE(2:end,:));
patch_dictionary = double(patch_dictionary(2:end,:));

clear patch_recons;
patch_recons = patch_dictionary_AE;

%% Reconstructing patches using large window and center block replacement
%replacement of center 3x3 patch
for i = 1:size(patch_recons)
    patch_rec_temp = reshape(patch_dictionary_AE(i,:),[patch_side,patch_side]);
    patch_cent_extract = reshape(patch_dictionary(i,:),[patch_side,patch_side]);
    patch_rec_temp(center+1:center+small_wind_side,center+1:center+small_wind_side) = patch_cent_extract(center+1:center+small_wind_side,center+1:center+small_wind_side);
    patch_flat = reshape(patch_rec_temp,[1,patch_side^2]);
    patch_recons(i,:) =patch_flat;
end

output = zeros(size(img_padded));

for i = 1: vert_patch_ps
    for j = 1: horz_patch_ps
    temp_patch = reshape(patch_recons(((i-1)*vert_patch_ps+j),:),[patch_side,patch_side]);
    output((i-1)*patch_side+1:(i-1)*patch_side+patch_side,(j-1)*patch_side+1:(j-1)*patch_side+patch_side) = temp_patch;
    end
end

figure;imshow(output,[])
title('denoised image')


