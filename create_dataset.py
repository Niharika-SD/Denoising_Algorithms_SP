from matplotlib import pyplot as plt
import cv2
import numpy as np
import sys
import os
from skimage import data, img_as_float
from skimage.util.shape import view_as_windows
dirname = 'train_data'
os.mkdir(dirname)

image = cv2.imread('image1.jpg',0)
[m,n] = image.shape

print 'number of rows is:'
print m
print 'number of columns is:'
print n

#size of patch to be extracted
patch_side = 21
a = m % patch_side
b = n % patch_side

#number of extra rows and columns to be added for padding
bottom = patch_side-a;
right = patch_side-b;
top = 0;
left = 0;

#padding
padded_image = cv2.copyMakeBorder(image, top, bottom, left, right, cv2.BORDER_REPLICATE) 
[m_pad,n_pad]= padded_image.shape
print 'after padding, no of vertical and horizontal patches is :'
vertical_patches =int(m_pad/21)
horizontal_patches =int(n_pad/21)
print [vertical_patches,horizontal_patches]

cv2.imwrite('padded_image.jpg',padded_image)

padded_image = img_as_float(padded_image)*255

#change directory to folder storing patches
os.chdir(dirname)

# creating overlapping patches from an image

print 'creating dataset, please wait'

B = view_as_windows(padded_image, [patch_side,patch_side])
[p,q,r,s] = B.shape

for i in range(p):
    sys.stdout.write('.')
    sys.stdout.flush()

    for j in range(q):
        b = B[i,j]
        str1 = 'train'+ str(i*p+j) + '.jpg'
        cv2.imwrite(str1,np.array(b))
    
print ' ' 
