from abc import ABCMeta, abstractmethod

import numpy as np
import skimage.io as io
from sklearn.cross_validation import train_test_split
from sklearn.metrics import mean_absolute_error
from sklearn.preprocessing import StandardScaler
from scipy import stats

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
        images_and_masks = zip(self.images, [self.im_2_mask(m) for m in self.masks])
        #print len(test[0])
	self.y =[]
        self.X = np.concatenate([self.im_superpixels(pair) for pair in images_and_masks], axis=0)
        #self.y = np.concatenate([self.im_mask(mask) for mask in self.masks], axis=0)
        # self.y = np.ones(self.X.shape[0])
    def im_superpixels(self,pair):
	im = pair[0]
	mask = pair[1]
        im_labels = slic(im, n_segments = 100, sigma = 3) # 500, 5
        unique_labels = np.unique(im_labels)
	#for x in unique_labels:
        #    idx = np.argwhere(im_labels == x)
        #    print x
        #    print idx.shape
        #    print im[idx].shape
        segs = [self.pixels_by_label(im,mask,im_labels,x) for x in unique_labels]
        return np.vstack([self.seg_2_stats(seg) for seg in segs])
    def pixels_by_label(self, im, mask, im_labels, x):
        idxs = np.argwhere(im_labels == x)
        #index = self.images.index(im)
        #mask = self.masks[index]
        mode = stats.mode(mask[idxs[:,0],idxs[:,1]])
        self.y.append(mode.mode[0])
	#print mode
        return im[idxs[:,0],idxs[:,1],:]
    def seg_2_stats(self, seg):
        #print seg.shape
        return np.array([np.mean(seg[:,0]), np.std(seg[:,0]), np.median(seg[:,0]),
			 np.mean(seg[:,1]), np.std(seg[:,1]), np.median(seg[:,1]),
                         np.mean(seg[:,2]), np.std(seg[:,2]), np.median(seg[:,2])])
    def im_mask(self,mask):
        return [self.mask_by_label(mask,x) for x in self.unique_labels]
        #return np.vstack([self.seg_2_stats(seg) for seg in segs])
    def mask_by_label(self, mask, x):
        idxs = np.argwhere(self.im_labels == x)
        return stats.mode(mask[idxs[:,0],idxs[:,1]])
