import time
start = time.time()

import numpy as np
from sklearn.metrics import mean_absolute_error
from ELM import ELMRegressor

# same transformed data
X_train = np.loadtxt("X_train.csv", delimiter=",")
y_train = np.loadtxt("y_train.csv", delimiter=",")
X_test = np.loadtxt("X_test.csv", delimiter=",")
y_test = np.loadtxt("y_test.csv", delimiter=",")

for x in range(100, 10000, 100):
	ELM = ELMRegressor(2000)
	ELM.fit(X_train, y_train)
	prediction = ELM.predict(X_train)

	print 'train error: ' + str(mean_absolute_error(y_train, prediction))

	prediction = ELM.predict(X_test)
	print 'test error: ' + str(mean_absolute_error(y_test, prediction))

	end = time.time()
	print 'time elapsed: ' + str(end-start)
