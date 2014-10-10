%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
% Auteur : Leny vinceslas                                   %
% Date : 02/05/2013                                         %
% Place : Laboratoire de Phonetique et de Phonologie, Paris3%
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
%
% This function open a gui showing detailled features of the formant analysis.  
% 
function varargout = detailed_analysis(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @detailed_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @detailed_analysis_OutputFcn, ...
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


% --- Executes just before detailed_analysis is made visible.
function detailed_analysis_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

%Get and store arguments
handles.path=varargin{1};
handles.details_selectedFiles=varargin{2};
handles.details_selectedSpeakers=varargin{3};
handles.totalFormants=varargin{4};
handles.totalMeanFormants=varargin{1,5};
handles.testFormantEstimation=varargin{1,6};
handles.idx=varargin{1,7};
handles.gender=varargin{1,8};
handles.gender=1;%varargin{1,8};
handles.nameVowels=varargin{1,9};
handles.xVoiced=varargin{1,10};
handles.nominalValues=varargin{1,11};
handles.tres=varargin{1,12};
handles.fs=varargin{1,13};

%Set interface
set(handles.checkbox_norms,'value',1)
set(handles.checkbox_markers,'value',1)
set(handles.checkbox_means,'value',1)
set(handles.axes1,'Tag','axes1');
set(handles.axes2,'Tag','axes2');
set(handles.text1,'string',handles.nameVowels);
set(handles.text1,'FontName','Script','FontSize',20);

%Inatialize variables
handles.lineF1std=[];  
handles.lineF2std=[];  
handles.lineF3std=[];  
handles.lineF4std=[];  
handles.lineF1=[];  
handles.lineF2=[];  
handles.lineF3=[];  
handles.lineF4=[]; 
  
clear handles.lines

%Set OpenGL as graphical renderer in order to allow trasparency
set(gcf,'Renderer','OpenGL')

%%%%%%%%%%%% Plot wave form %%%%%%%%%%%%%%%%%%%
axes(handles.axes1);
t=(1:length(handles.xVoiced))/handles.fs*1000;
plot(handles.axes1,t,handles.xVoiced);  %%%%%unité
hold on
grid on
axis manual on xy;
xlabel('Time (ms)');
ylabel('Amplitude');
set(gca,'XLim',[0 max(t)],'YLim',[min(handles.xVoiced)-0.2 max(handles.xVoiced)+0.2],'Box','On'); 
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~isnan(handles.idx)   
     %compute transparent bars with confidence interval at 95%
        handles.lineF1std(:,1:2)=ones(size(handles.totalFormants,1),1)*...
            (handles.nominalValues.formants{handles.gender}(handles.idx,1)+...
            handles.nominalValues.tolerence{handles.gender}(handles.idx,1).*[1 -1]);
        handles.lineF1std(:,1:2)=ones(size(handles.totalFormants,1),1)*...
            (handles.nominalValues.formants{handles.gender}(handles.idx,1)+...
            handles.nominalValues.tolerence{handles.gender}(handles.idx,1).*[1 -1]);    
        handles.lineF2std(:,1:2)=ones(size(handles.totalFormants,1),1)*...
            (handles.nominalValues.formants{handles.gender}(handles.idx,2)+...
            handles.nominalValues.tolerence{handles.gender}(handles.idx,2).*[1 -1]);
        handles.lineF3std(:,1:2)=ones(size(handles.totalFormants,1),1)*...
            (handles.nominalValues.formants{handles.gender}(handles.idx,3)+...
            handles.nominalValues.tolerence{handles.gender}(handles.idx,3).*[1 -1]);
        handles.lineF4std(:,1:2)=ones(size(handles.totalFormants,1),1)*...
            (handles.nominalValues.formants{handles.gender}(handles.idx,4)+...
            handles.nominalValues.tolerence{handles.gender}(handles.idx,4).*[1 -1]);
         handles.lineStd=([handles.lineF1std(1,:);handles.lineF2std(1,:);...
            handles.lineF3std(1,:);handles.lineF4std(1,:)]);
end
 %compute nominal formant values line
        handles.lineF1=ones(size(handles.totalFormants,1),1)*nanmean(handles.totalFormants(:,1));
        handles.lineF2=ones(size(handles.totalFormants,1),1)*nanmean(handles.totalFormants(:,2));
        handles.lineF3=ones(size(handles.totalFormants,1),1)*nanmean(handles.totalFormants(:,3));  
        handles.lineF4=ones(size(handles.totalFormants,1),1)*nanmean(handles.totalFormants(:,4));
        handles.lines=[handles.lineF1 handles.lineF2 handles.lineF3 handles.lineF4];
        
% Update handles structure
uipanel1_SelectionChangeFcn(hObject, eventdata, handles)

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = detailed_analysis_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
guidata(hObject, handles);


% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)

close 


% --- Executes on button press in checkbox_markers.
function checkbox_markers_Callback(hObject, eventdata, handles)

uipanel1_SelectionChangeFcn(hObject, eventdata, handles)

% --- Executes on button press in checkbox_means.
function checkbox_means_Callback(hObject, eventdata, handles)

uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes on button press in checkbox_norms.
function checkbox_norms_Callback(hObject, eventdata, handles)

uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)

axes(handles.axes2);  
cla reset 
[S]=sp(handles.xVoiced,handles.fs,256,60,10);
hold on
  %title(nameVowels{k});
  if get(handles.checkbox_markers,'value')
    for k=1:size(handles.totalFormants,2)
        [handles.sc]=scatter(handles.tres*10^3,handles.totalFormants(:,k),'filled');
    end
  end
       
  if get(handles.checkbox_means,'value')
      
     handles.p=plot(handles.tres*10^3,handles.lines,'-.','LineWidth',1.3);
  end
      
  if get(handles.checkbox_norms,'value')   
    if ~isnan(handles.idx)
        for k=1:length(handles.testFormantEstimation)
            if handles.testFormantEstimation(k)
                color='g';
            else
                color='r';
            end
            p=patch([S(1) S(end) S(end) S(1)],[handles.lineStd(k,2)...
            handles.lineStd(k,2) handles.lineStd(k,1) handles.lineStd(k,1)],color);
            set(p,'FaceAlpha',0.3);set(p,'Edgecolor','none');
        end
    end
  end
    hold off
    guidata(hObject, handles);


% --- Executes on button press in pushbutton_play.
function pushbutton_play_Callback(hObject, eventdata, handles)

%apply fade-in and fade-out to the signal
fade_length = round(handles.fs*0.01);
fade_in= linspace(0,1,fade_length)';
fade_out=linspace(1,0,fade_length)';
sig_faded = handles.xVoiced;
sig_faded(1:fade_length) = handles.xVoiced(1:fade_length).*fade_in;
sig_faded(end+1-fade_length:end) = handles.xVoiced(end+1-fade_length:end).*fade_out;

%play Sound
soundsc(sig_faded,handles.fs);
%soundsc(handles.xVoiced,handles.fs);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)




function edit1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
