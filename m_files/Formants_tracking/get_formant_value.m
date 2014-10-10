%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By : Thibaut FUX         %
% thibaut.fux@hotmail.Fr   %
% Date : 19/10/2012        %
% Place : LPP              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Fx2]=get_formant_value(ai,Fs) %<-------------------------FX3


P=roots(ai);
P_abs=abs(P);
[P_ang IX]=sort(angle(P));
P_abs=P_abs(IX);

Fx=P_ang/pi*Fs/2;
Bw=-log(P_abs)/pi *Fs/2;

%Ne prendre que les positifs et les différents de 0 et Fs/2
a0=find(Fx==0);
aFs_2=find(Fx==Fs/2);

Fx2=Fx(Fx>0 & Fx<Fs/2);

%Fx3=ones(10,1).*NaN;
Fx3=Fx2;
%Fx3(1:length(Fx2))=Fx2;

% Fx2=Fx;
% Fx2(abs(Fx2)==Fs/2)=0;
% Fx2=Fx2(end/2:end);
% 
% indx0=find(Fx2==0);
% indxsup=find(Fx2>0);
% Fx3=[sort(Fx2(indxsup)) ; Fx2(indx0)];


