#print 'test'
import sys
import numpy as np
import skimage.io as io

def im_read(path):
	return io.imread(path)

def im_reshape(im):
	'''
	reshape so each pixel is a (r,b,g) row
	'''
	x,y,z = im.shape
	return im.reshape(x*y,z)

def im_2_mask(im):
	'''
	covert mask to 1's and 0's and reshape
	'''
	mu = np.mean(im, axis=2)
	mask2d = mu < 255
	mask2d = mask2d.astype(int)
	x,y = mask2d.shape
	return mask2d.reshape(x*y)

def sample_test():
	X = im_reshape(im_read('im00001.jpg'))
	Y = im_2_mask(im_read('im00001_s.bmp'))
	W = np.linalg.lstsq(X, Y)[0]
	print W

path = '' if len(sys.argv) < 2 else str(sys.argv[1])
# print str(len(sys.argv)) + ': ' + str(sys.argv[0])
train_imgs = io.ImageCollection(path + '*.jpg')
combined_data = np.concatenate([im_reshape(im) for im in train_imgs], axis=0)
print combined_data.shape
