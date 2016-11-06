function varargout = gui_OPELM(varargin)
% GUI_OPELM M-file for gui_OPELM.fig
%      GUI_OPELM, by itself, creates a new GUI_OPELM or raises the existing
%      singleton*.
%
%      H = GUI_OPELM returns the handle to a new GUI_OPELM or the handle to
%      the existing singleton*.
%
%      GUI_OPELM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_OPELM.M with the given input arguments.
%
%      GUI_OPELM('Property','Value',...) creates a new GUI_OPELM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OPELM_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OPELM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_OPELM

% Last Modified by GUIDE v2.5 11-Feb-2008 15:18:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OPELM_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OPELM_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_OPELM is made visible.
function gui_OPELM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_OPELM (see VARARGIN)

% Choose default command line output for gui_OPELM
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_OPELM wait for user response (see UIRESUME)
% uiwait(handles.work);

home
if ~isempty(evalin('base','who'))
    mylist=evalin('base','who');
    set(handles.work,'UserData',mylist);
    popupmenu1_Callback(hObject, eventdata, handles)
    popupmenu2_Callback(hObject, eventdata, handles)
    popupmenu7_Callback(hObject, eventdata, handles)
    popupmenu8_Callback(hObject, eventdata, handles)
else
    disp(repmat('Workspace is empty!',200,1))
end


% --- Outputs from this function are returned to the command line.
function varargout = gui_OPELM_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


mylist=get(handles.work,'UserData');
set(handles.popupmenu1,'String',mylist);


% --- Executes during object creation, after setting all properties.
function work_CreateFcn(hObject, eventdata, handles)
% hObject    handle to work (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% --- Executes during object creation, after setting all properties.














% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

mylist=get(handles.work,'UserData');
set(handles.popupmenu2,'String',mylist);


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in Next1.
function Next1_Callback(hObject, eventdata, handles)
% hObject    handle to Next1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Kernel,'Visible','on');









% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k=[1 1 1];
k(1,1)=get(handles.checkbox1,'Value');
k(1,2)=get(handles.checkbox2,'Value');
k(1,3)=get(handles.checkbox3,'Value');
mystring='lsg';
kernel=mystring(find(k));

mylist=get(handles.work,'UserData');
number_x=get(handles.popupmenu1,'Value');
name_x=char(mylist(number_x,:));
data.x=evalin('base',name_x);
number_y=get(handles.popupmenu2,'Value');
name_y=char(mylist(number_y,:));
data.y=evalin('base',name_y);

number_x=get(handles.popupmenu7,'Value');
name_x=char(mylist(number_x,:));
data.xtest=evalin('base',name_x);
number_y=get(handles.popupmenu8,'Value');
if number_y<=length(mylist)
    name_ytest=char(mylist(number_y,:));
    data.ytest=evalin('base',name_ytest);
else
    data.ytest=[];
end

