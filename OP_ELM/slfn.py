# -*- coding: utf-8 -*-
"""
Created on Wed Nov 27 14:07:48 2013

@author: akusoka1
"""

import numpy as np
from numpy.linalg import pinv, svd
import numexpr as ne

class SLFN(object):    
    """ELM model is just a SLFN.
    """
    d = 0
    k = 0
    p = 0
    W = np.empty((d,k))
    B = np.empty((k,p))
    f = []
    feats = np.arange(d)
    TOL = np.finfo(np.float32).eps * 50  # tolerance for linear solver
    lmd = None  # L2-regularizer, 'None' means 'not in use'
    
    
    def _project(self, X, W=None):
        """Projects inputs to hidden layer outputs.
        """
        if W is None:
            W = self.W
        # here is the trick: mean of np.dot(X,W) stays close to 0,
        # but mean of absolute that value is proportional to d**0.5
        H = X.dot(W)
        div = W.shape[0]**0.5
        H = ne.evaluate("H/div")
        # apply non-linear functions
        for i in xrange(self.k):
            if self.f[i] == 1:
                np.tanh(H[:,i], H[:,i])  # apply inplace        
        return H

    
    def _solve(self, H, Y):
        """Solve ELM output weights.
        """
        # if lambda is specified
        if self.lmd is not None:
            # adapted from numpy.linalg.pinv
            U,s,Vt = svd(H, 0)
            m = U.shape[0]
            n = Vt.shape[1]
            for i in range(min(m,n)):
                if s[i] > self.TOL:
                    s[i] = s[i] / (s[i]**2 + self.lmd)
                else:
                    s[i] = 0.
            Hp = np.dot(Vt.T, np.multiply(s[:, np.newaxis], U.T))
            self.B = np.dot(Hp, Y)
            
        # fast no-lambda version using LAPACK solver
        else:
            self.B = np.linalg.lstsq(H,Y,rcond=self.TOL)[0]                    
        return self.B
                
    
    def run(self, X):
        """Get prediction.
        """
        X = np.hstack((X, np.ones((X.shape[0],1))))
        X = X.take(self.feats, axis=1)
        H = self._project(X)
        Yh = H.dot(self.B)
        return Yh





