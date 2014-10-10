%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By : Thibaut FUX         %
% thibaut.fux@hotmail.Fr   %
% Date : 19/10/2012        %
% Place : LPP              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [t_f0s f0s t_f0d f0d t_f0 f0]=pitch_estimation(s,Fs,step)

%cd boersmapitch
% [t_f0,f0,phiBest,ncand,Rpen,Fest,R,rel_absIntensity]=BoersmaPitch(s./max(
% s),Fs,0,samp2ms(length(s),Fs));
[t_f0,f0,phiBest,ncand,Rpen,Fest,R,rel_absIntensity]=BoersmaPitch(s./max(s),Fs,0,samp2ms(length(s),Fs),50,300,20,1000*3/50,'HANNING',10,0.25,0.01);
% VoicingThreshold,SilenceThreshold,OctaveCost,OctaveJumpCost,VoicedUnvoicedCost,TerpMeth,tol);
% 1-x,2-Fs,3-tmin, 4-tmax, 5-minF0,6-maxF0,7-hopMs,8-dwinMs,9-winType,10-MaxNumCandPerFrame,
% 11-VoicingThreshold,12-SilenceThreshold,13 -OctaveCost,14 -OctaveJumpCost 15-VoicedUnvoicedCost
% 16-TerpMeth, 17-tol);

%correction de f0 pouir eliminer les points seul

for i=2:length(f0)-1
    if(f0(i)>0 & f0(i-1)==0 & f0(i+1)==0)
        f0(i)=0;
    else
        f0(i)=f0(i);
    end
end
f0(1)=0;
f0(end)=0;

t_f0=t_f0/1000;
%cd ..
fmin=min(f0(f0>1));%Fmin est choisi comme la plus faible valeurs avant interpolation

t_f0s=1/Fs:1/Fs:length(s)/Fs;
f0s=interp1(t_f0,f0,t_f0s);% interpolation du vecteur F0 pour obtenir la lonueur du signal
f0s(f0s<50)=0;
f0s(isnan(f0s))=0;

t_f0d=(step:step:length(s))/Fs;
f0d=interp1(t_f0,f0,t_f0d);
f0d(isnan(f0d))=0;
f0d(f0d<50)=0;