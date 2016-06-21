 function a = compute_weight_nl(i,j,patch_ref,patch,horz_patch,vert_patch)
 
 %computes weight of the patch w.r.t the reference
 
 h=0.01;
 dist_int = sqrt(sum((patch_ref-patch).^2));
 if (rem(i,horz_patch) == 0)
     p1 = horz_patch;
 else
     p1 =rem(i,horz_patch);
 end
 if (rem(j,horz_patch) == 0)
     p2 = horz_patch;
 else
     p2 =rem(j,horz_patch);
 end
     
 p = abs(p1 -p2);
 q = ceil(i/horz_patch)- ceil(j/horz_patch); 
 dist_euc = sqrt(p^2 + q^2);
 a = exp(-dist_int/h)* exp(-dist_euc/h);
 end
