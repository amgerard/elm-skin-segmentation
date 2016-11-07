function [yh,error]=sim_OPELM(model,data)

% Simulation the Optimal-Pruning Extreme Learning
% Machine obtained model on a different dataset
%
% [yh,error] = sim_OPELM( model , data )
%
%
% Inputs:
%          model     a struct containing the model
%                    previously obtained by the
%                    train_OPELM function.
%
%          data      is a struct made of, at least:
%                    data.x  a Nxd matrix of variables
%                    (optional) data.y  a Nxn matrix 
%                               of outputs
%                               (can be multi-output)
%
%
% Outputs:
%          yh        the estimated output by the model.
%
%          error     the mean square error (for regression problem)
%                    or classification error with confusion matrix
%                    (for classification problem). Computed only
%                    if data.y is specified.
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


%% Test user input extensively
if (nargin~=2)
    disp('Error: two arguments required: model from train_OPELM and dataset.')
    disp('Exiting...')
    return
end

% First, check the data
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
        if (~isfield(data,{'x'}))
            % Data has not the required field
            disp('Error: data set does not have data.x field.')
            disp('Exiting...')
            return
        else
            x=data.x;
            [N,d]=size(x);
            if (~isfield(data,{'y'}))
                % Data does not have any data.y field
                y=[];
                n=size(model.y,2);
            else
                % Data has the two fields data.x and data.y
                y=data.y;
                [No,n]=size(y);
                if (N~=No) || (N<2)
                    disp('Error: data.x and data.y do not have the same number of samples or too few samples.');
                    disp('Exiting...');
                    return
                end
            end
        end
    end

end

% Second, check the model
if isempty(model)
    % Model is empty
    disp('Error: model is empty.')
    disp('Exiting...')
    return
else
    % Model is here, check it
    if (~isstruct(model))
        % Model is not a struct
        disp('Error: model is not a struct. Use train_OPELM to generate a proper model.')
        disp('Exiting...')
        return
    else
        % Model is a struct, check it
        if (~isfield(model,{'x','y','KM','mymean','mystd','model_dim','problem'}))
            % Model does not have the required fields for proper sim
            disp('Error: model does not have the required fields for simulation.')
            disp('       use train_OPELM to generate a proper model.')
            disp('Exiting...')
            return
        else
            % Model has the fields, check them
            if (~isfield(model.KM,{'param','function','value'}))
                % Kernel Matrix does not have proper structure
                disp('Error: model kernel matrix does not have proper structure.')
                disp('       use train_OPELM to generate a proper model.')
                disp('Exiting...')
                return
            else
                % Kernel Matrix has the fields, check them
                if (~isfield(model.KM.param,{'p1','p2'}))
                    % Kernel matrix param misses parameters p1 or p2
                    disp('Error: model kernel matrix does not have proper structure.')
                    disp('       use train_OPELM to generate a proper model.')
                    disp('Exiting...')
                    return
                else
                    % Kernel Matrix param has the fields, check function
                    if (~iscell(model.KM.function))
                        % Kernel Matrix function list does not have cell
                        % structure
                        disp('Error: model kernel matrix does not have proper structure.')
                        disp('       use train_OPELM to generate a proper model.')
                        disp('Exiting...')
                        return
                    end
                end
            end
        end
    end
end

% End of input checking


%% Set a few things up
mymean=model.mymean;
mystd=model.mystd;
model_dim=model.model_dim;
KM=model.KM;


%% Normalize data
for i=1:d
    x(:,i)=(x(:,i)-mymean(:,i))/mystd(i);
end


%% Evaluate values for output estimation
value=[];
for i=1:max(model_dim)
    if strcmp(KM.function(i),'l')
        value=[value x(:,KM.param.p2(i))];
    end
    if strcmp(KM.function(i),'s')
        value=[value tanh(x*KM.param.p1(:,i)+ones(N,1)*KM.param.p2(:,i))];
    end
    if strcmp(KM.function(i),'g')
        value=[value gaussian_func(x,KM.param.p1(:,i)',KM.param.p2(:,i))];
    end
end


%% Evaluate output and error
if model.problem=='r'
    error=zeros(1,n);
end
yh=zeros(N,n);
for i=1:n
    W2(1:model_dim(i)+1,1)=model.W2(1:model_dim(i)+1,i);
    if model.problem=='r'
        yh(:,i)=[value(:,1:model_dim(i)) ones(N,1)]*W2(1:model_dim(i)+1,1);
        if (~isempty(y))
            error(1,i)=mean((y(:,i)-yh(:,i)).^2);
        else
            error=[];
        end
    else
        if (~isempty(y))
            yh(:,i)=sign([value(:,1:model_dim(i)) ones(N,1)]*W2(1:model_dim(i)+1,1));
            error.perc_gc(1,i)=mean(y(:,i).*yh(:,i)+1)/2;
            error.conf_mat(i,1,1)=sum((y(:,i)==-1).*(yh(:,i)==-1));
            error.conf_mat(i,1,2)=sum((y(:,i)==-1).*(yh(:,i)==1));
            error.conf_mat(i,2,2)=sum((y(:,i)==1).*(yh(:,i)==1));
            error.conf_mat(i,2,1)=sum((y(:,i)==1).*(yh(:,i)==-1));
        else
            error(1,i)=[];
        end
    end
    clear W2
end

