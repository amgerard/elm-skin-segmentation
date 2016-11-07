function [model]=train_OPELM(data,kernel,maxneur,problem,normal,KM)

% Optimal-Pruning Extreme Learning Machine algorithm
%
% [model] = train_OPELM( data , [kernel] , [maxneur], 
%                        [problem] , [normal] , [KM] )
%
%
% Inputs:
%          data       is a struct made of, at least:
%                     data.x  a Nxd matrix of variables
%                     data.y  a Nxn matrix of outputs
%                             (can be multi-output)
%
%          [kernel]   (optional) is the type of kernels
%                     to use. Either 'l' (linear), 's' (sigmoid),
%                     'g' (gaussian), 'ls' (linear+sigmoid),
%                     'lg' (linear+gaussian) 
%                     or 'lsg' (linear+sigmoid+gaussian). 
%                     Default is 'lsg'.
%
%          [maxneur]  (optional) is the maximum number of
%                     neurons allowed in the model.
%                     Default is 100.
%
%          [problem]  (optional) is the type of problem.
%                     Either 'r' (regression) or 
%                     'c' (classification).
%                     Default is 'r'.
%
%          [normal]   (optional) defines whether data is to
%                     be normalized before applying OPELM.
%                     Either 'y' (yes) or 'n' (no).
%                     Default is 'y'.
%
%          [KM]       (optional) specifies a previously 
%                     computed Kernel Matrix to be used
%                     as initialization of the model.
%                     Default is empty.
%
%
% Output:
%          [model]   a struct containing the obtained model.
%                    Use show_model to view details of the model.
%

% References: Yoan Miche, Patrick Bas, Christian Jutten, Olli Simula,
%             Amaury Lendasse. A Methodology for Building Regression 
%             Models using Extreme Learning Machine: OP-ELM, in Proceedings
%             of European Symposium on Artificial Neural Networks (ESANN)
%             2008, Bruges, Belgium.
%
%             Timo Similä, Jarkko Tikka. Multiresponse sparse regression with
%             application to multidimensional scaling. International Conference
%             on Artificial Neural Networks (ICANN). Warsaw, Poland. September
%             11-15, 2005. LNCS 3697, pp. 97-102.
%
% Copyright (C) 2008 by Amaury Lendasse, Antti Sorjamaa and Yoan Miche.
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


%% Test the user input extensively
model=[];
if nargin<1
    disp('Error: no arguments.');
    disp('Exiting...');
    return
end
if nargin>6
    disp('Error: too many arguments.');
    disp('Exiting...');
    return
end

% Check data
if isempty(data)
    % Data is empty
    disp('Error: data set is empty.')
    disp('Exiting...')
    return
else
    % Data set is here, check it
    if (~isstruct(data))
        % Data is not a struct
        disp('Error: data set is not a struct; should be of form data.x and data.y.')
        disp('Exiting...')
        return
    else
        % Data is a struct, check the structure
        if (~isfield(data,{'x','y'}))
            % Data has not the required fields
            disp('Error: data set does not have data.x and data.y fields.')
            disp('Exiting...')
            return
        else
            % Data has the two fields data.x and data.y
            x=data.x;
            y=data.y;
            [N,d]=size(x);
            [No,n]=size(y);
            if (N~=No) || (N<2)
                disp('Error: data.x and data.y do not have the same number of samples or too few samples.');
                disp('Exiting...');
                return
            end
        end
    end
   
end

if rank(x)~=d
    msg=sprintf('Error: data variables cannot be correlated (%d correlated variable(s)).',d-rank(x)+1);
    disp(msg);
    disp('Exiting...');
    return
end
if rank(y)~=n
    msg=sprintf('Error: output variables cannot be correlated (%d correlated variable(s)).',n-rank(y)+1);
    disp(msg);
    disp('Exiting...');
    return
end


%% Set a few things up
% Remove the singularity warnings from matlab
% They are handled correctly below
warning off MATLAB:nearlySingularMatrix
warning off MATLAB:rankDeficientMatrix


%% Check all arguments
% First, the Kernel Matrix
if ~exist('KM','var')
    KM.value=[];
    KM.function=[];
    KM.param.p1=[];
    KM.param.p2=[];
