%function  vocal_diagram( userID )
%VOCAL_DIAGRAM Summary of this function goes here
%   Detailed explanation goes here
clear all
%close 5;
%addpath('Formants_tracking/');
%addpath('Formants_tracking/boersmapitch');
 
directory=('C:\Users\Leny\Documents\audio\voyelles Laurianne\test\fff111-001\');
list=dir([directory '*.wav']);
totalMeanFormants=zeros(0,0);
nameVowels=cell(0,0);
f=0;
nasale=1;
%tresh=0.125;
dispanalysis=1;

%load formant average table from "Analyse formantique des voyelles orales du français en 
%contexte isolé : à la recherche d’une référence pour les 
%apprenants de FLE. Georgeton Laurianne, Paillereau Nikola, Landron Simon, Gao Jiayin, Kamiyama Takeki"   
% and data from Gendro
fid = fopen('C:\Users\Leny\Documents\MATLAB\Programmation-ProjetJV- modifié\script-matlab\AcousticRecording\InitiationFiles\male nominal values.txt');
txtFile = textscan(fid,'%s %f %f %f %f %f %f %f %f', 'delimiter', ' ','HeaderLines',2);
fclose(fid);
for k=1:4 % cell 1= male values
nominalValues.formants{1}(:,k)=txtFile{k*2}; 
nominalValues.std{1}(:,k)=txtFile{1+k*2}; 
nominalValues.tolerence{1}(:,k)=2*nominalValues.std{1}(:,k);%tresh*nominalValues.female.formants(:,k);       
end
nominalValues.idx=txtFile{1};
fid = fopen('C:\Users\Leny\Documents\MATLAB\Programmation-ProjetJV- modifié\script-matlab\AcousticRecording\InitiationFiles\female nominal values.txt');
txtFile = textscan(fid,'%s %f %f %f %f %f %f %f %f', 'delimiter', ' ','HeaderLines',2);
fclose(fid);
for k=1:4 %cell 2=female values
nominalValues.formants{2}(:,k)=txtFile{k*2}; 
nominalValues.std{2}(:,k)=txtFile{1+k*2}; 
nominalValues.tolerence{2}(:,k)=2*nominalValues.std{2}(:,k);%tresh*nominalValues.female.formants(:,k);       
end
%nominalValues.female.tolerence(:,1)=tresh*nominalValues.female.formants(:,1)+20; 


k=1;
for nFile=1:length(list)
    name=list(nFile).name;
    
    %if findstr(name,'wav')  
      % if 1%(findstr(name,'n') && nasale)
        nameVowels{k}=name(12:end-7);
        if name(3)=='h' 
            gender(k)=1; 
        end; 
        if name(3)=='f' 
            gender(k)=2; 
        end; 
        
        % Look for the idx of the vowel, empty if nasal or unknown name
        IDX=find(strcmp(nominalValues.idx,nameVowels(k)),1);
        if isempty(IDX) IDX=NaN; end
        idx(k)=IDX;
        
        if ~isnan(idx(k))||nasale
        [x, Fs]=wavread([directory,name]);
        disp(['------- vowel:',num2str(k),nameVowels(k),'-------']);
        %keep only ch1 if stereo signal
        x=x(:,1);
        
        %downsampling
        fs=12000;
        x=resample(x,fs,Fs);
      
        %window settings
        step=0.015; %10
        Win_length=0.030; %20
        WLen=round(Win_length*fs);  % convertion en échantillon
        Hop=round(step*fs);         % conversion en échantillon
        ordre=12;%round(fs/1000+2);          % Ordre du filtre de contour spectral
    
        %LP filtering 50 HZ
        [b50hz,a50hz]=butter(2,50/(fs/2),'high');
        x=filtfilt(b50hz,a50hz,x);
        t=1/fs:1/fs:length(x)/fs;
        
        %pitch analysis
        [t_f0s f0s t_f0d f0d t_f0 f0]=pitch_estimation(x,fs,0.01*fs);
        %keep only voiced part
        voiced=f0s>100;%~=0;
        xVoiced=x(voiced);

        %LPC estimation
        [ai I residu tres{k}]=LPC_estimation(xVoiced,fs,WLen,Hop,ordre);
        %[formant_tracks,pitch_track] = ftrack(x,fs);
        %get formant value
        for j=1:size(ai,1) 
             [formants(j,:)]=ones(10,1)*NaN;
             buff=get_formant_value(ai(j,:),fs);
             [formants(j,1:length(buff))]=buff;
        end
        
       % track the formant paths 
       [formants,tres{k}]=test_tracking(formants,tres{k},0);
       
        % average over 3 points 1/3 1/2 2/3
        for j=2:4
        meanFormants(j-1,:)=formants(ceil(j*size(formants,1)/6),1:4);
        end

       meanFormants=mean(meanFormants);
        
       %f2prim, formula from "Two-formant Models, Pitch and Vowel
       %Perception, Rolf Carlson, Gunnar Fant and Bjorn Granstrom,KTM"
       c=((meanFormants(1)/500)^2) *...
           (((meanFormants(2)-meanFormants(1))/(meanFormants(4)-meanFormants(3)))^4) *...
           (((meanFormants(3)-meanFormants(2))/(meanFormants(3)-meanFormants(1)))^2);
       
       f2prim(k)=(meanFormants(2)+((c*(meanFormants(3)*meanFormants(4)))^(1/2)))/(1+c);
       
%test estimation
if ~isnan(idx(k))
for j=1:4
    if abs(meanFormants(j)-nominalValues.formants{gender(k)}(idx(k),j))<...
            nominalValues.tolerence{gender(k)}(idx(k),j)
        %if formant is into the nominal value estimation is OK 
        testFormantEstimation(k,j)=1;
        disp('        test 1 OK');
    else
        %if formant is outside the nominal value estimation is wrong 
        testFormantEstimation(k,j)=0;
        disp('     test 1 failed');
    end
end
else
    %testFormantEstimation(idx(k),j)=NaN;
    disp('      no test      ');
end
       totalMeanFormants(end+1,:)=meanFormants;
       totalFormants{k}=formants;
       
      %clear variables
       formants=[];
       meanFormants=[];

       k=k+1;%increase the index of analyzed files
       %pause
        end
     %end
end
 
% average per vowel
vowel2disp=unique(nameVowels);
for k=1:length(vowel2disp)
    same=strcmp(vowel2disp{k},nameVowels);
        gravityCenter(k,:)=mean(totalMeanFormants(same==1,:),1);
        val2disp{k}=totalMeanFormants(same==1,:);
end

% save formant values into .txt 
saveAll=0; % 1:save average 2:save all measures

        fid =fopen([directory 'average_formant_values_' name(1:10) '.txt'],'w+');
        fprintf(fid,'vowels f1 f2 f3 f4 f2''\r\n');%header
            for k=1:size(gravityCenter,1)
                fprintf(fid,'%s %.0f %.0f %.0f %.0f\r\n',vowel2disp{k},gravityCenter(k,:));%,f2Prim(k))
            end
            fclose(fid);
    
    if size(nameVowels,2)>size(gravityCenter,1)
        fid =fopen([directory 'all_formant_values_' name(1:10) '.txt'],'w+');
        fprintf(fid,'vowels f1 f2 f3 f4 f2''\r\n');%header
            for k=1:length(nameVowels)
                fprintf(fid,'%s %.0f %.0f %.0f %.0f\r\n',nameVowels{k},totalMeanFormants(k,:));%,f2Prim(k))
            end
            fclose(fid);
    end
   

 if 1  
 for k=1:size(totalMeanFormants,1)
     
        if isnan(idx(k))   
        %compute nominal formant values line
        lineF1=ones(size(totalFormants{k},1),1)*mean(totalFormants{k}(:,1));
        lineF2=ones(size(totalFormants{k},1),1)*mean(totalFormants{k}(:,2));
        lineF3=ones(size(totalFormants{k},1),1)*mean(totalFormants{k}(:,3));  
        lineF4=ones(size(totalFormants{k},1),1)*mean(totalFormants{k}(:,4));
        else
        %idx=find(strcmp(nominalValues.idx,nameVowels(k))==1);
        %compute nominal formant values line
        lineF1=ones(size(totalFormants{k},1),1)*nominalValues.formants{gender(k)}(idx(k),1);
        lineF2=ones(size(totalFormants{k},1),1)*nominalValues.formants{gender(k)}(idx(k),2);
        lineF3=ones(size(totalFormants{k},1),1)*nominalValues.formants{gender(k)}(idx(k),3);  
        lineF4=ones(size(totalFormants{k},1),1)*nominalValues.formants{gender(k)}(idx(k),4);
        %compute 95% doted lines
        lineF1std(:,1:2)=ones(size(totalFormants{k},1),1)*(nominalValues.formants{gender(k)}(idx(k),1)+nominalValues.std{gender(k)}(idx(k),1).*[2 -2]);
        lineF2std(:,1:2)=ones(size(totalFormants{k},1),1)*(nominalValues.formants{gender(k)}(idx(k),2)+nominalValues.std{gender(k)}(idx(k),2).*[2 -2]);
        lineF3std(:,1:2)=ones(size(totalFormants{k},1),1)*(nominalValues.formants{gender(k)}(idx(k),3)+nominalValues.std{gender(k)}(idx(k),3).*[2 -2]);
        lineF4std(:,1:2)=ones(size(totalFormants{k},1),1)*(nominalValues.formants{gender(k)}(idx(k),4)+nominalValues.std{gender(k)}(idx(k),4).*[2 -2]);
       end

     if dispanalysis==1 
         
       nfig=ceil(k/16);
       figure(nfig)
       subplot(4,4,k-((nfig-1)*16));
       [S]=sp(xVoiced,fs,256,60,10);
       hold on
       plot(tres{k}*10^3,totalFormants{k}','.');
       plot(tres{k}*10^3,lineF1,'k-.');
       plot(tres{k}*10^3,lineF2,'k-.');
       plot(tres{k}*10^3,lineF3,'k-.');
       plot(tres{k}*10^3,lineF4,'k-.');
       title(nameVowels{k});
       
    if ~isnan(idx(k))
       if testFormantEstimation(k,1)
       plot(tres{k}*10^3,lineF1std,'g-.');
       else
       plot(tres{k}*10^3,lineF1std,'r-.');    
       end
       if testFormantEstimation(k,2)
       plot(tres{k}*10^3,lineF2std,'g-.');
       else
       plot(tres{k}*10^3,lineF2std,'r-.');    
       end
       if testFormantEstimation(k,3)
       plot(tres{k}*10^3,lineF3std,'g-.');
       else
       plot(tres{k}*10^3,lineF3std,'r-.');   
       end
       if testFormantEstimation(k,4)
       plot(tres{k}*10^3,lineF4std,'g-.');
       else
       plot(tres{k}*10^3,lineF4std,'r-.');    
       end
    end
          %hold off
     end
     hold off
       %pause  

      %clear variables
       lineF1=[];
       lineF2=[];
       lineF3=[];
       lineF1std=[];
       lineF2std=[];
       lineF3std=[];
       lineF4std=[];
 end
 end
%  j=1;
%  while ~isempty(totalMeanFormants)
% %j=length(totalMeanFormants);
% same=0;
% same=strcmp(nameVowels,nameVowels{1});
% val2disp(j,:)=mean(totalMeanFormants(same==1,:),1);
% vowel2disp{j}=nameVowels{1};
% totalMeanFormants(same==1,:)=[];
% nameVowels(same==1)=[];
% j=j+1;
%  end
 

%triangle conf
allMeasures=1;
nasal=1;
mixMalFem=1;
elipseSTD=0;
elipseMeasure=0;
%color plot vowels
color=[1 0 0;0 1 1;1 0 1;1 .843 0;0 1 0;...
    0 0 1;0 0 0;1 .647 0;.557 .557 .22;...
    .698 .133 .133;.821 .821 .821]	;
colorCount=1;
%plot vocal diagram
for j=1:size(gravityCenter,1)    
    h=figure(5);
    %plot f1/f2
    subplot(2,2,1);hold on; grid on;
    if ~isnan(idx(j))
        plot(gravityCenter(j,2),gravityCenter(j,1),'r+');
        text(gravityCenter(j,2),gravityCenter(j,1), vowel2disp{j},'color',color(colorCount,:),...
        'FontWeight','bold','FontSize',16,'HorizontalAlignment','center');
        if allMeasures
            plot(val2disp{j}(:,2),val2disp{j}(:,1),'+','color',color(colorCount,:));
        end
        if elipseSTD 
            elipse2(nominalValues.tolerence{gender(j)}(idx(j),2),nominalValues.tolerence{gender(j)}(idx(j),1)...
            ,0,nominalValues.formants{gender(j)}(idx(j),2),nominalValues.formants{gender(j)}(idx(j),1),color(colorCount,:));
        end
        if elipseMeasure
            if size(val2disp{j},1)>1
            [e]=ellipse(val2disp{j}(:,2),val2disp{j}(:,1));
            plot(e(1,:),e(2,:),'-.','color',color(colorCount,:),'LineWidth',1.5);
            end
        end
    elseif nasal
        plot(gravityCenter(j,2),gravityCenter(j,1),'r+');
        text(gravityCenter(j,2),gravityCenter(j,1), vowel2disp{j},'color',color(end,:),...
        'FontWeight','bold','FontSize',16,'HorizontalAlignment','center');
        if allMeasures
            plot(val2disp{j}(:,2),val2disp{j}(:,1),'+','color',color(end,:));
        end
        if elipseMeasure
            if size(val2disp{j},1)>1
            [e]=ellipse(val2disp{j}(:,2),val2disp{j}(:,1));
            plot(e(1,:),e(2,:),'-.','color',color(end,:),'LineWidth',1.5);
            end
        end
    end
    set(gca,'XDir','rev','YDir','rev')
    set(gca, 'YAxisLocation', 'right');
    set(gca, 'XAxisLocation', 'top');
    set(get(gca,'YLabel'),'String','F1');
    set(get(gca,'XLabel'),'String','F2');
    hold off



subplot(2,2,2)%f3/f2
hold on
grid on
    if ~isnan(idx(j))
        plot(gravityCenter(j,3),gravityCenter(j,2),'r+');
        text(gravityCenter(j,3),gravityCenter(j,2), vowel2disp{j},'color',color(colorCount,:),...
        'FontWeight','bold','FontSize',16,'HorizontalAlignment','center');
        if allMeasures
            plot(val2disp{j}(:,3),val2disp{j}(:,2),'+','color',color(colorCount,:));
        end
        if elipseSTD 
            elipse2(nominalValues.tolerence{gender(j)}(idx(j),3),nominalValues.tolerence{gender(j)}(idx(j),2)...
            ,0,nominalValues.formants{gender(j)}(idx(j),3),nominalValues.formants{gender(j)}(idx(j),2),color(colorCount,:));
        end
        if elipseMeasure
            if size(val2disp{j},1)>1
            [e]=ellipse(val2disp{j}(:,3),val2disp{j}(:,2));
            plot(e(1,:),e(2,:),'-.','color',color(colorCount,:),'LineWidth',1.5);
            end
        end
    elseif nasal
        plot(gravityCenter(j,3),gravityCenter(j,2),'r+');
        text(gravityCenter(j,3),gravityCenter(j,2), vowel2disp{j},'color',color(end,:),...
        'FontWeight','bold','FontSize',16,'HorizontalAlignment','center');
        if allMeasures
            plot(val2disp{j}(:,3),val2disp{j}(:,2),'+','color',color(end,:));
        end
        if elipseMeasure
            if size(val2disp{j},1)>1
            [e]=ellipse(val2disp{j}(:,3),val2disp{j}(:,2));
            plot(e(1,:),e(2,:),'-.','color',color(end,:),'LineWidth',1.5);
            end
        end
    end
set(gca,'XDir','rev','YDir','rev')
set(gca, 'YAxisLocation', 'right');
set(gca, 'XAxisLocation', 'top');
set(get(gca,'YLabel'),'String','F2');
set(get(gca,'XLabel'),'String','F3');
hold off

subplot(2,2,3)%f3/f1
hold on
grid on
    if ~isnan(idx(j))
        plot(gravityCenter(j,3),gravityCenter(j,1),'r+');
        text(gravityCenter(j,3),gravityCenter(j,1), vowel2disp{j},'color',color(colorCount,:),...
        'FontWeight','bold','FontSize',16,'HorizontalAlignment','center');
        if allMeasures
            plot(val2disp{j}(:,3),val2disp{j}(:,1),'+','color',color(colorCount,:));
        end
        if elipseSTD 
            elipse2(nominalValues.tolerence{gender(j)}(idx(j),3),nominalValues.tolerence{gender(j)}(idx(j),1)...
            ,0,nominalValues.formants{gender(j)}(idx(j),3),nominalValues.formants{gender(j)}(idx(j),1),color(colorCount,:));
        end
        if elipseMeasure
            if size(val2disp{j},1)>1
            [e]=ellipse(val2disp{j}(:,3),val2disp{j}(:,1));
            plot(e(1,:),e(2,:),'-.','color',color(colorCount,:),'LineWidth',1.5);
            end
        end
        colorCount=colorCount+1;
    elseif nasal
        plot(gravityCenter(j,3),gravityCenter(j,1),'r+');
        text(gravityCenter(j,3),gravityCenter(j,1), vowel2disp{j},'color',color(end,:),...
        'FontWeight','bold','FontSize',16,'HorizontalAlignment','center');
        if allMeasures
            plot(val2disp{j}(:,3),val2disp{j}(:,1),'+','color',color(end,:));
        end
        if elipseMeasure
            if size(val2disp{j},1)>1
            [e]=ellipse(val2disp{j}(:,3),val2disp{j}(:,1));
            plot(e(1,:),e(2,:),'-.','color',color(end,:),'LineWidth',1.5);
            end
        end
    end
set(gca,'XDir','rev','YDir','rev')
set(gca, 'YAxisLocation', 'right');
set(gca, 'XAxisLocation', 'top');
set(get(gca,'YLabel'),'String','F1');
set(get(gca,'XLabel'),'String','F3');
hold off


% saveas(2,[directory 'f2f1.fig']);
% saveas(3,[directory 'f3f2.fig']);
% saveas(4,[directory 'f3f1.fig']);
end

%tout afficher ou juste average
%choix affichage ellipe crible ou recorded data

%construire crible pour detecter les mauvaises estimations
% revoir valeur crible
%plot zone voyelle if plusieurs recordings

%Save into PDF/jpeg/eps + text file txtgrid  format ?

%try viterbi

%try http://www.cns.bu.edu/~speech/ftrack.php

%ellipse crible

%problem F2 i (09)  et F2 U (01)

%diff f1-f2
%end

