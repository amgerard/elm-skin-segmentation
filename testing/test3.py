import time
start = time.time()

import numpy as np
from sklearn.metrics import mean_absolute_error
from sklearn.metrics import accuracy_score
from ELM import ELMRegressor

# same transformed data
X_train = np.loadtxt("X_train.csv", delimiter=",")
y_train = np.loadtxt("y_train.csv", delimiter=",").astype(int8)
X_test = np.loadtxt("X_test.csv", delimiter=",")
y_test = np.loadtxt("y_test.csv", delimiter=",").astype(int8)

for x in range(500, 2000, 200):
	ELM = ELMRegressor(x)
	ELM.fit(X_train, y_train)
	prediction = ELM.predict(X_train)
	print x
	# print 'train error: ' + str(mean_absolute_error(y_train, prediction))
	print 'train accuracy: ' + str(accuracy_score(y_train, prediction))

	prediction = ELM.predict(X_test)
	#print 'test error: ' + str(mean_absolute_error(y_test, prediction))
	print 'test accuracy: ' + str(accuracy_score(y_test, prediction))

	end = time.time()
	print 'time elapsed: ' + str(end-start)
