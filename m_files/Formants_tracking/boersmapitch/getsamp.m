%  Saved from C:\NeareyMLTools\PitchDevel\getsamp.m 2006/10/12 15:18

function y=getsamp(x,i1,i2);
%function y=getsamp(x,i1,i2);
% Function to grab signals in given index ranges
% returns zeros for out of range requests, reverses requests if i2<i1;
% col vector assumed
% version 2.1 Copyright T M Nearey 2003; % Fixes calls all out of range
reverse=0;
x=x(:);
if i1==i2; y=x(i1);
	return;
end
% i1sav=i1; i2sav=i2;

if i2<i1
	reverse=1;
	t=i1;
	i1=i2;
	i2=t;
end
n=length(x(:));
nleft=0; nright=0;
% Entire request is greater than requested % Or condition fixed Oct 2003
if i1>n | i2 <1
	nout=i2-i1+1;
	y=zeros(nout,1);
	return
end


if i1<1,
	nleft=-i1+1;
	i1=1;
end
if i2>n,
	nright=i2-n;
	i2=n;
end

y=[zeros(nleft,1);x(i1:i2); zeros(nright,1)];
%nleft,i1,i2,nright,n,i1sav,i2sav
return

