%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By : Thibaut FUX         %
% thibaut.fux@hotmail.Fr   %
% Date : 19/10/2012        %
% Place : LPP              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output exc]=vocoder(input,exc,Fs,ai,WLen,Hop)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [output exc]=vocoder(input,Fs,ai,I,p,WLen,Hop,fmin,acc_p)
%
%Entrée :
%       - input     : signal d'origine
%       - Fs        : Fréquence d'échantillonnage
%       - ai        : Coefficients du filtre
%       - Wlen      : Longueur de la fenêtre d'analyse (en échantillons)
%       - Hop       : Décalage (en échantillon)
%       - fmin      : fréquence minimum de voismement
%       - acc_p     : coefficient du filtre de pré/post-accentuation
%       - residu    : residu de la prédiction LPC
%Sortie :
%       - output    : Signal synthétisé
%       - exc       : Vecteur d'excitation
%
%Auteur : Thibaut FUX
%Date : 15 avril 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%% CALUL DES GAINS %%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%
        %Initialisation
        indx=1;
        k  = 0;
        kmax = length(input) - 2*WLen;

        %Calul du gain de chaque filtre en fonction de l'excitation
        while k < kmax
            if(isnan(ai(indx,:)))
                ai(indx,:)=ones(1,length(ai(indx,:)));
            end
            grain=filter(1,ai(indx,:),exc(k+1:k+WLen)');
%             tmp=intensity(grain);   
%             I(indx)=I(indx)/tmp;
            
            k = k + Hop;
            indx=indx+1;
        end


  %%%%%%%%%%%SYNTHESE%%%%%%%%%
  
        %Initilaisation
        output = zeros(length(input),1);
        indx=1;
        k  = 0;
        kmax = length(input) - WLen;
        
        %Synthèse du signal
        while k < kmax
            grain=filter(1,ai(indx,:),exc(k+1:k+WLen)');
            grain=grain-mean(grain);
            output(k+1:k+WLen) = output(k+1:k+WLen) + (grain.*hanning(length(grain)));
            k = k + Hop;
            indx=indx+1;
        end
        

end

