%--------------------------%
% By : Leny vinceslas      %
% Date : 13/02/2013        %
% Place : LPP              %
%--------------------------%
function varargout = advancedDisplay(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @advancedDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @advancedDisplay_OutputFcn, ...
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


% --- Executes just before advancedDisplay is made visible.
function advancedDisplay_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for advancedDisplay
handles.output = hObject;
handles.nDiagram=varargin{1};
handles.gravityCenter=varargin{2};
handles.vowel2disp=varargin{3};
handles.val2disp=varargin{4};
handles.nominalValues=varargin{5};
handles.idx=varargin{6};
handles.gender=varargin{7};
handles.allMeasures=varargin{8};
handles.nasal=varargin{9};
handles.elipseSTD=varargin{10};
handles.elipseMeasure=varargin{11};
handles.code2sampa=varargin{12};
handles.f2prim=varargin{13};
handles.meanf2prim=varargin{14};
handles.f2prim2disp=varargin{15};
handles.isnasal=varargin{16};
handles.idxSpeaker2disp=varargin{17};
handles.nameVowels=varargin{18};

handles.choice={'F1';'F2';'F3';'F4';'F''2';'F2-F1';'F3-F1';'F3-F2';'none'};

set(handles.popupXfunction,'string',handles.choice);
set(handles.popupXfunction,'value',1);

set(handles.popupYfunction,'string',handles.choice);
set(handles.popupYfunction,'value',2);

handles.xyFunction=ones(4,2)*9;
handles.xyFunction(1,1)=2;
handles.xyFunction(1,2)=1;
handles.button=1;
set(handles.buttonAxes1,'value',1);

set(handles.boxNasal,'value',0);
set(handles.boxNorm,'value',0);
set(handles.boxMeasures,'value',0);
set(handles.boxAll,'value',0);
handles.nasal=[0 0 0 0];
handles.norm=[0 0 0 0];
handles.stdMeasures=[0 0 0 0];
handles.allMeasures=[0 0 0 0];
handles.xyScale=cell(4,2);
handles.reversAxes=ones(4,2);
set(handles.boxRevYaxis,'value',1);
set(handles.boxRevXaxis,'value',1);
set(handles.configRadio1,'string','f2/f1');
set(handles.configRadio2,'string','none');
set(handles.configRadio3,'string','none');
set(handles.configRadio4,'string','none');

%find and set figures position
fig1 = figure(1);
pos=get(fig1,'position');
set(fig1,'position',[pos(1)+300   pos(2)   pos(3)   pos(4)]);

uipanel1_SelectionChangeFcn(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = advancedDisplay_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)

if get(handles.buttonAxes1,'value') 
    handles.button=1;
elseif get(handles.buttonAxes2,'value') 
    handles.button=2;
elseif get(handles.buttonAxes3,'value') 
    handles.button=3;
elseif get(handles.buttonAxes4,'value') 
    handles.button=4;
end

set(handles.popupXfunction,'value',handles.xyFunction(handles.button,1))
set(handles.popupYfunction,'value',handles.xyFunction(handles.button,2))

set(handles.boxNasal,'value',handles.nasal(handles.button));
set(handles.boxNorm,'value',handles.norm(handles.button));
set(handles.boxMeasures,'value',handles.stdMeasures(handles.button));
set(handles.boxAll,'value',handles.allMeasures(handles.button));

set(handles.boxRevYaxis,'value',handles.reversAxes(handles.button,2));
set(handles.boxRevXaxis,'value',handles.reversAxes(handles.button,1));

if handles.xyFunction(handles.button,1)>4 || handles.xyFunction(handles.button,2)>4
    set(handles.boxNorm,'Enable','off');
else
    set(handles.boxNorm,'Enable','on');
end

numPlot=zeros(4,1);
 nPlot=1;
for k=1:4
    if (handles.xyFunction(k,1)~=9&&handles.xyFunction(k,2)~=9) 
        numPlot(k)=1;
    end 
end

r=(numPlot(1)||numPlot(2))+(numPlot(3)||numPlot(4));
c=(numPlot(1)||numPlot(3))+(numPlot(2)||numPlot(4));  

h = zeros(1,4);
figure(1)

clf
for k=1:4%sum(sum(Plot))
    if numPlot(k)~=0  

        subplot(r,c,nPlot);
        disp_vocal_diagram(handles.nameVowels,handles.gravityCenter,...
        handles.vowel2disp,handles.val2disp,handles.nominalValues,handles.idx,handles.gender,...
        handles.allMeasures(k),handles.nasal(k),handles.norm(k),...
        handles.stdMeasures(k),handles.xyFunction(k,1),handles.xyFunction(k,2),handles.code2sampa,...
        handles.meanf2prim,handles.f2prim2disp,handles.reversAxes(k,:),handles.isnasal,handles.idxSpeaker2disp);
 
        nPlot=nPlot+1;
 
        set(handles.configRadio1,'string',[handles.choice{handles.xyFunction(1,1)} '/' handles.choice{handles.xyFunction(1,2)}]);
        set(handles.configRadio2,'string',[handles.choice{handles.xyFunction(2,1)} '/' handles.choice{handles.xyFunction(2,2)}]);
        set(handles.configRadio3,'string',[handles.choice{handles.xyFunction(3,1)} '/' handles.choice{handles.xyFunction(3,2)}]);
        set(handles.configRadio4,'string',[handles.choice{handles.xyFunction(4,1)} '/' handles.choice{handles.xyFunction(4,2)}]);
     end
end
guidata(hObject, handles);


% --- Executes on button press in boxNasal.
function boxNasal_Callback(hObject, eventdata, handles)

handles.nasal(handles.button)=get(handles.boxNasal,'value');
uipanel1_SelectionChangeFcn(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in boxNorm.
function boxNorm_Callback(hObject, eventdata, handles)

handles.norm(handles.button)=get(handles.boxNorm,'value');
uipanel1_SelectionChangeFcn(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in boxMeasures.
function boxMeasures_Callback(hObject, eventdata, handles)

handles.stdMeasures(handles.button)=get(handles.boxMeasures,'value');
uipanel1_SelectionChangeFcn(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in boxAll.
function boxAll_Callback(hObject, eventdata, handles)

handles.allMeasures(handles.button)=get(handles.boxAll,'value');
uipanel1_SelectionChangeFcn(hObject, eventdata, handles);
guidata(hObject, handles);



% --- Executes on selection change in popupXfunction.
function popupXfunction_Callback(hObject, eventdata, handles)

handles.xyFunction(handles.button,1)=get(handles.popupXfunction,'value');
handles.xyFunction(handles.button,2)=get(handles.popupYfunction,'value');
uipanel1_SelectionChangeFcn(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupXfunction_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupYfunction.
function popupYfunction_Callback(hObject, eventdata, handles)

handles.xyFunction(handles.button,1)=get(handles.popupXfunction,'value');
handles.xyFunction(handles.button,2)=get(handles.popupYfunction,'value');
uipanel1_SelectionChangeFcn(hObject, eventdata, handles);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupYfunction_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonClose.
function buttonClose_Callback(hObject, eventdata, handles)

close(figure(1))
close


% --- Executes on button press in boxRevXaxis.
function boxRevXaxis_Callback(hObject, eventdata, handles)

handles.reversAxes(handles.button,1)=get(handles.boxRevXaxis,'value');
uipanel1_SelectionChangeFcn(hObject, eventdata, handles);

% --- Executes on button press in boxRevYaxis.
function boxRevYaxis_Callback(hObject, eventdata, handles)

handles.reversAxes(handles.button,2)=get(handles.boxRevYaxis,'value');
uipanel1_SelectionChangeFcn(hObject, eventdata, handles);
