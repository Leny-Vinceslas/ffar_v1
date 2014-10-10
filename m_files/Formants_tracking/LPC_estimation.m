%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By : Thibaut FUX         %
% thibaut.fux@hotmail.Fr   %
% Date : 19/10/2012        %
% Place : LPP              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ai I residu t_res Nbre_LPC]=LPC_estimation(s,Fs,WLen,Hop,ordre)
%addpath('matsig-0.2.5\');
indx=1;
k  = 0;
kmax = length(s) - WLen;
s=filter([1 -0.95],1,s);
residu=zeros(1,length(s));
while k < kmax
      %disp(['size(s) : ' num2str(size(s)) '  /  ' ])
 
    frame(indx,:)= s(k+1:k+WLen);
%disp(['size(x) : ' num2str(frame(indx,:)) '  /  ' num2str(size(hamming(frame(indx,:))))])
 
    %[ai(indx,:)]=lp(frame(indx,:)',ordre);%Fenêtrage fait dans LP par Hamming
    [ai(indx,:)]=arburg(frame(indx,:)',ordre);
    %[ai(indx,:)]=dap(signal(frame(indx,:),Fs),ordre) ;

     res=filter(ai(indx,:),1,frame(indx,:));%filtrage inverse de la frame

  residu(k+1:k+WLen)=residu(k+1:k+WLen)+res.*hanning(WLen)';%recontruction du residu
    
    t_res(indx)=(k+WLen./2)/Fs;  %calcul de la position temporel de la frame
    I(indx)=sqrt(mean(frame(indx,:).^2)); % Calcul de l'intensité de la frame
       
    k = k + Hop;
    indx=indx+1;
end

t_res=t_res';

tframe=(Hop:Hop:length(s))/Fs;

Nbre_LPC=indx-1;
tframe=tframe(1:Nbre_LPC);