else
    if isempty(KM)
        % Kernel Matrix is empty
        disp('Warning: Kernel Matrix specified but empty...');
        disp('-------> Switching to default empty one.');
        KM.value=[];
        KM.function=[];
        KM.param.p1=[];
        KM.param.p2=[];
    else
        % Kernel Matrix not empty, check it quickly
        if (~isstruct(KM))
            disp('Error: Kernel Matrix KM is not of type struct.');
            disp('Exiting...');
            return
        end
        if (isempty(KM.value)) || (isempty(KM.function))
            disp('Error: Kernel Matrix values or functions are empty.');
            disp('Exiting...');
            return
        end
        if (isempty(KM.param)) || (~isstruct(KM.param))
            disp('Error: Kernel Matrix parameters are not valid (empty or not struct form.)');
            disp('Exiting...');
            return
        end

        if (isempty(KM.param.p1)) || (isempty(KM.param.p2))
            disp('Error: Kernel Matrix parameters are empty.');
            disp('Exiting...');
            return
        end
    end
end

% Second, the normalization argument
if ~exist('normal','var')
    disp('Warning: normalization unspecified...');
    disp('-------> Switching to forced normalization.');
    normal='y';
else
    if isempty(normal)
        % Normalization field is empty
        disp('Warning: normalization specified but empty...');
        disp('-------> Switching to forced normalization.');
        normal='y';
    else
        % Normalization field is specified, check it
        if ~strcmp(normal,{'y';'n';'Y';'N'})
            disp('Error: Normalization specification invalid; either "N" or "n" for none or "Y" or "y" for yes.');
            disp('Exiting...');
            return
        else
            if normal=='Y'
                normal='y';
            end
        end
    end
end

% Third, the problem specification
if ~exist('problem','var')
    disp('Warning: problem unspecified...');
    disp('-------> Switching to regression problem.');
    problem='r';
else
    if isempty(problem)
        % Problem field is empty
        disp('Warning: problem specified but empty...');
        disp('-------> Switching to regression problem.');
        problem='r';
    else
        % Problem field is specified, check it
        if ~strcmp(problem,{'r';'c'})
            disp('Error: problem specification invalid; either "r" for regression or "c" for classification.');
            disp('Exiting...');
            return
        end

        if problem=='c'
            % If we have classification problem, check classes
            uy=unique(y);
            sy1=size(uy,1);
            if (sy1~=2)
                disp('Error: Classification problem with more than two classes not supported.');
                disp('Exiting...');
                clear uy sy1 sy2
                return
            end
            if (min(uy)~=-1) || (max(uy)~=1)
                disp('Error: Classes for classification should be 1 and -1 only.');
                disp('Exiting...');
                clear uy
                return
            end
        end
    end
end

% Fourth, Kernel type (since number of neurons depends on it)
if ~exist('kernel','var')
    disp('Warning: kernel type unspecified...');
    if N-1-d>0
        disp('-------> Switching to lsg kernel.');
        kernel='lsg';
    else
        disp('-------> Switching to sg kernel.');
        kernel='sg';
    end
else
    % Kernel type is empty
    if isempty(kernel)
        disp('Warning: kernel type empty...');
        if N-1-d>0
            disp('-------> Switching to lsg kernel.');
            kernel='lsg';
        else
            disp('-------> Switching to sg kernel.');
            kernel='sg';
        end
    else
        % Kernel type is specified, check it
        if ~max(strcmp(kernel,{'l';'s';'g';'ls';'lg';'sg';'lsg'}))
            disp('Error: Kernel type invalid; either "l" or "s" or "g" or "ls" or "lg" or "sg" or "lsg".');
            disp('Exiting...');
            return
        end
    end
end


% Fifth, Maximum number of neurons specification
if ~exist('maxneur','var')    
    if strcmp(kernel,{'l'})
        maxneur=1;
    else
        disp('Warning: maximum number of neurons unspecified...');
        disp('-------> Switching to 100 maximum neurons.');
        if N-1-d>0
            maxneur=min(100,N-2-d);
        else
            maxneur=min(100,N-2);
        end
    end
else
    % Maximum number of neurons is empty
    if isempty(maxneur)
        if strcmp(kernel,{'l'})
            maxneur=1;
        else
            disp('Warning: maximum number of neurons empty...');
            disp('-------> Switching to 100 maximum neurons.');
            if N-1-d>0
                maxneur=min(100,N-2-d);
            else
                maxneur=min(100,N-2);
            end
        end
    else
        % Maximum number of neurons is specified, check it
        if (maxneur<1) || (ceil(maxneur)~=maxneur)
            disp(['Error: Maximum number of neurons should be more than 1 and ' ...
                'integer.']);
            disp('Exiting...');
            return
        end
        if max(strcmp(kernel,{'ls';'lg';'lsg'}))
            if (maxneur>N-d-2)
                disp('Error: Maximum number of neurons too important.');
                disp('Exiting...');
                return
            end
        else
            if (maxneur>N-2)
                disp('Error: Maximum number of neurons too important.');
                disp('Exiting...');
                return
            end
        end
    end
