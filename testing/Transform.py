from abc import ABCMeta, abstractmethod
import time
import numpy as np
import skimage.io as io
from sklearn.cross_validation import train_test_split
from sklearn.metrics import mean_absolute_error
from sklearn.preprocessing import StandardScaler
from scipy import stats

from multiprocessing.dummy import Pool as ThreadPool

# super-pixels
from skimage.segmentation import slic
from skimage.util import img_as_float

#class ITransform(metaclass=ABCMeta):
class ITransform():
	def __init__(self, images, masks):
		self.images=images
		self.masks=masks
		self.X = np.ones(1);
		self.y = np.ones(1);
	@abstractmethod
	def transform(self):
		pass
	def im_2_mask(self,im):
		'''
		covert mask to 1's and 0's and reshape
		'''
		mu = np.mean(im, axis=2)
		mask2d = mu < 255
		return mask2d.astype(int)

class SimpleTransform(ITransform):
	def transform(self):
		self.X = np.concatenate([self.im_reshape(im) for im in self.images], axis=0)
		self.y = np.concatenate([self.im_2_mask(im) for im in self.masks], axis=0)
	def im_reshape(self,im):
		'''
		reshape so each pixel is a (r,b,g) row
		'''
		x,y,z = im.shape
		return im.reshape(x*y,z)
	def im_2_mask(self,im):
		mask2d = ITransform.im_2_mask(im)
		x,y = mask2d.shape
		return mask2d.reshape(x*y)

class SuperPxlTransform(ITransform):
	def transform(self):
		im_labels = [get_im_labels(im) for im in self.images]
		ims_and_labels = zip(self.images, im_labels)

		results = [self.im_superpixels(pair) for pair in ims_and_labels]
		self.X = np.concatenate(results, axis=0)

		labels_and_masks = zip(im_labels, [self.im_2_mask(m) for m in self.masks])
		yy = [im_mask(pair) for pair in labels_and_masks]
		self.y = np.concatenate(yy, axis=0)
	
	def get_im_labels(self,im):
		return slic(im, n_segments = 100, sigma = 3) # 500, 5

	def im_superpixels(self,pair):
		im = pair[0]
		im_labels = pair[1]
		unique_labels = np.unique(im_labels)
		segs = [self.pixels_by_label(im,im_labels,x) for x in unique_labels]
		return np.vstack([self.seg_2_stats(seg) for seg in segs])
	
	def pixels_by_label(self, im, im_labels, x):
		idxs = np.argwhere(im_labels == x)
		return im[idxs[:,0],idxs[:,1],:]
	
	def seg_2_stats(self, seg):
		return np.array([np.mean(seg[:,0]), np.std(seg[:,0]), np.median(seg[:,0]),
				np.mean(seg[:,1]), np.std(seg[:,1]), np.median(seg[:,1]),
				np.mean(seg[:,2]), np.std(seg[:,2]), np.median(seg[:,2])])
	def im_mask(self,pair):
		im_labels = pair[0]
		mask = pair[1]
		unique_labels = np.unique(im_labels)
		return [self.mask_by_label(mask,im_labels,x) for x in unique_labels]
	
	def mask_by_label(self, mask, im_labels, x):
		idxs = np.argwhere(im_labels == x)
		mode = stats.mode(mask[idxs[:,0],idxs[:,1]])
		return mode.mode[0]

class SuperPxlParallelTransform(SuperPxlTransform):
	def transform(self):
		st = time.time()
		self.y =[]
		pool = ThreadPool(20) 

		im_labels = pool.map(self.get_im_labels, self.images)
		pool.close() 
		pool.join() # wait 

		print '1 => ' + str(time.time()-st)

		ims_and_labels = zip(self.images, im_labels)
		'''pool = ThreadPool(20) 
		results = pool.map(self.im_superpixels, ims_and_labels)
		pool.close() 
		pool.join()''' # wait 

		results = [self.im_superpixels(pair) for pair in ims_and_labels]

		self.X = np.concatenate(results, axis=0)
		print '2 => ' + str(time.time()-st)

		pool = ThreadPool(20) 
		labels_and_masks = zip(im_labels, [self.im_2_mask(m) for m in self.masks])
		yy = pool.map(self.im_mask, labels_and_masks)
		pool.close() 
		pool.join() # wait 

		self.y = np.concatenate(yy, axis=0)
		print '3 => ' + str(time.time()-st)
