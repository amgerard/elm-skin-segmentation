function [W,i1] = mrsr(T,X,kmax)
% Multiresponse Sparse Regression algorithm.
%
% [W,i1] = mrsr(T,X,kmax)
%  
% Input:
% T    is an (n x p) matrix of targets. The columns of T should
%      have zero mean and same scale (e.g. equal variance).
% X    is an (n x m) matrix of regressors. The columns of X should
%      have zero mean and same scale (e.g. equal variance).
% kmax is an integer fixing the number of steps to be run, which
%      equals to the maximum number of regressors in the model.
%  
% Output:
% W    is an (m x p*kmax) sparse matrix of regression
%      coefficients. It can be converted to full matrix by command   
%      full(W). Regression coefficients of the k:th step are given
%      by W(:,(k-1)*p+1:k*p).
% i1   is a (1 x kmax) vector of indices revealing the order in
%      which the regressors enter model. 
% 
% The estimates for T may be obtained by Y = X*W, where the k:th
% estimate Y(:,(k-1)*p+1:k*p) uses k regressors.
%  
% Reference: 
% Timo Similä, Jarkko Tikka. Multiresponse sparse regression with
% application to multidimensional scaling. International Conference
% on Artificial Neural Networks (ICANN). Warsaw, Poland. September
% 11-15, 2005. LNCS 3697, pp. 97-102.

% Copyright (C) 2005 by Timo Similä and Jarkko Tikka.
%
% This function is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of
% the License, or any later version.   
%
% The function is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% General Public License for more details.
% http://www.gnu.org/copyleft/gpl.html  
  
[n,m] = size(X);
[n,p] = size(T);
kmax = min(kmax,m);

W = sparse(m,p*kmax); % Weight matrices for all steps
i1 = []; % Indices of the selected regressors
i2 = [1:m]; % Indices of the nonselected regressors
XT = X'*T; % Helper matrix (frequently used)
XX = sparse(m,m); % Will be updated, in the m:th step XX = X'*X

% Matrix of all sign vectors of size (1 x p)
S = ones(2^p,p);
S(1:2^(p-1),1) = -1;
for j=2:p
  S(:,j) = [S(2:2:2^p,j-1);S(2:2:2^p,j-1)];
end

% Make the 1st step
A = XT';
[cmax,cind] = max(sum(abs(A),1));
A(:,cind) = [];
ind = i2(cind); % Index of the selected regressor
i2(cind) = []; i1 = [i1,ind];
XX(ind,ind) = X(:,ind)'*X(:,ind);
invXX = 1/XX(ind,ind);
Wols = invXX*XT(ind,:); % OLS parameters
Yols = X(:,ind)*Wols; % OLS estimate for T
B = Yols'*X(:,i2);
G = (cmax+S*A)./(cmax+S*B);
g = min(G(G>=0)); % Step size
W(i1,1:p) = g*Wols; % MRSR parameters
Y = g*Yols; % MRSR estimate for T

% Make rest of the steps
for k=2:kmax
  A = (T-Y)'*X(:,i2);
  [cmax,cind] = max(sum(abs(A),1));
  A(:,cind) = [];
  ind = i2(cind); % Index of the selected regressor
  i2(cind) = []; i1 = [i1,ind];
  xX = X(:,ind)'*X(:,i1);
  XX(ind,i1) = xX; XX(i1,ind) = xX';
  invXX = update_inverse(XX(i1,i1),invXX);    
  Wols = invXX*XT(i1,:); % OLS parameters
  Yols = X(:,i1)*Wols; % OLS estimate for T
  B = (Yols-Y)'*X(:,i2);
  G = (cmax+S*A)./(cmax+S*B);
  G = [2*(k==m)-1;G(:)];
  g = min(G(G>=0)); % Step size
  W(i1,(k-1)*p+1:k*p) = (1-g)*W(i1,(k-2)*p+1:(k-1)*p)+g*Wols; % MRSR parameters
  Y = (1-g)*Y+g*Yols; % MRSR estimate for T
end

function invXxXx = update_inverse(XxXx,invXX)
% Helper function for MRSR.
%  
% Input:
% XxXx    is the matrix [X x]'*[X x].
% invXX   is the inverse matrix of X'*X.
%
% Output:
% invXxXx is the inverse matrix of [X x]'*[X x].
%
% Reference: 
% Mark JL Orr. Introduction to Radial Basis Function Networks.
% Centre for Cognitive Science, University of Edinburgh, Technical
% Report, April 1996. 
  
m = size(XxXx,1)-1;
M1 = XxXx(1:m,m+1);
M2 = invXX*M1;
p = XxXx(m+1,m+1)-M1'*M2;
invXxXx = [M2;-1]*[M2',-1]/p;
invXxXx(1:m,1:m) = invXxXx(1:m,1:m)+invXX;
