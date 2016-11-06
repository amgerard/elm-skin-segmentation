function myinputs=LARS_Selection_OPELM(data,kernel,maxneur,problem,normal)

% Least Angle Regression (LARS) based on Optimal-Pruning 
% Extreme Learning Machine algorithm
%
% myinputs = LARS_Selection_OPELM( data , [kernel] , [maxneur], 
%                                 [problem] , [normal] )
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
%
% Output:
%          myinputs   a 1xd matrix of '1' (for the selected variables)
%                     and '0' (for the unselected).

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

% End of input checking


%% Initialize indexes
index=1:d;
[W,i1] = mrsr(y,x,d);
index=index(i1);
perf=zeros(1,d);

%% Loop and find the best ranking by LARS
for i=1:d
    data.x=x(:,index(1:i));
    [model]=train_OPELM(data,kernel,maxneur,problem,normal);
    if problem=='r'
        perf(i)=mean(model.errloo);
    else
        perf(i)=-mean(model.perc_gc);
    end
end
[I,II]=min(perf);

%% Output the best ranking of variables
myinputs=index(1:II);



