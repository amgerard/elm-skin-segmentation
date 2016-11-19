import time
start = time.time()

#print 'test'
import sys
import numpy as np
import skimage.io as io
from sklearn.cross_validation import train_test_split
from sklearn.metrics import mean_absolute_error
from sklearn.preprocessing import StandardScaler

# super-pixels
from skimage.segmentation import slic
from skimage.util import img_as_float

#
from multiprocessing.dummy import Pool as ThreadPool

from ELM import ELMRegressor

def im_read(path):
	return io.imread(path)

def im_reshape(im):
	'''
	reshape so each pixel is a (r,b,g) row
	'''
	x,y,z = im.shape
	return im.reshape(x*y,z)

def im_superpixels(im):
    im_labels = slic(im, n_segments = 100, sigma = 3) # 500, 5
    unique_labels = np.unique(im_labels)
    segs = [im[np.argwhere(im_labels == x)] for x in unique_labels]
    return np.vstack([seg_2_stats(seg) for seg in segs])

def seg_2_stats(seg):
    return np.ndarray([np.mean(seg), np.std(seg), np.median(seg)])

def superpixels_2_stats(segs):
    return np.column_stack([np.mean(segs,axis=0),np.std(segs,axis=0),np.median(segs,axis=0)])

def im_2_mask(im):
	'''
	covert mask to 1's and 0's and reshape
	'''
	mu = np.mean(im, axis=2)
	mask2d = mu < 255
	mask2d = mask2d.astype(int)
	x,y = mask2d.shape
	return mask2d.reshape(x*y)

def im_2_mask_2(zs):
    pass

def sample_test():
	X = im_reshape(im_read('im00001.jpg'))
	Y = im_2_mask(im_read('im00001_s.bmp'))
	W = np.linalg.lstsq(X, Y)[0]
	print W

# get 1st path passed in as argument
path = '' if len(sys.argv) < 2 else str(sys.argv[1])

# load all training images @ path
all_train_imgs = io.ImageCollection(path + '*.jpg')

# combine all images, one pixel per row
X = np.concatenate([im_superpixels(im) for im in all_train_imgs], axis=0)
# X = np.concatenate([im_reshape(im) for im in all_train_imgs], axis=0)

# get 2nd path passed in as argument
path = '' if len(sys.argv) < 3 else str(sys.argv[2])

# load all training images @ path
all_train_masks = io.ImageCollection(path + '*.bmp')

# combine all masks, one label per row
#y = np.concatenate([im_2_mask(im) for im in all_train_masks], axis=0)
y = np.ones(X.shape[0])

print 'done, pixels 2 super: ' + str(time.time()-start)

## DATA PREPROCESSING
#X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=2)

X_train = X
y_train = y

# same process above
path = '' if len(sys.argv) < 4 else str(sys.argv[3])
all_test_imgs = io.ImageCollection(path + '*.jpg')
X_test = np.concatenate([im_superpixels(im) for im in all_test_imgs], axis=0)
#X_test = np.concatenate([im_reshape(im) for im in all_test_imgs], axis=0)
path = '' if len(sys.argv) < 5 else str(sys.argv[4])
all_test_masks = io.ImageCollection(path + '*.bmp')
y_test = np.ones(X_test.shape[0])
# y_test = np.concatenate([im_2_mask(im) for im in all_test_masks], axis=0)

print 'done, test pixels 2 super: ' + str(time.time()-start)

'''
stdScaler_data = StandardScaler()
X_train = stdScaler_data.fit_transform(X_train)
X_test = stdScaler_data.transform(X_test)

stdScaler_target = StandardScaler()
y_train = stdScaler_target.fit_transform(y_train)  # /max(y_train)
y_test = stdScaler_target.transform(y_test)  # /max(y_train)
max_y_train = max(abs(y_train))
y_train = y_train / max_y_train
y_test = y_test / max_y_train
'''

ELM = ELMRegressor(30)
ELM.fit(X_train, y_train)
prediction = ELM.predict(X_train)

print 'train error: ' + str(mean_absolute_error(y_train, prediction))

prediction = ELM.predict(X_test)
print 'test error: ' + str(mean_absolute_error(y_test, prediction))

end = time.time()
print 'time elapsed: ' + str(end-start)