end


if (max(strcmp(KM.function,'l'))==1) && (max(strcmp(kernel,{'l';'ls';'lg';'lsg'}))==1)
    disp('Error: Chosen kernel not suitable considering the previous Kernel Matrix given (previous kernel matrix is linear and kernel is partly linear.)');
    disp('Exiting...');
    return;
end

% End of input checking



%% Normalisation of data
mymean=zeros(1,d);
mystd=zeros(1,d);
if normal=='y'
    for i=1:d
        mymean(1,i)=mean(x(:,i));
        mystd(1,i)=std(x(:,i));
        x(:,i)=(x(:,i)-mean(mymean(1,i)))/mystd(1,i);
    end
else
    mymean(1,1:d)=0;
    mystd(1,1:d)=1;
end
myperm=randperm(N);
x=x(myperm,:);
y=y(myperm,:);

%% Random initialisation of the kernel
if max(strcmp(kernel,{'l';'ls';'lg';'lsg'}))
    KM.value=[KM.value x];
    KM.function=[KM.function repmat({'l'},1,d)];
    KM.param.p1=[KM.param.p1 zeros(d,d)];
    KM.param.p2=[KM.param.p2 1:d];
end

if max(strcmp(kernel,{'s';'ls'}))
    W1=rand(d,maxneur)*10-5;
    W10=rand(1,maxneur)*10-5;
    KM.value=[KM.value tanh(x*W1+ones(N,1)*W10)];
    KM.function=[KM.function repmat({'s'},1,maxneur)];
    KM.param.p1=[KM.param.p1 W1];
    KM.param.p2=[KM.param.p2 W10];
    clear W1 W10
end

