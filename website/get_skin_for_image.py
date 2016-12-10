#import Transform
from ELM import ELMRegressor
import skimage.io as io
import numpy as np
import matplotlib.pyplot as plt
import pickle
import sys

# slic
from skimage.segmentation import slic
from skimage.segmentation import mark_boundaries
from skimage.util import img_as_float

# from scipy.misc import imsave
# elm
# import elm

def getModel(elmPkl):
	with open(elmPkl, 'rb') as inpu:
		return pickle.load(inpu)

def seg_2_stats(seg):
	return np.array([np.mean(seg[:,0]), np.std(seg[:,0]), np.median(seg[:,0]),
		np.mean(seg[:,1]), np.std(seg[:,1]), np.median(seg[:,1]),
		np.mean(seg[:,2]), np.std(seg[:,2]), np.median(seg[:,2]),
		np.min(seg[:,0]), np.min(seg[:,1]), np.min(seg[:,2]),
		np.max(seg[:,0]), np.max(seg[:,1]), np.max(seg[:,2])])

def idxs_by_label(im_labels, x):
        return np.argwhere(im_labels == x)

def pixels_by_label(im, idxs):
	return im[idxs[:,0],idxs[:,1],:]

def get_skin_image(im, elmPkl, dispOn=False):
	
	# get ELM model
	ELM = getModel(elmPkl)
	numSegments = 300

	# convert image to a floating point data type
	image = img_as_float(im)

	# apply SLIC and extract (approximately) the supplied number
	# of segments
	segments = slic(image, n_segments = numSegments, sigma = 1.0)
	#segments = slic(image, n_segments = numSegments, sigma = 1, compactness=20)
	
	unique_labels = np.unique(segments)
	idxs = {x:idxs_by_label(segments,x) for x in unique_labels}
	segs = {x:pixels_by_label(image,idxs[x]) for x in unique_labels}
	X_test = np.vstack([seg_2_stats(segs[x]) for x in unique_labels])

	# show the output of SLIC
	if dispOn == True:
		fig = plt.figure("Superpixels -- %d segments" % (numSegments))
		ax = fig.add_subplot(1, 1, 1)
		ax.imshow(mark_boundaries(image, segments))
		plt.axis("off")	
		plt.show()

	# predict skin
	pred = ELM.predict(X_test)
	# print pred
	av = 0.3 # pred.mean()
	skin = pred >= av
	not_skin = pred < av
	pred[skin] = 1
	pred[not_skin] = 0
	for i,x in enumerate(pred):
		#print x
		if x == 0:
			idx = idxs[unique_labels[i]]
			image[idx[:,0],idx[:,1],:] = 1

	# show skin
	if dispOn == True:
		fig = plt.figure("Superpixels -- %d segments" % (numSegments))
		ax = fig.add_subplot(1, 1, 1)
		#ax.imshow(mark_boundaries(image, segments))
		ax.imshow(image)
		plt.axis("off")
		plt.show()
	return image	

if __name__ == '__main__':
	#io.use_plugin('freeimage')
	
	elmPkl = sys.argv[1]
	impath = sys.argv[2]
	outpath = sys.argv[3]

	image = io.imread(impath)
	skin_im = get_skin_image(image, elmPkl)
	io.imsave(outpath, skin_im)
	'''
	path = '../../../Original/test/'
	images = io.ImageCollection(path + '*.jpg')	
	for image in images:	
		skin_im = get_skin_image(image, True)
		io.imsave('test.png', skin_im)
	'''
	# save
	#with open('elm.pkl', 'wb') as output:
	#    pickle.dump(ELM, output, pickle.HIGHEST_PROTOCOL)
