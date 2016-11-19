import time
start = time.time()

import sys
import Transform
import skimage.io as io
import numpy as np
from sklearn.metrics import mean_absolute_error
from ELM import ELMRegressor

# get 1st path passed in as argument
path = '' if len(sys.argv) < 2 else str(sys.argv[1])

# load all training images @ path
all_train_imgs = io.ImageCollection(path + '*.jpg')

# get 2nd path passed in as argument
path = '' if len(sys.argv) < 3 else str(sys.argv[2])

# load all training images @ path
all_train_masks = io.ImageCollection(path + '*.bmp')

train = Transform.SuperPxlParallelTransform(all_train_imgs, all_train_masks)
train.transform()
X_train = train.X
y_train = train.y

print X_train.shape

print 'done, transforming training data: ' + str(time.time()-start)

path = '' if len(sys.argv) < 4 else str(sys.argv[3])
all_test_imgs = io.ImageCollection(path + '*.jpg')
path = '' if len(sys.argv) < 5 else str(sys.argv[4])
all_test_masks = io.ImageCollection(path + '*.bmp')

test = Transform.SuperPxlParallelTransform(all_test_imgs, all_test_masks)
test.transform()
X_test = test.X
y_test = test.y

print 'done, transforming test data: ' + str(time.time()-start)

# same transformed data
np.savetxt("X_train.csv", X_train, delimiter=",")
np.savetxt("y_train.csv", y_train, delimiter=",")
np.savetxt("X_test.csv", X_test, delimiter=",")
np.savetxt("y_test.csv", y_test, delimiter=",")

ELM = ELMRegressor(2000)
ELM.fit(X_train, y_train)
prediction = ELM.predict(X_train)

print 'train error: ' + str(mean_absolute_error(y_train, prediction))

prediction = ELM.predict(X_test)
print 'test error: ' + str(mean_absolute_error(y_test, prediction))

end = time.time()
print 'time elapsed: ' + str(end-start)