[N,d]=size(data.x);
if N>100
    if k(1,1)==0
        numberkernel=[int2str((50:50:min(N,400))')];
        numberkernelvalue=50:50:min(N,400);
    else
        numberkernel=[int2str((50:50:min(N-d-1,400))')];
        numberkernelvalue=50:50:min(N,400);
    end
else
    if k(1,1)==0
        numberkernel=[int2str((min(N,10):10:N)')];
        numberkernelvalue=min(N,10):10:N;
    else
        numberkernel=[int2str((min(N,10):10:min(N-d-1))')];
        numberkernelvalue=min(N,10):10:N;
    end
end
set(handles.nk,'Visible','on');
set(handles.popupmenu5,'String',numberkernel);




% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(handles.Problem,'Visible','on');









% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3




% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Normalisation,'Visible','on');



% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Run,'Visible','on');


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k=[1 1 1];
k(1,1)=get(handles.checkbox1,'Value');
k(1,2)=get(handles.checkbox2,'Value');
k(1,3)=get(handles.checkbox3,'Value');
mystring='lsg';
kernel=mystring(find(k));

mylist=get(handles.work,'UserData');
number_x=get(handles.popupmenu1,'Value');
name_x=char(mylist(number_x,:));
data.x=evalin('base',name_x);
number_y=get(handles.popupmenu2,'Value');
name_y=char(mylist(number_y,:));
data.y=evalin('base',name_y);

number_x=get(handles.popupmenu7,'Value');
name_x=char(mylist(number_x,:));
data.xtest=evalin('base',name_x);
number_y=get(handles.popupmenu8,'Value');
if number_y<=length(mylist)
    name_ytest=char(mylist(number_y,:));
    data.ytest=evalin('base',name_ytest);
else
    data.ytest=[];
end

[N,d]=size(data.x);
if N>100
    if k(1,1)==0
        numberkernel=[int2str((50:50:min(N,400))')];
        numberkernelvalue=50:50:min(N,400);
    else
        numberkernel=[int2str((50:50:min(N-d-1,400))')];
        numberkernelvalue=50:50:min(N,400);
    end
else
    if k(1,1)==0
        numberkernel=[int2str((min(N,10):10:N)')];
        numberkernelvalue=min(N,10):10:N;
    else
        numberkernel=[int2str((min(N,10):10:min(N-d-1))')];
        numberkernelvalue=min(N,10):10:N;
    end
end

if get(handles.radiobutton11,'Value')==1
    problem='r';
else
    problem='c';
end

if get(handles.radiobutton14,'Value')==1
    normalisation='y';
else
    normalisation='n';
end

numberselect=get(handles.popupmenu5,'Value');
numberselect=numberkernelvalue(numberselect);
[model]=train_OPELM(data,kernel,numberselect,problem,normalisation);
if isempty(model)
    return
end
model.xtest=data.xtest;
model.ytest=data.ytest;
set(handles.pushbutton11,'UserData',model);
set(handles.pushbutton11,'Visible','on');
set(handles.pushbutton12,'Visible','on');
set(handles.pushbutton13,'Visible','on');


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k=[1 1 1];
k(1,1)=get(handles.checkbox1,'Value');
k(1,2)=get(handles.checkbox2,'Value');
k(1,3)=get(handles.checkbox3,'Value');
mystring='lsg';
kernel=mystring(find(k));

mylist=get(handles.work,'UserData');
number_x=get(handles.popupmenu1,'Value');
name_x=char(mylist(number_x,:));
data.x=evalin('base',name_x);
number_y=get(handles.popupmenu2,'Value');
name_y=char(mylist(number_y,:));
data.y=evalin('base',name_y);

number_x=get(handles.popupmenu7,'Value');
name_x=char(mylist(number_x,:));
data.xtest=evalin('base',name_x);
number_y=get(handles.popupmenu8,'Value');
if number_y<=length(mylist)
    name_ytest=char(mylist(number_y,:));
    data.ytest=evalin('base',name_ytest);
else
    data.ytest=[];
end

[N,d]=size(data.x);
if N>100
    if k(1,1)==0
        numberkernel=[int2str((50:50:min(N,400))')];
        numberkernelvalue=50:50:min(N,400);
    else
        numberkernel=[int2str((50:50:min(N-d-1,400))')];
        numberkernelvalue=50:50:min(N,400);
    end
else
    if k(1,1)==0
        numberkernel=[int2str((min(N,10):10:N)')];
        numberkernelvalue=min(N,10):10:N;
    else
        numberkernel=[int2str((min(N,10):10:min(N-d-1))')];
        numberkernelvalue=min(N,10):10:N;
    end
end

if get(handles.radiobutton11,'Value')==1
    problem='r';
else
    problem='c';
end

if get(handles.radiobutton14,'Value')==1
    normalisation='y';
else
    normalisation='n';
end

numberselect=get(handles.popupmenu5,'Value');
numberselect=numberkernelvalue(numberselect);
myinputs=FB_OPELM(data,zeros(1,d),kernel,numberselect,problem,normalisation);
if isempty(myinputs)
    return
end
data_select.x=data.x(:,myinputs);
data_select.xtest=data.xtest(:,myinputs);
data_select.y=data.y;
[model]=train_OPELM(data_select,kernel,numberselect,problem,normalisation);
model.selected_variables=myinputs;
model.xtest=data.xtest(:,myinputs);
model.ytest=data.ytest;
set(handles.pushbutton11,'UserData',model);
set(handles.pushbutton11,'Visible','on');
set(handles.pushbutton12,'Visible','on');
set(handles.pushbutton13,'Visible','on');

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k=[1 1 1];
k(1,1)=get(handles.checkbox1,'Value');
k(1,2)=get(handles.checkbox2,'Value');
k(1,3)=get(handles.checkbox3,'Value');
mystring='lsg';
kernel=mystring(find(k));

mylist=get(handles.work,'UserData');
number_x=get(handles.popupmenu1,'Value');
name_x=char(mylist(number_x,:));
data.x=evalin('base',name_x);
number_y=get(handles.popupmenu2,'Value');
name_y=char(mylist(number_y,:));
data.y=evalin('base',name_y);

number_x=get(handles.popupmenu7,'Value');
name_x=char(mylist(number_x,:));
data.xtest=evalin('base',name_x);
number_y=get(handles.popupmenu8,'Value');
if number_y<=length(mylist)
    name_ytest=char(mylist(number_y,:));
    data.ytest=evalin('base',name_ytest);
else
    data.ytest=[];
end

[N,d]=size(data.x);
if N>100
    numberkernel=[int2str((50:50:min(N,400))')];
    numberkernelvalue=50:50:min(N,400);
else
    numberkernel=[int2str((min(N,10):10:N)')];
    numberkernelvalue=min(N,10):10:N;
end

if get(handles.radiobutton11,'Value')==1
    problem='r';
else
    problem='c';
end

if get(handles.radiobutton14,'Value')==1
    normalisation='y';
else
    normalisation='n';
end

numberselect=get(handles.popupmenu5,'Value');
numberselect=numberkernelvalue(numberselect);
myinputs=LARS_Selection_OPELM(data,kernel,numberselect,problem,normalisation);
if isempty(myinputs)
    return
end

data_select.x=data.x(:,myinputs);
data_select.xtest=data.xtest(:,myinputs);
data_select.y=data.y;
[model]=train_OPELM(data_select,kernel,numberselect,problem,normalisation);
model.selected_variables=myinputs;
model.xtest=data.xtest(:,myinputs);
model.ytest=data.ytest;
set(handles.pushbutton11,'UserData',model);
set(handles.pushbutton11,'Visible','on');
set(handles.pushbutton12,'Visible','on');
set(handles.pushbutton13,'Visible','on');

% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
model=get(handles.pushbutton11,'UserData');

[filename,pathname] = uiputfile('default','Save your results');
 
if pathname == 0 %if the user pressed cancelled, then we exit this callback
    return
end
%construct the path name of the save location
saveDataName = fullfile(pathname,filename); 
 
save(saveDataName,'model')




% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

model=get(handles.pushbutton11,'UserData');
model


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k=[1 1 1];
k(1,1)=get(handles.checkbox1,'Value');
k(1,2)=get(handles.checkbox2,'Value');
k(1,3)=get(handles.checkbox3,'Value');
mystring='lsg';
kernel=mystring(find(k));

mylist=get(handles.work,'UserData');
number_x=get(handles.popupmenu7,'Value');
name_x=char(mylist(number_x,:));
data.x=evalin('base',name_x);
number_y=get(handles.popupmenu8,'Value');
if number_y<=length(mylist)
    name_y=char(mylist(number_y,:));
    data.y=evalin('base',name_y);
else
    data.y=[];
end

model=get(handles.pushbutton11,'UserData');

if isfield(model,'selected_variables')
    data.x=data.x(:,model.selected_variables);
end
model.xtest=data.x;
model.ytest=data.y;

[yh,error]=sim_OPELM(model,data);
model.errortest=error;
model.ytesth=yh;
set(handles.pushbutton11,'UserData',model);

disp(repmat('Test is done!',200,1))


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7

mylist=get(handles.work,'UserData');
set(handles.popupmenu7,'String',mylist);

% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8

mylist=get(handles.work,'UserData');
mylist=[mylist;'unknown'];
set(handles.popupmenu8,'String',mylist);

% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes4
A=imread('tspcitop_mini.jpg');
image(A)
set(gca,'Visible','off')





% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://www.cis.hut.fi/projects/tsp/')

