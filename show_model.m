function show_model( model )

% Displays the content of a previously computed model
%
% show_model( model )
%
%
% Inputs:
%          model        is a model computed using the 
%                       train_OPELM function.


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


%% Check the model in argument
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

[N,d]=size(model.x);
[No,n]=size(model.y);


%% Displays the contents of the model
if (strcmp(model.problem,'r'))
    problem='regression';
    gc=[];
else
    problem='classification';
    gc=model.perc_gc;
end
if (n>1)
    output='multi';
else
    output='one dimensional';
end

message1=sprintf('Model for %s, build on %dx%d data, %s output.',problem,N,d,output);
disp(message1);
message2=sprintf('Uses %d neurons; LOO error is %d.',model.model_dim,model.errloo);
disp(message2);
if (~isempty(gc))
    message_gc=sprintf('Good classification rate achieved: %d.',gc);
    disp(message_gc);
end

indices=find(strcmp(model.KM.function,'l'));

if (~isempty(indices))
    message3=sprintf('Uses following variables linearly: %s',mat2str(indices));
    disp(message3);
end