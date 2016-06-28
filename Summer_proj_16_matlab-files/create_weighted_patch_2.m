function patch_out = create_weighted_patch_2(patch_d,s_dict,sim_wind)
%% takes a patch vector as input along with the search window dictionary and position of current element in the iteration and returns the weighted and reconstructed patch

h=2; %filter parameter

numel = size(s_dict,1);
weight = zeros(numel,1);

for k = 1:numel
    dist_int = sqrt(sum((patch_d -s_dict(k)).^2));
    weight(k) = exp(-dist_int/h);
end

weight = weight / sum(weight);
s_dict = horzcat(s_dict,weight);
s_dict = sortrows(s_dict,size(s_dict,2));
patch_out =s_dict(1:(size(s_dict,1)/(sim_wind*sim_wind)),1:(size(s_dict,2)-1));
end