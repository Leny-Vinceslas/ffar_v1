%Vocoder LPC avec modification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By : Thibaut FUX         %
% thibaut.fux@hotmail.Fr   %
% Date : 19/10/2012        %
% Place : LPP              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc
addpath('boersmapitch/')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
direcotry_in='sons/';
directory_out='output/';
filename='i.wav';
D=[300 200 100 0 -100 -200 -300 -400 -500 -600 ...
    -700 -800 -900 -1000 -1100 -1200 -1300 -1400 ...
    -1500 -1600 -1700 -1800 -1900 -2000 -2100 -2200 ...
    -2300 -2400 -2500 -2600 -2700];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outfull=[];
indx=2;
tmp=0;

for j=1:10length(D)

    %ouverture du fichier son
    [s_org Fs]=wavread([direcotry_in filename]);
    
    %re-echantillonnage
    s=resample(s_org(:,1),16000,Fs);
    Fs=16000;
    
    %filtrage 50 HZ
    [b50hz,a50hz]=butter(2,50/(Fs/2),'high');
    s=filtfilt(b50hz,a50hz,s);
    
    t=1/Fs:1/Fs:length(s)/Fs;
    
    
    %Paramètre du vocodeur
    Win_length=0.020;           
    step=0.010; 
    WLen=round(Win_length*Fs);  % convertion en échentillon
    Hop=round(step*Fs);         % conversion en échantillon
    ordre=(Fs/1000+2);          % Ordre du filtre de contour spectral
    

    %%%%%%%%%%%%%%%%%%%%%%%%ANALYSE%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [t_f0s f0s t_f0d f0d t_f0 f0]=pitch_estimation(s,Fs,0.01*Fs);
    [ai I residu tres]=LPC_estimation(s,Fs,WLen,Hop,ordre);

        %Verification de la qualité de la resynthèse sans modification
    [output3]=vocoder(t,residu,Fs,ai,WLen,Hop);
    output3=filter(1,[1 -0.95],output3);

    
    %%%%%%%%%%%%%%%%CALCUL ET AFFICHAGE DES FORMANT%%%%%%%%%%%%%%%%%%%%%%%%%%

    for i=1:length(ai)
        [Fx_tmp]=get_formant_value(ai(i,:),Fs);
        Fx(i,1:length(Fx_tmp))=Fx_tmp;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %Modification de la position des formants
    for i=1:length(ai)
    [tmp indx]=min(abs(t_f0s-tres(i)));
        if(f0s(indx)>0) % Ne modifie le filtre que si la trame est voisée
            [ai_mod(i,:)]=formant_shift(ai(i,:),Fs,[0 0 D(j)]);
        else
            ai_mod(i,:)=ai(i,:);
        end
    end

    [output]=vocoder(t,residu,Fs,ai_mod,WLen,Hop);
    output=filter(1,[1 -0.95],output);
    wavwrite(output./(1.1*max(output)),Fs,[directory_out filename(1:end-4) '_' num2str(D(j)) '.wav']);
    
    
    %%%%%%%%%%%%%%%%CALCUL ET AFFICHAGE DES FORMANT%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ai_out]=LPC_estimation(output,Fs,WLen,Hop,ordre);

    for i=1:length(ai)
        [Fx_tmp]=get_formant_value(ai_out(i,:),Fs);
        Fx_out(i,1:length(Fx_tmp))=Fx_tmp;
    end
    
    
    mid=round(length(ai)/2);
    [h1 f1]=freqz(1,ai(mid,:),1024,Fs);
    [h2 f2]=freqz(1,ai_mod(mid,:),1024,Fs);
    %Affichage du filt au milieu du signal
    figure(1)
    subplot(2,2,[2 4])
    hh1=plot(f1,20.*log10(abs(h1)));
    hold on
    hh2=plot(f1,20.*log10(abs(h2)),'r');
    legend('original','modify')
    xlabel('frequency (Hz)')
    ylabel('Amplitude (norm.)')
    title(['\bfModification de F3 de ' num2str(D(j)) ' Hz'])
     hold off
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subplot(221)
    plot(t,s);hold on; plot(t,output3,'g');plot(t,output,'r');
    legend('Originale','Resynthethize','Modify')
    title('Signal audio')
    xlabel('Temps(s)')
    hold off
    subplot(223)
    plot(tres,Fx(:,1),'.'); hold on; plot(tres,Fx(:,2),'.'); plot(tres,Fx(:,3),'.');plot(tres,Fx(:,4),'.')
    plot(tres,Fx_out(:,1),'.r'); hold on; plot(tres,Fx_out(:,2),'.r'); plot(tres,Fx_out(:,3),'.r');plot(tres,Fx_out(:,4),'.r')
    plot(t_f0s,10.*f0s,'--k')
    ylabel('Fréquence (Hz)')
    xlabel('Temps(s)')
    title('Formants')
    hold off
    
    outfull=[outfull;zeros(640,1) ;output./(1.1*max(output))];

end