%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
% Auteur : Leny vinceslas                                   %
% Date : 02/05/2013                                         %
% Place : Laboratoire de Phonetique et de Phonologie, Paris3%
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
%
%
% This function performe a formant analysis
% path:access path to the folder contening the sound file.
% nominalValues: structure of tables of nominal formants value for
% different language and sexe
% list: list of files to be analyzed
% selectedSpeakers: speakers to be analyzed 

function [data]=formant_analysis(path,nominalValues,list,selectedSpeakers)

totalMeanFormants=[];
testFormantEstimation=[];
nameVowels=cell(0,0);
idxSpeaker=[];
nasale=1;
k=1;

for nFile=1:length(list)
    file=list{nFile};
    
    %if findstr(name,'wav')  
        nameVowels{k}=file(12:end-7);
       if isempty(findstr(nameVowels{k},'n')) 
           isnasal(k)=0;
       else 
           isnasal(k)=1;
       end
        
        folder=file(1:10);
        
        if file(3)=='h' 
            gender(k)=1; 
        end; 
        if file(3)=='f' 
            gender(k)=2; 
        end; 
        gender(k)=1;%%%%%%%%% stuck gender at 1 and let users choose ref file
        
        % Look for the idx of the vowel, empty if nasal or unknown name
        IDX=find(strcmp(nominalValues.idx,nameVowels(k)),1);
        if isempty(IDX) IDX=NaN; end
        idx(k)=IDX ;
        
        if isempty(idxSpeaker)
        idxSpeaker(k)=1;
        elseif findstr(list{k}(1:6),list{k-1}(1:6))
            idxSpeaker(k)=idxSpeaker(k-1);
        else
            idxSpeaker(k)=idxSpeaker(k-1)+1;
        end
        
        
        if ~isnan(idx(k))||nasale
        [x, Fs]=wavread([path '\' folder '\' file]);
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
        xVoiced{k}=x(voiced);
        %LPC estimation
        [ai I residu tres{k}]=LPC_estimation(xVoiced{k},fs,WLen,Hop,ordre);
        
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
      
%------f2prim, formula from "Two-formant Models, Pitch and Vowel ---------%
       %Perception, Rolf Carlson, Gunnar Fant and Bjorn Granstrom,KTM"

       % to simplify the equantion
       f1=meanFormants(1);
       f2=meanFormants(2);
       f3=meanFormants(3);
       f4=meanFormants(4);
       
       %coef 
       b2=67;
       kf=12*(f2/1400);
       
       %equations
       A34byA2=(b2*f2*(1-(f1^2/f2^2))*(1-(f2^2/f3^2))*(1-(f2^2/f4^2)))/ ((f4-f3)^2*((f3*f4)/(f2^2)-1));
       c=kf*A34byA2;
       f2prim{k}=(f2+c^2*(f3*f4)^(1/2))/(1+c^2);
%-------------------------------------------------------------------------%      
       
%test estimation
if ~isnan(idx(k))
for j=1:4
    if abs(meanFormants(j)-nominalValues.formants{gender(k)}(idx(k),j))<...
            nominalValues.tolerence{gender(k)}(idx(k),j)
        %if formant is into the nominal value estimation is OK 
        testFormantEstimation(k,j)=1;
        disp(['        test F' num2str(j) ' OK']);
    else
        %if formant is outside the nominal value estimation is wrong 
        testFormantEstimation(k,j)=0;
        disp(['        test F' num2str(j) ' failed']);
    end
end
else
    testFormantEstimation(k,1:4)=2;
    disp('      no test      ');
end
       totalMeanFormants(end+1,:)=roundn(meanFormants,0);
       totalFormants{k}=roundn(formants,0);
       
      %clear variables
       formants=[];
       meanFormants=[];

       k=k+1;%increase the index of analyzed files
       %pause
        end
end
 
% average per vowel
vowel2disp=unique(nameVowels);
for k=1:length(vowel2disp)
    same=strcmp(vowel2disp{k},nameVowels);
        gravityCenter(k,:)=roundn(mean(totalMeanFormants(same==1,:),1),0);
        valSTD(k,:)=roundn(std(totalMeanFormants(same==1,:),0,1),0);
        val2disp{k}=roundn(totalMeanFormants(same==1,:),0);
        f2prim2disp{k}=f2prim(same==1);
        meanf2prim{k}=round(mean([f2prim{:,same==1}]));
        idxSpeaker2disp{k}=idxSpeaker(same==1);
end

%save into struct
data.idxSpeaker2disp=idxSpeaker2disp;
data.isnasal=isnasal;
data.valSTD=valSTD;
data.totalFormants=totalFormants;
data.totalMeanFormants=totalMeanFormants;
data.val2disp=val2disp;
data.vowel2disp=vowel2disp;
data.gravityCenter=gravityCenter;
data.testFormantEstimation=testFormantEstimation;
data.idx=idx;
data.gender=gender;
data.nameVowels=nameVowels;
data.xVoiced=xVoiced;
data.nominalValues=nominalValues;
data.tres=tres;
data.fs=fs;
data.f2prim=f2prim;
data.meanf2prim=meanf2prim;
data.f2prim2disp=f2prim2disp;
end