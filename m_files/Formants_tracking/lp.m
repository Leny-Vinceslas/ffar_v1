%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By : Thibaut FUX         %
% thibaut.fux@hotmail.Fr   %
% Date : 19/10/2012        %
% Place : LPP              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [a_i,k_i,En]=lp(x,p)

x_hm=x;
%disp(['size(x) : ' num2str(size(x)) '  /  ' num2str(size(hamming(length(x))))])
x_hm=x.*hamming(length(x));
 %disp(['size(x) hamm : ' num2str(size(x)) '  /  ' num2str(size(hamming(length(x))))])
 
xcc=xcorr(x_hm);
Ri=xcc(round(length(xcc)/2):round(length(xcc)/2)+p);

R=Ri';

R0 = R(1);
R = R/R0;

p = length(R) - 1;
k = zeros(1,p);
r = zeros(1,2);

a = 1;

for n = 1:p,
	a = [a, 0];
	r = R(1:n+1);
	En = sum(r.*a);
	Bn = sum(fliplr(r).*a);
	ki = -Bn/En;
	a = a + fliplr(a)*ki;
	k(n) = ki;
end;

En = R0*sum(R.*a);


k_i=k;
a_i=a;
end