if max(strcmp(kernel,{'g';'lg'}))
    if (N>2000)
        Y=pdist(x(randperm(2000),:));
    else
        Y=pdist(x);
    end
    a10=prctile(Y,20);
    a90=prctile(Y,60);
    MP=randperm(N);
    W1=x(MP(1:maxneur),:);
    W10=rand(1,maxneur)*(a90-a10)+a10;
    for j=1:maxneur
        KM.valueinit(:,j)=gaussian_func(x,W1(j,:),W10(1,j));
    end
    KM.value=[KM.value KM.valueinit];
    KM.function=[KM.function repmat({'g'},1,maxneur)];
    KM.param.p1=[KM.param.p1 W1'];
    KM.param.p2=[KM.param.p2 W10];
    clear W1 W10 Y a10 a90 MP
    KM=rmfield(KM,'valueinit');
end

if max(strcmp(kernel,{'sg';'lsg'}))
    % s part
    W1=rand(d,max(round(maxneur/2),1))*10-5;
    W10=rand(1,max(round(maxneur/2),1))*10-5;
    KM.value=[KM.value tanh(x*W1+ones(N,1)*W10)];
    KM.function=[KM.function repmat({'s'},1,max(round(maxneur/2),1))];
    KM.param.p1=[KM.param.p1 W1];
    KM.param.p2=[KM.param.p2 W10];
    % g part
    if (N>2000)
        Y=pdist(x(randperm(2000),:));
    else
        Y=pdist(x);
    end
    a10=prctile(Y,20);
    a90=prctile(Y,60);
    MP=randperm(N);
    W1=x(MP(1:max(round(maxneur/2),1)),:);
    W10=rand(1,max(round(maxneur/2),1))*(a90-a10)+a10;
    for j=1:max(round(maxneur/2),1)
        KM.valueinit(:,j)=gaussian_func(x,W1(j,:),W10(1,j));
    end
    KM.value=[KM.value KM.valueinit];
    KM.function=[KM.function repmat({'g'},1,max(round(maxneur/2),1))];
    KM.param.p1=[KM.param.p1 W1'];
    KM.param.p2=[KM.param.p2 W10];
    clear W1 W10 Y a10 a90 MP
    KM=rmfield(KM,'valueinit');
end
[Np,nn]=size(KM.value);


%% Hidden layer output normalization
KM_norm=zeros(Np,nn);
for i=1:nn
    KM_norm(:,i)=(KM.value(:,i)-mean(KM.value(:,i)))/std(KM.value(:,i));
end
y_norm=zeros(No,n);
for i=1:n
    y_norm(:,i)=(y(:,i)-mean(y(:,i)))/std(y(:,i));
end


%% L.A.R.S.
if nn>1
    [W,i1] = mrsr(y_norm,KM_norm,nn);
    KM.value=KM.value(:,i1);
    KM.function=KM.function(:,i1);
    KM.param.p1=KM.param.p1(:,i1);
    KM.param.p2=KM.param.p2(:,i1);
end


%% Leave-One-Out
disp(['Computing model with ',int2str(d),' variable(s)...']);
err=zeros(nn,n);
mycond=zeros(1,nn);
errloo=Inf(nn,n);
maxsamples=min(N,5000);
if max(strcmp(kernel,{'l';'ls';'lg';'lsg'}))
    nn_indexes=[1:d d+5:5:nn];
else
    nn_indexes=[5:5:nn];
end

for i=nn_indexes
    W2=[KM.value(1:maxsamples,1:i) ones(maxsamples,1)]\y(1:maxsamples,:);
    yh=[KM.value(1:maxsamples,1:i) ones(maxsamples,1)]*W2;
    err(i,1:n)=mean((yh(1:maxsamples,:)-y(1:maxsamples,:)).^2);
    P=inv([KM.value(1:maxsamples,1:i) ones(maxsamples,1)]'*[KM.value(1:maxsamples,1:i) ones(maxsamples,1)]);
    mycond(i)=rcond(P);
    if mycond(1,i)>1e-017
        mydiag=[KM.value(1:maxsamples,1:i) ones(maxsamples,1)]*P*[KM.value(1:maxsamples,1:i) ones(maxsamples,1)]';
        errloo(i,1:n)=mean(((y(1:maxsamples,:)-[KM.value(1:maxsamples,1:i) ones(maxsamples,1)]*W2)./repmat((1-diag(mydiag)),1,n)).^2,1);
    else
        errloo(i,1:n)=inf;
        break
    end
    if ((i>1) && ((min(errloo(i,:)>var(y)*1.5)) || ((min(errloo(i,:)>min(errloo)*1.5)))))
        break
    end
end
clear W2 count maxsamples yh
[LOO_min_value,min_index]=min(errloo);


%% Compute estimates for best LOO
W2=zeros(max(min_index)+1,n);
yhloo=zeros(No,n);
for i=1:n
    W2(1:min_index(i)+1,i)=[KM.value(:,1:min_index(i)) ones(N,1)]\y(:,i);
    if problem=='r'
        yh(:,i)=[KM.value(:,1:min_index(i)) ones(N,1)]*W2(1:min_index(i)+1,i);
        if (N<5000)
      	    P=inv([KM.value(:,1:min_index(i)) ones(N,1)]'*[KM.value(:,1:min_index(i)) ones(N,1)]);
            mydiag=[KM.value(:,1:min_index(i)) ones(N,1)]*P*[KM.value(:,1:min_index(i)) ones(N,1)]';
            yhloo(:,i)=y(:,i)-(y(:,i)-yh(:,i))./(1-diag(mydiag));
	end
   else
        yh(:,i)=[KM.value(:,1:min_index(i)) ones(N,1)]*W2(1:min_index(i)+1,i);
        if (N<5000)
	    P=inv([KM.value(:,1:min_index(i)) ones(N,1)]'*[KM.value(:,1:min_index(i)) ones(N,1)]);
            mydiag=[KM.value(:,1:min_index(i)) ones(N,1)]*P*[KM.value(:,1:min_index(i)) ones(N,1)]';
            yhloo(:,i)=sign(y(:,i)-(y(:,i)-yh(:,i))./(1-diag(mydiag)));
	end
        yh(:,i)=sign(yh(:,i));
    end
end
KM.value=KM.value(:,1:max(min_index));
KM.function=KM.function(:,1:max(min_index));
KM.param.p1=KM.param.p1(:,1:max(min_index));
KM.param.p2=KM.param.p2(:,1:max(min_index));


%% Set the model output
model.x=x;
model.y=y;
model.KM=KM;
model.mymean=mymean;
model.mystd=mystd;
model.yh=yh;
if (N<5000)
    model.yhloo=yhloo;
end    
model.W2=W2;
model.errloo=LOO_min_value;
model.model_dim=min_index;
model.problem=problem;


%% If the problem is classification, compute confusion matrix
if problem=='c'
    for i=1:n
        model.perc_gc(1,i)=mean(y(:,i).*yhloo(:,i)+1)/2;
        model.conf_mat(i,1,1)=sum((y(:,i)==-1).*(yhloo(:,i)==-1));
        model.conf_mat(i,1,2)=sum((y(:,i)==-1).*(yhloo(:,i)==1));
        model.conf_mat(i,2,2)=sum((y(:,i)==1).*(yhloo(:,i)==1));
        model.conf_mat(i,2,1)=sum((y(:,i)==1).*(yhloo(:,i)==-1));
    end
end

