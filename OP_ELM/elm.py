# -*- coding: utf-8 -*-
"""
Created on Wed Nov 27 14:07:48 2013

@author: akusoka1
"""

import numpy as np
from numpy.linalg import inv
from scipy.optimize import minimize

from mrsr import mrsr
from slfn import SLFN


class ELMError(Exception):
    def __init__(self, v):
        self.val = v
    def __str__(self):
        return repr(self.val)


class ELM(object):
    """Implementation of ELM.
    """    
    
    # global variables
    nn = None
    op_max_samples = 5000  # limit of samples for mrsr
    TOL = np.finfo(np.float32).eps * 50  # tolerance for linear solver
     
     
    def __init__(self, inputs, outputs=0, mirror=0, lin=0, tanh=0):
        """Starts ELM with parameters.
        
        X - input data OR elm parameters for running,
            with loaded parameters no training possible
        mirror - number of dimensions copied to hidden neurons, 
                 copy first #mirror dimensions
        lin - number of linear combination neurons
        tanh - number of tanh neurons
        """
        
        # load trained network
        if isinstance(inputs, SLFN):
            self.nn = inputs
        # train a new elm
        else:  
            # set input and output dimensions
            if (mirror<1) and (lin<1) and (tanh<1):
                raise ELMError("No neurons selected.")
            self.nn = SLFN()
            self.nn.d = inputs+1
            self.nn.p = outputs
            self.nn.k = max(mirror,0) + max(lin,0) + max(tanh,0)
            self.nn.feats = np.arange(self.nn.d)
            self.nn.W = self._gen_random_weights(mirror, lin, tanh)  # random projection matrix

    
    def _norm_X(self, X):
        # check saliency
        if len(X.shape) != 2:
            raise ELMError("X must be 2-dim numpy array.")
        if X.shape[1] < np.max(self.nn.feats):
            raise ELMError("Wrong input dimension: %d expected, %d found"\
                  % (np.max(self.nn.feats), X.shape[1]))
        # add bial column
        X = np.hstack((X, np.ones((X.shape[0],1))))  # add bias
        X = X.take(self.nn.feats, axis=1)
        return X

    
    def _norm_Y(self, Y, X):
        if len(Y.shape) == 1:
            # reshape single output to 2-dim form
            Y = np.reshape(Y, (-1,1))
        if len(Y.shape) != 2:
            raise ELMError("Y must be 1-dim or 2-dim numpy array.")
        if Y.shape[0] != X.shape[0]:
            raise ELMError("X and Y have different number of samples.")
        if Y.shape[1] != self.nn.p:
            raise ELMError("Wrong output dimension: %d expected, %d found"\
                           % (self.nn.p, Y.shape[1]))
        return Y


    def _gen_random_weights(self, mirror, lin, tanh):
        """Generate random projection matrix and mapping functions.
        
        Identity function is 'None'.
        """
        d = self.nn.d - 1  # without bias
        W = []
        self.nn.f = []  # reset features
        # add mirrored neurons
        if mirror > 0:
            mirror = min(mirror, d)  # limit to number of inputs
            W.append(np.eye(d, mirror))
            self.nn.f.extend([0]*mirror)
        # add linear neurons
        if lin > 0:
            W.append(np.random.randn(d, lin))
            self.nn.f.extend([0]*lin)
        # add tanh neurons
        if tanh > 0:
            W.append(np.random.randn(d, tanh))
            self.nn.f.extend([1]*tanh)
        # add bias
        self.nn.f = np.array(self.nn.f)
        W = np.vstack((np.hstack(W), np.random.randn(1, self.nn.k)))
        return W

    
    def _press(self, H, Y, lmd=None):
        """According to Momo's article.
        
        Extended case for multiple outputs, 'W' is 2-dimensional.
        """      
        # no lambda version of PRESS
        if lmd is None:
            return self._press_basic(H,Y)
        
        X = H
        N = X.shape[0]
        U,S,V = np.linalg.svd(X, full_matrices=False)
        A = np.dot(X, V.T)
        B = np.dot(U.T, Y)
        
        # function for optimization
        def lmd_opt(lmd, S, A, B, U, N):    
            Sd = S**2 + lmd
            C = A*(S/Sd)
            P = np.dot(C, B)
            D = np.ones((N,)) - np.einsum('ij,ji->i', C, U.T)
            e = (Y - P) / D.reshape((-1,1))
            MSE = np.mean(e**2)
            return MSE
        
        res = minimize(lmd_opt, lmd, args=(S,A,B,U,N), method="Powell")
        if not res.success:
            print "Lambda optimization failed:  (using basic results)"
            print res.message
            MSE = lmd_opt(lmd, S, A, B, U, N)    
            self.nn.lmd = None
        else:
            lmd = res.x
            MSE = res.fun
            self.nn.lmd = lmd

        return MSE

        
    def _press_basic(self, H, Y):
        """According to Momo's article, fast version with no L2-regularization.
        
        Extended case for multiple outputs, 'W' is 2-dimensional.
        """        
        X = H
        N = X.shape[0]
        C = inv(np.dot(X.T, X))
        P = X.dot(C)
        W = C.dot(X.T).dot(Y)        
        D = np.ones((N,)) - np.einsum('ij,ji->i', P, X.T)        
        e = (Y - X.dot(W)) / D.reshape((-1,1))
        MSE = np.mean(e**2)
        return MSE

    
    def _op_core(self, X, Y, lmd=None, Kmax=0):
        """Core OP-ELM function, used in other methods.
        """
        if Kmax == 0:
            Kmax = self.nn.k
        N = X.shape[0]
        if N > self.op_max_samples:
            idx = np.arange(N)
            np.random.shuffle(idx)
            idx = idx[:self.op_max_samples]
            X = X.take(idx, axis=0)
            Y = Y.take(idx, axis=0)
        H = self.nn._project(X)
        # rank all neurons wrt their usefullness
        rank = mrsr(Y, H, kmax=Kmax)
        
        """
        tree-like close-to-optimal discrete function optimization
        evaluate 3 middle points every time, then reduce search range twice
        delta is distance between a <-> b1 <-> b2 <-> b3 <-> c
        note that b3 <-> c may be larger than delta!
                |-------------------------------------|
        a0       b1       b2        b3       c0  < say smallest error at b3
                           |------------------|
                          a1   b1   b2   b3   c1
        etc...
        """
        a = 0
        c = Kmax
        b = c
        E = np.ones((Kmax,))
        while True:
            delta = max((c-a)/4, 1)
            # if delta==1, evaluate all points in range and exit
            if delta < 2:
                for i in range(a,b):
                    if E[i] == 1:  # if we have not calculated this yet
                        Hi = H.take(rank[:i+1], axis=1)
                        E[i] = self._press(Hi, Y, lmd)
                break
            # check 3 middle points            
            for b in [a+delta, a+2*delta, a+3*delta]:
                if E[b] == 1:  # if we have not calculated this yet
                    Hi = H.take(rank[:b], axis=1)
                    E[b] = self._press(Hi, Y, lmd)
            b = np.argmin(E)
            a = b-delta
            if b != (a+3*delta):  # don't change the upper bound <Kmax>
                c = b+delta

        self.best_idx = rank[:np.argmin(E)+1]  # indices of best neurons
        return E.min()
        
        
    def _update_nn(self):
        """Update ELM parameters using calculated best indices.
        """
        best_idx = self.best_idx
        self.nn.k = len(best_idx)
        self.nn.W = self.nn.W.take(best_idx, axis=1)        
        self.nn.f = np.array([self.nn.f[i] for i in best_idx], dtype=np.int)
        if len(self.nn.B) > 0:
            self.nn.B = self.nn.B.take(best_idx, axis=0)
    
    
    def _train_op(self, X, Y, Kmax=0):
        """Perform optimal pruning of ELM.
        
        kmax - maximum amount of samples for pruninig
        step - step for checking the results
        """
        H = self.nn._project(X)
        E_min = self._op_core(X,Y,Kmax=Kmax)
        self._update_nn()
        H_new = self.nn._project(X)
        self.nn._solve(H_new, Y)
        return E_min


    def _train_trop(self, X, Y, Kmax=0):
        """Perform TR-optimized Optimal Pruning of ELM.
        
        kmax - maximum amount of samples for pruninig
        """
        E_min = self._op_core(X, Y, lmd=1E-3, Kmax=Kmax)
        self._update_nn()
        H_new = self.nn._project(X)
        self.nn._solve(H_new, Y)
        return E_min
    
    
    def _train_tr(self, X, Y, Kmax=0):
        """Tikhonov-regularized ELM.
        """
        H = self.nn._project(X)
        E = self._press(H, Y, 1E-5)  # this finds optimal lambda
        self.nn._solve(H, Y)
        return E


    def _train_basic(self, X, Y, Kmax=0):
        """Train a basic version of ELM.
        """
        H = self.nn._project(X)
        self.nn._solve(H, Y)

