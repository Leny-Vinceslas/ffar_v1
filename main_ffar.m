%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
% Auteur : Leny vinceslas                                   %
% Date : 02/05/2013                                         %
% Place : Laboratoire de Phonetique et de Phonologie, Paris3%
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
%
% This function is the main GUI of the Vowel Formant main_ffar 
% and Repesentation tool.
% In order to start, main_ffar needs ffar_ini.txt and ffar_ini.txt in
% the same folder
         

function varargout = main_ffar(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_ffar_OpeningFcn, ...
                   'gui_OutputFcn',  @main_ffar_OutputFcn, ...
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

 
% --- Executes just before main_ffar is made visible.
function main_ffar_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Add path
addpath(genpath('m_files'));

% Load init file
fid=fopen('ffar_ini.txt');
[handles.initFile] = textscan(fid,'%s %s', 'delimiter', '\t');
fclose(fid);

% If the default sound location is empty, open uigetdir popup
if isempty(handles.initFile{1,2}{1,1})
    [handles.path]=uigetdir('C:','Select the audio files location. You must indicate the folder contening the speaker folders.');
    handles.initFile{1,2}{1,1}=handles.path;
    handles.list=dir(handles.path);  
    % write new directory 
    fid=fopen('ffar_ini.txt','w+');
    for k=1:size(handles.initFile{1,1},1)
        fprintf(fid,'%s\t%s\r\n',handles.initFile{1,1}{k},handles.initFile{1,2}{k:k});  
    end
    fclose(fid);
else
    handles.path=handles.initFile{1,2}{1,1};
    handles.list=dir(handles.path);
    while numel(handles.list)==0
        [handles.path]=uigetdir('C:','Select the audio files location. You must indicate the folder contening the speaker folders.');
        handles.initFile{1,2}{1,1}=handles.path;
        handles.list=dir(handles.path);
    end
    % write new directory 
    fid=fopen('ffar_ini.txt','w+'); 
    for k=1:size(handles.initFile{1,1},1)
         fprintf(fid,'%s\t%s\r\n',handles.initFile{1,1}{k},handles.initFile{1,2}{k:k});  
    end
        fclose(fid);
end

% delete the 2 first results in the name list    
for k=numel(handles.list):-1:1
    if handles.list(k).isdir==0 || length(handles.list(k).name)<3 
        handles.list(k)=[]; end
end

% initialize variables
handles.nominalValues=[];
handles.totalFormants=[];
handles.totalMeanFormants=[];
handles.val2disp=[];
handles.vowel2disp=[];
handles.gravityCenter=[];
handles.testFormantEstimation=[];
handles.nameVowels=[];
handles.nDiagram=1;
handles.choice={'F1';'F2';'F3';'F4';'F2-F1';'F3-F1';'F3-F2'};
handles.allMeasures=0;
handles.nasal=0;
handles.elipseSTD=0;
handles.elipseMeasure=0;
handles.speakersID = {handles.list.name};
handles.nTable=1;
handles.reversAxes=ones(1,2);

% set buttons state
set(handles.axes1,'Tag','axes1');
set(handles.radiobutton1,'value',1);
set(handles.radiobutton2,'value',0);
set(handles.radiobutton3,'value',0);
set(handles.checkboxNorme,'value',0);
set(handles.checkboxMeasure,'value',0);
set(handles.checkboxAll,'value',0);
set(handles.checkboxNasal,'value',0);
set(handles.listbox1, 'String',handles.speakersID);
set(handles.axes1,'XLim',[400 3000],'YLim',[100 1100])
set(handles.axes1, 'YAxisLocation', 'right');
set(handles.axes1, 'XAxisLocation', 'top');
set(get(handles.axes1,'YLabel'),'String','F1');
set(get(handles.axes1,'XLabel'),'String','F2');
set(handles.axes1,'XDir','rev','YDir','rev');
set(handles.menuSave,'Enable','off');
set(handles.button_AdvancedDisplay,'Enable','off');
set(handles.uitable, 'ColumnName',{'F1' 'F2' 'F3' 'F4' 'F''2'},'data',[]);
set(handles.popupReferenceFormantFiles,'Enable','off');

% Find location of reference formant values file
handles.listRefFormantTextFiles=handles.initFile{1,2}(3:end);
handles.nameRefFormantTextFiles=strfind(handles.listRefFormantTextFiles(:),'\');

for k=1:size(handles.listRefFormantTextFiles,1)
    handles.nameRefFormantTextFiles{k}=handles.listRefFormantTextFiles{k}(handles.nameRefFormantTextFiles{k}(end)+1:end-4);
end

set(handles.popupReferenceFormantFiles,'string',handles.nameRefFormantTextFiles);
set(handles.popupReferenceFormantFiles,'value',numel(handles.nameRefFormantTextFiles));
 
    path=handles.listRefFormantTextFiles{numel(handles.nameRefFormantTextFiles)};
    fid = fopen(path);
    txtFile = textscan(fid,'%s %f %f %f %f %f %f %f %f', 'delimiter',' ','HeaderLines',1);
    fclose(fid);
    handles.nominalValues.idx=txtFile{1};
    
    for k=1:4 % cell 1= male values
        handles.nominalValues.formants{1}(:,k)=txtFile{k*2}; 
        handles.nominalValues.std{1}(:,k)=txtFile{1+k*2}; 
        handles.nominalValues.tolerence{1}(:,k)=1.96*handles.nominalValues.std{1}(:,k);%tresh*nominalValues.female.formants(:,k);       
    end


% Load conversion table code2sampa

fid = fopen(handles.initFile{1,2}{2,1});
txtFile = textscan(fid,'%s %s', 'delimiter', ' ','HeaderLines',1);
fclose(fid);
handles.code2sampa(1,:)=txtFile{:,1};
handles.code2sampa(2,:)=txtFile{:,2};

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = main_ffar_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)



% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)

