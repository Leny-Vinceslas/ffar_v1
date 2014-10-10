%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By : Thibaut FUX         %
% thibaut.fux@hotmail.Fr   %
% Date : 19/10/2012        %
% Place : LPP              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [a2 E1 E2]=formant_shift(ai,Fs,Fx_mod)
% ai: coefficent du filtre
% Fs: frequence d'echantillongage
% Fx: valeur de déplacement des formants type : [DELTA_F1 DELTA_F2 DELTA_F3 ...]


Nb_mod=length(Fx_mod);
%Mesure

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
Bw2=Bw(Fx>0 & Fx<Fs/2);

Fx2(1:Nb_mod)=Fx2(1:Nb_mod)+Fx_mod';

%reconstruction
Bw3=[Bw2; Bw2;Bw(a0); Bw(aFs_2)];
Fx3=[-Fx2; Fx2; Fx(a0); Fx(aFs_2)];
P_abs2=exp(-2*pi*Bw3/Fs);
P_ang2=Fx3*(2*pi)/Fs;

P2=P_abs2.*exp(j.*P_ang2);
a2=real(poly(P2));