##############################################################################

    def train(self, X, Y, method='none', Kmax=0):
        """Training wrapper.
        """
        X = self._norm_X(X)
        Y = self._norm_Y(Y,X)
        methods = {"basic": self._train_basic,
                   "tr": self._train_tr,
                   "op": self._train_op,
                   "trop": self._train_trop}
        E = methods[method.lower()](X,Y,Kmax)
        return E
        

    def get_nn(self):
        return self.nn


    def set_nn(self, nn):
        self.nn = nn

    
    def run(self, X, Y=None):
        X = self._norm_X(X)
        H = self.nn._project(X)
        Yh = H.dot(self.nn.B)
        if Y is None:
            return Yh
        else:
            Y = self._norm_Y(Y,X)
            E = self._press(H, Y, self.nn.lmd)
            return Yh, E


def try1():
    ins = 50
    outs = 5
    N = 1000
    X = np.random.randn(N,ins)
    Y = np.random.rand(N,outs)
    elm = ELM(ins, outs, mirror=ins, lin=0, tanh=100)
    elm.train(X, Y, method='op')    
    Yh = elm.run(X)
    print "mse: ", np.mean((Y-Yh)**2)
    print "Done!"
    

if __name__ == "__main__":
    print "numpy version: ", np.__version__
    try1()
    