% initialize variables
handles.filesID=[];
handles.selectedFiles=[];
handles.listinfo=[];
handles.infotxt=[];

%get the selected speakers
handles.selectedSpeakers=handles.speakersID((get(handles.listbox1, 'value')));

%find the wave and info files
for k=1:length(handles.selectedSpeakers)
list=dir([handles.path '\' handles.selectedSpeakers{k} '\*.wav']); %core/*MIC.wav
handles.filesID=[handles.filesID {list(:).name}];
listinfo=dir([handles.path '\' handles.selectedSpeakers{k} '\*info.txt']);
handles.listinfo=[handles.listinfo listinfo];
fid = fopen([handles.path '\' handles.selectedSpeakers{k} '\' listinfo.name]);
 if fid==-1
     handles.infotxt{k}='No info file';
 else
     temp = textscan(fid,'%s','Delimiter','\n');
     fclose(fid);
     handles.infotxt{k} = temp{1};
 end
end

%set listboxes, info-text and info-menu startAnalysis Button.
set(handles.listbox2,'value',[]);
if isempty(handles.filesID)
set(handles.listbox2, 'String',[]);
set(handles.infomenu,'String',[]);
set(handles.text1,'string',[]);
set(handles.startAnalysis,'Enable','off');
set(handles.popupReferenceFormantFiles,'Enable','off');
else
set(handles.listbox2, 'String',handles.filesID);
set(handles.listbox2, 'Value',1:numel(handles.filesID));
handles.selectedFiles=handles.filesID;
set(handles.infomenu,'String',handles.selectedSpeakers);
set(handles.text1,'string',handles.infotxt{1});
set(handles.startAnalysis,'Enable','on');
set(handles.popupReferenceFormantFiles,'Enable','on');
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)

handles.selectedFiles=handles.filesID((get(handles.listbox2, 'value')));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over listbox1.
function listbox1_ButtonDownFcn(hObject, eventdata, handles)



% --- Executes on button press in startAnalysis.
function startAnalysis_Callback(hObject, eventdata, handles)

%show busy mode
set(handles.figure1, 'pointer', 'watch')
drawnow;

[data]=formant_analysis(handles.path,handles.nominalValues,handles.selectedFiles,handles.selectedSpeakers);
handles = CATSTRUCT(handles,data);

% Display formant values in the table
switch handles.nTable
    case 1
    handles.totalMeanFormants_cell=[];
    % use HTML to highlight cells in red
    for k=1:size(handles.totalMeanFormants,1)
        for j=1:size(handles.totalMeanFormants,2)
            if handles.testFormantEstimation(k,j)==1
                handles.totalMeanFormants_cell{k,j}=...
                num2str(handles.totalMeanFormants(k,j));
            elseif handles.testFormantEstimation(k,j)==2
                handles.totalMeanFormants_cell{k,j} = strcat(...
                '<html><span style="color: #808080; ">', ...
                num2str(handles.totalMeanFormants(k,j)), ...
                '</span></html>');
            else
                handles.totalMeanFormants_cell{k,j} = strcat(...
                '<html><span style="color: #FF0000; font-weight: bold;">', ...
                num2str(handles.totalMeanFormants(k,j)), ...
                '</span></html>');
            end
        end
        if handles.testFormantEstimation(k,:)==1
            f2prim{k}=num2str(round(handles.f2prim{k}));
        elseif handles.testFormantEstimation(k,j)==2
            f2prim{k} = strcat(...
            '<html><span style="color: #808080; ">', ...
            num2str(round(handles.f2prim{k})), ...
            '</span></html>');
        else
            f2prim{k} = strcat(...
            '<html><span style="color: #FF0000; font-weight: bold;">', ...
            num2str(round(handles.f2prim{k})), ...
            '</span></html>');
        end
    end
set(handles.uitable, 'RowName',handles.nameVowels,'ColumnName',{'F1' 'F2' 'F3' 'F4' 'F''2'},'data',[handles.totalMeanFormants_cell f2prim']);
   
    case 2
        handles.totalMeanFormants_cell=[];
        for k=1:size(handles.gravityCenter,1)
            for j=1:size(handles.gravityCenter,2)
                handles.totalMeanFormants_cell{k,j}=...
                num2str(handles.gravityCenter(k,j));  
            end
            f2{k}=num2str(round(handles.meanf2prim{k}));
        end
        set(handles.uitable, 'RowName',handles.vowel2disp,'ColumnName',{'F1' 'F2' 'F3' 'F4' 'F''2'},'data',[handles.totalMeanFormants_cell f2']);
end

cla reset
handles.x=2;% Show f2 on x axis
handles.y=1;%Show f1 on y axis
set(handles.radiobutton1,'value',1);

%Display the diagram
 disp_vocal_diagram(handles.nameVowels,handles.gravityCenter,...
     handles.vowel2disp,handles.val2disp,handles.nominalValues,handles.idx,handles.gender,...
     handles.allMeasures,handles.nasal,handles.elipseSTD,handles.elipseMeasure,...
     handles.x,handles.y,handles.code2sampa,handles.meanf2prim,handles.f2prim2disp,...
     handles.reversAxes,handles.isnasal,handles.idxSpeaker2disp);

%Enable button
set(handles.radiobutton1,'Enable','on');
set(handles.radiobutton2,'Enable','on');
set(handles.radiobutton3,'Enable','on');
set(handles.radiobuttonAllMeasures,'Enable','on');
set(handles.radiobuttonAverage,'Enable','on');
set(handles.checkboxNasal,'Enable','on');
set(handles.checkboxNorme,'Enable','on');
set(handles.checkboxMeasure,'Enable','on');
set(handles.checkboxAll,'Enable','on');
set(handles.menuSave,'Enable','on');
set(handles.button_AdvancedDisplay,'Enable','on');

%quit busy mode
set(handles.figure1, 'pointer', 'arrow')
guidata(hObject, handles);


% --- Executes on button press in checkboxMeasure.
function checkboxMeasure_Callback(hObject, eventdata, handles)

%get elipse button state
handles.elipseMeasure=get(handles.checkboxMeasure,'Value');

%display the diagram
cla reset
disp_vocal_diagram(handles.nameVowels,handles.gravityCenter,...
     handles.vowel2disp,handles.val2disp,handles.nominalValues,handles.idx,handles.gender,...
     handles.allMeasures,handles.nasal,handles.elipseSTD,handles.elipseMeasure,...
     handles.x,handles.y,handles.code2sampa,handles.meanf2prim,handles.f2prim2disp,...
     handles.reversAxes,handles.isnasal,handles.idxSpeaker2disp);

guidata(hObject, handles);

% --- Executes on button press in checkboxNorme.
function checkboxNorme_Callback(hObject, eventdata, handles)

%get elipseSTD button state
handles.elipseSTD=get(handles.checkboxNorme,'Value');

%display diagram
cla reset
disp_vocal_diagram(handles.nameVowels,handles.gravityCenter,...
    handles.vowel2disp,handles.val2disp,handles.nominalValues,handles.idx,handles.gender,...
    handles.allMeasures,handles.nasal,handles.elipseSTD,handles.elipseMeasure,...
    handles.x,handles.y,handles.code2sampa,handles.meanf2prim,handles.f2prim2disp,...
     handles.reversAxes,handles.isnasal,handles.idxSpeaker2disp);
guidata(hObject, handles);

% --- Executes on button press in checkboxNasal.
function checkboxNasal_Callback(hObject, eventdata, handles)

%Get nasal button state
handles.nasal=get(handles.checkboxNasal,'Value');

%Display diagram
cla reset
disp_vocal_diagram(handles.nameVowels,handles.gravityCenter,...
    handles.vowel2disp,handles.val2disp,handles.nominalValues,handles.idx,handles.gender,...
    handles.allMeasures,handles.nasal,handles.elipseSTD,handles.elipseMeasure,...
    handles.x,handles.y,handles.code2sampa,handles.meanf2prim,handles.f2prim2disp,...
     handles.reversAxes,handles.isnasal,handles.idxSpeaker2disp);

guidata(hObject, handles);

% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)

%Set the X and Y axes to display function of tue radio button
switch get(eventdata.NewValue,'Tag')
    case 'radiobutton1'
       handles.nDiagram=1; 
       handles.x=2;
       handles.y=1;
    case 'radiobutton2'
       handles.nDiagram=2; 
       handles.x=2;
       handles.y=3;
    case 'radiobutton3'
       handles.nDiagram=3; 
       handles.x=3;
       handles.y=1;
end

%Display diagram
cla reset
disp_vocal_diagram(handles.nameVowels,handles.gravityCenter,...
    handles.vowel2disp,handles.val2disp,handles.nominalValues,handles.idx,handles.gender,...
    handles.allMeasures,handles.nasal,handles.elipseSTD,handles.elipseMeasure,...
    handles.x,handles.y,handles.code2sampa,handles.meanf2prim,handles.f2prim2disp,...
    handles.reversAxes,handles.isnasal,handles.idxSpeaker2disp);

guidata(hObject, handles);


% --- Executes on button press in checkboxAll.
function checkboxAll_Callback(hObject, eventdata, handles)

% Get allMeasures button status
handles.allMeasures=get(handles.checkboxAll,'Value');

% Display diagram
cla reset
disp_vocal_diagram(handles.nameVowels,handles.gravityCenter,...
    handles.vowel2disp,handles.val2disp,handles.nominalValues,handles.idx,handles.gender,...
    handles.allMeasures,handles.nasal,handles.elipseSTD,handles.elipseMeasure,...
    handles.x,handles.y,handles.code2sampa,handles.meanf2prim,handles.f2prim2disp,...
    handles.reversAxes,handles.isnasal,handles.idxSpeaker2disp);
 
guidata(hObject, handles);


function menuSave_Callback(hObject, eventdata, handles)



% --------------------------------------------------------------------
function menuOpen_Callback(hObject, eventdata, handles)

% Open getdir box and get speaker ID from the folder 
[handles.path]=uigetdir('C:','Select the audio files location. You must indicate the folder contening the speaker folders.');
handles.list=dir(handles.path);
handles.initFile{1,2}{1,1}=handles.path;
% write new directory 
fid=fopen('ffar_ini.txt','w+'); 
for k=1:size(handles.initFile{1,1},1)
    fprintf(fid,'%s\t%s\r\n',handles.initFile{1,1}{k},handles.initFile{1,2}{k:k});  
end
fclose(fid);
% delete the 2 first results in the name list    
for k=numel(handles.list):-1:1
    if handles.list(k).isdir==0 || length(handles.list(k).name)<3 
        handles.list(k)=[]; end
end

handles.speakersID = {handles.list.name};

% Set the listbox
set(handles.listbox1, 'String',handles.speakersID);

guidata(hObject, handles);

% --- Executes on selection change in infomenu.
function infomenu_Callback(hObject, eventdata, handles)

%Get and display the info files
temp=get(handles.infomenu,{'String','Value'});
str=temp{1}{temp{2}};
set(handles.text1,'string',handles.infotxt{temp{2}});
guidata(hObject, handles);

function infomenu_CreateFcn(hObject, eventdata, handles)

function save_fig_Callback(hObject, eventdata, handles)

defaultName=[];
if numel(handles.selectedSpeakers)>1
    for k=1:numel(handles.selectedSpeakers)
    defaultName=[defaultName handles.selectedSpeakers{k} '_'];
    end   
    path=[handles.path '\' defaultName ];
else 
    defaultName=handles.selectedSpeakers{1};
    path=[handles.path '\' defaultName '\' defaultName '_'];
end
switch handles.nDiagram
    case 1
        path=[path 'F1F2'];
    case 2
       path=[path 'F2F3'];
    case 3
       path=[path 'F1F3'];
end

% Popup putfile box 
[file path]=uiputfile({'*.fig';'*.eps'},'Save plot as',path);

%Execute if path and file are filled
if file~=0 && path~=0
invisibleFig=figure;
set(invisibleFig,'visible','off');
copyobj(handles.axes1,invisibleFig);
set(gca,'Unit','Normalized');
set(gca,'Position',[0.07 0.07 0.85 0.85]);
axis square;
set(gcf,'Unit','Normalized');
set(gcf,'Position',[0 0 0.5 0.5]);
saveas(invisibleFig,[path file]);
close figure(invisibleFig);
end
guidata(hObject, handles);

function save_table_Callback(hObject, eventdata, handles)

%if number of speaker is greater than 1 change the saving path
defaultName=[];
if numel(handles.selectedSpeakers)>1
    for k=1:numel(handles.selectedSpeakers)
    defaultName=[defaultName handles.selectedSpeakers{k} '_'];
    end   
    path=[handles.path '\' defaultName ];
else 
    defaultName=handles.selectedSpeakers{1};
    path=[handles.path '\' defaultName '\' defaultName '_'];
end
 
%Select file name regarding the observed data
if handles.nTable==1
    path=[path 'all_formant_values.txt'];
    nan=ones(size(handles.totalMeanFormants,1),1)*NaN;
    formants2Save=[handles.totalMeanFormants(:,1) nan...
        handles.totalMeanFormants(:,2) nan...
        handles.totalMeanFormants(:,3) nan...
        handles.totalMeanFormants(:,4) nan...
        cell2mat(handles.f2prim)'];
    vowels2save=handles.nameVowels;
else
    path=[path 'average_formant_values.txt'];
    formants2Save=[handles.gravityCenter(:,1) handles.valSTD(:,1)...
        handles.gravityCenter(:,2) handles.valSTD(:,2)...
        handles.gravityCenter(:,3) handles.valSTD(:,3)...
        handles.gravityCenter(:,4) handles.valSTD(:,4)...
        cell2mat(handles.meanf2prim)'];
    vowels2save=handles.vowel2disp;
end

%Popup putfile box
[file path]=uiputfile('*.txt','Save formants table as',path);

%Execute if path and file are filled
if ~isempty(file) && ~isempty(path)      
    fid =fopen([path '\' file],'w+');
    fprintf(fid,'vowels f1 std f2 std f3 std f4 std f2''\r\n');%header
    for k=1:size(formants2Save,1)
          fprintf(fid,'%s %.0f %.0f %.0f %.0f %.0f %.0f %.0f %.0f %.0f \r\n',vowels2save{k},formants2Save(k,:));%,f2Prim(k))
    end
    fclose(fid);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)



% --- Executes when selected object is changed in panelTableDisplayOption.
function panelTableDisplayOption_SelectionChangeFcn(hObject, eventdata, handles)

%Display the data in the table
switch get(eventdata.NewValue,'Tag')
    
    case 'radiobuttonAllMeasures'% display all the measures
        handles.nTable=1;
        handles.totalMeanFormants_cell=[];
        
% use HTML to highlight cells
        for k=1:size(handles.totalMeanFormants,1)
            for j=1:size(handles.totalMeanFormants,2)
                if handles.testFormantEstimation(k,j)==1
                    handles.totalMeanFormants_cell{k,j}=...
                    num2str(handles.totalMeanFormants(k,j));
                elseif handles.testFormantEstimation(k,j)==2
             handles.totalMeanFormants_cell{k,j} = strcat(...
            '<html><span style="color: #808080; ">', ...
            num2str(handles.totalMeanFormants(k,j)), ...
            '</span></html>');
                else
                    handles.totalMeanFormants_cell{k,j} = strcat(...
                    '<html><span style="color: #FF0000; font-weight: bold;">', ...
                    num2str(handles.totalMeanFormants(k,j)), ...
                    '</span></html>');
                end
            end
            %f2prim{k}=num2str(round(handles.f2prim{k}));    
            if handles.testFormantEstimation(k,:)==1
                f2prim{k}=num2str(round(handles.f2prim{k}));
            elseif handles.testFormantEstimation(k,j)==2
                f2prim{k} = strcat(...
                '<html><span style="color: #808080; ">', ...
                num2str(round(handles.f2prim{k})), ...
                '</span></html>');
            else
                f2prim{k} = strcat(...
                '<html><span style="color: #FF0000; font-weight: bold;">', ...
                num2str(round(handles.f2prim{k})), ...
                '</span></html>');
            end
        end
        set(handles.uitable, 'RowName',handles.nameVowels,'ColumnName',{'F1' 'F2' 'F3' 'F4' 'F''2'},'data',[handles.totalMeanFormants_cell f2prim']);
   
    case 'radiobuttonAverage' %display the mean for each formant
        handles.nTable=2;
        handles.totalMeanFormants_cell=[];
        for k=1:size(handles.gravityCenter,1)
            for j=1:size(handles.gravityCenter,2)
                handles.totalMeanFormants_cell{k,j}=...
                num2str(handles.gravityCenter(k,j));  
            end
            f2{k}=num2str(round(handles.meanf2prim{k}));
        end
        set(handles.uitable, 'RowName',handles.vowel2disp,'ColumnName',{'F1' 'F2' 'F3' 'F4' 'F''2'},'data',[handles.totalMeanFormants_cell f2']);
end


guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in uitable.
function uitable_CellSelectionCallback(hObject, eventdata, handles)

obj=findjobj(handles.uitable);

%Get the selected row
handles.rows=obj.getComponent(0).getComponent(0).getSelectedRows+1;

%Do not pop up if the displayed values are the formants average
if handles.nTable==1 && ~isempty(handles.rows)
    [handles.details_selectedFiles]=handles.selectedFiles{handles.rows};
    [handles.details_selectedSpeakers]=handles.details_selectedFiles(1:10);
    
% Pop up the detailed main_ffar window
    detailed_analysis(handles.path,handles.details_selectedFiles,...
        handles.details_selectedSpeakers,handles.totalFormants{handles.rows},...
        handles.totalMeanFormants(handles.rows,:),handles.testFormantEstimation(handles.rows,:),...
        handles.idx(handles.rows),handles.gender(handles.rows),handles.nameVowels{handles.rows},...
        handles.xVoiced{handles.rows},handles.nominalValues,handles.tres{handles.rows},...
        handles.fs);
end

guidata(hObject, handles);


% --- Executes on button press in button_AdvancedDisplay.
function button_AdvancedDisplay_Callback(hObject, eventdata, handles)

% Pop up the advanced display window
advancedDisplay(handles.nDiagram,handles.gravityCenter,...
     handles.vowel2disp,handles.val2disp,handles.nominalValues,handles.idx,handles.gender,...
     handles.allMeasures,handles.nasal,handles.elipseSTD,handles.elipseMeasure,...
     handles.code2sampa,handles.f2prim,handles.meanf2prim,handles.f2prim2disp,...
     handles.isnasal,handles.idxSpeaker2disp,handles.nameVowels);

 
 guidata(hObject, handles);

function menuFile_Callback(hObject, eventdata, handles)


function menuAdd_Callback(hObject, eventdata, handles)

% Add a new table of reference formants 
[file path]=uigetfile('*.txt','Save formants table as',':/');

handles.initFile{1,2}{end+1}=[path file];
handles.initFile{1,1}{end+1}='New reference formant values:';

% Read the file
 fid=fopen('ffar_ini.txt','w+');
  for k=1:min(size(handles.initFile{1,1},1),size(handles.initFile{1,2},1))
            fprintf(fid,'%s\t%s\r\n',handles.initFile{1,1}{k},handles.initFile{1,2}{k,:});
  end
  fclose(fid);
  
handles.listRefFormantTextFiles{end+1}=[path file];
handles.nameRefFormantTextFiles{end+1}=file(1:end-4);
set(handles.popupReferenceFormantFiles,'string',handles.nameRefFormantTextFiles);
set(handles.popupReferenceFormantFiles,'value', length(handles.nameRefFormantTextFiles));

popupReferenceFormantFiles_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


function popupReferenceFormantFiles_CreateFcn(hObject, eventdata, handles)

% --- Executes on selection change in popupReferenceFormantFiles.
function popupReferenceFormantFiles_Callback(hObject, eventdata, handles)

fileID=get(handles.popupReferenceFormantFiles,'value');
path=handles.listRefFormantTextFiles{fileID}; 

handles.nominalValues.formants=[];
handles.nominalValues.std=[];
handles.nominalValues.tolerence=[];
handles.nominalValues.idx=[];

% Load male nominal values
fid = fopen(path);
txtFile = textscan(fid,'%s %f %f %f %f %f %f %f %f %f', 'delimiter',' ','HeaderLines',1);
fclose(fid);
handles.nominalValues.idx=txtFile{1};
for k=1:4 % cell 1= male values
handles.nominalValues.formants{1}(:,k)=txtFile{k*2}; 
handles.nominalValues.std{1}(:,k)=txtFile{1+k*2}; 
handles.nominalValues.tolerence{1}(:,k)=1.96*handles.nominalValues.std{1}(:,k);%tresh*nominalValues.female.formants(:,k);       
end

% Look for the idx of the vowel, empty if nasal or unknown name

if ~isempty(handles.nameVowels)
for k=1:length(handles.nameVowels)
    IDX=find(strcmp(handles.nominalValues.idx,handles.nameVowels(k)),1);
    if isempty(IDX) IDX=NaN; end
    handles.idx(k)=IDX;
end

if ~isempty(handles.gravityCenter)
    % Display diagram
    cla
    disp_vocal_diagram(handles.nameVowels,handles.gravityCenter,...
        handles.vowel2disp,handles.val2disp,handles.nominalValues,handles.idx,handles.gender,...
        handles.allMeasures,handles.nasal,handles.elipseSTD,handles.elipseMeasure,...
        handles.x,handles.y,handles.code2sampa,handles.meanf2prim,handles.f2prim2disp,...
        handles.reversAxes,handles.isnasal,handles.idxSpeaker2disp);
end
end
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%close main_ffar
delete(hObject);


% --- Executes on button press in exit_button.
function exit_button_Callback(hObject, eventdata, handles)
close main_ffar
