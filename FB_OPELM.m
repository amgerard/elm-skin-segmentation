function myinputs=FB_OPELM(data,input_init,kernel,maxneur,problem,normal)

% Forward-Backward based on Optimal-Pruning Extreme 
% Learning Machine algorithm
%
% myinputs = FB_OPELM( data , [input_init] , [kernel], 
%                        [maxneur], [problem] , [normal] )
%
%
% Inputs:
%          data         is a struct made of, at least:
%                       data.x  a Nxd matrix of variables
%                       data.y  a Nxn matrix of outputs
%                               (can be multi-output)
%
%          [input_init] (optional) is an initialization
%                       of the input selection to be used
%                       for the Forward-Backward algorithm.
%                       Specified as a 1xd matrix of '0' 
%                       (if the considered variable is not to 
%                       be taken) and '1' (if it is to be taken).
%                       Default is '0' everywhere.
%
%          [kernel]     (optional) is the type of kernels
%                       to use. Either 'l' (linear), 's' (sigmoid),
%                       'g' (gaussian), 'ls' (linear+sigmoid),
%                       'lg' (linear+gaussian) 
%                       or 'lsg' (linear+sigmoid+gaussian). 
%                       Default is 'lsg'.
%
%          [maxneur]    (optional) is the maximum number of
%                       neurons allowed in the model.
%                       Default is 100.
%
%          [problem]    (optional) is the type of problem.
%                       Either 'r' (regression) or 
%                       'c' (classification).
%                       Default is 'r'.
%
%          [normal]     (optional) defines whether data is to
%                       be normalized before applying OPELM.
%                       Either 'y' (yes) or 'n' (no).
%                       Default is 'y'.
%
%
%
% Output:
%          myinputs     a 1xd matrix of '1' (for the selected variables)
%                       and '0' (for the unselected).
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



%% Set a few things up
myinputs=[];

x=data.x;
y=data.y;
[N,d]=size(x);
[No,n]=size(y);


%% Test the user input extensively
if (N~=No) || (N<2)
    disp('Error: data.x and data.y do not have the same number of samples or too few samples.');
    disp('Exiting...');
    return
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


%% Check all arguments

% First, the normalization argument
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

% Second, the problem specification
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

% Third, Kernel type (since number of neurons depends on it)
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


% Fourth, Maximum number of neurons specification
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

% Fifth, the initialization of the outputs
if ~exist('input_init','var')
    disp('Warning: initialization for inputs unspecified...');
    disp('-------> Switching to zeros everywhere (none selected).');
    input_init=zeros(1,d);
else
    % Initialization is empty
    if isempty(input_init)
    disp('Warning: initialization for inputs empty...');
    disp('-------> Switching to zeros everywhere (none selected).');
    input_init=zeros(1,d);
    else
        % Initialization is specified, check it
        if (isnumeric(input_init))
            [si1,si2]=size(input_init);
            if (si1==1) && (si2==d)
                if (size(unique(input_init),2)>2) || (size(setdiff(input_init,[1 0]),2)~=0)
                    disp('Error: initialization should be a line vector with "0" and "1" for unselected and selected variables...');
                    disp('Exiting...');
                    return
                end
            else
                disp('Error: initialization should be a line vector with the same number of variables as your dataset...');
                disp('Exiting...');
                return
            end
        else
            disp('Error: initialization should be a matrix...');
            disp('Exiting...');
            return
        end
    end
end

% End of input checking


%% Prepare dataset with specified inputs
index=find(input_init);
xnew=x(:,index);
if sum(input_init)==0
    bestperf=inf;
else
    data.x=xnew;
    [model]=train_OPELM(data,kernel,maxneur,problem,normal);
    if problem=='r'
        bestperf=mean(model.errloo);
    else
        bestperf=-mean(model.perc_gc);
    end
end


%% Forward-Backward Loop using OPELM
flag=1;
bestperf2=zeros(1,d);
while flag==1
    flag=0;
    for i=1:d
        input_initnew=input_init;
        input_initnew(1,i)=-input_initnew(1,i)+1;
        index=find(input_initnew);
        xnew=x(:,index);
        if sum(input_initnew)==0
            bestperf2(i)=inf;
        else
            data.x=xnew;
            [model]=train_OPELM(data,kernel,maxneur,problem,normal);
            if problem=='r'
                bestperf2(i)=mean(model.errloo);
            else
                bestperf2(i)=-mean(model.perc_gc);
            end
        end
    end
    [I,II]=min(bestperf2);
    if I<bestperf
        bestperf=I;
        input_init(1,II)=-input_init(1,II)+1;
        flag=1;
    end
    clear bestperf2
end


%% Output the best found variables
myinputs=find(input_init);
