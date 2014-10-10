%  Saved from C:\NeareyMLTools\PitchDevel\tausincterp.m 2006/10/12 15:18

function rt=tausincterp(xlag,rIn,nwinIn,lagsIn)
% Interpolation of autocorrelation for non-integer lags
% Persistant property                                                                                                      here used as semiglobal
% returns rt = autocorrelation at possible noninteger lag xlag (in samples)
% This does a windowed (approximate, non cyclical) sinc interpolation
% base on Boersma's suggestions (see BoersmaPitch)
% Designed for use witn Brent call with 4 args before calling BRENT
% It keeps the last 3 arguments in PERSISTENT variable until new values
% are supplied
% input
% xlag-- lag value (in samples, but not generally integer)
% rIn -- autocorrelation function (will be normalized by max internally)
% nwinIn  -- window length that was used to create rIn
% nwinIn and lagsIn need only be set for the first the first frame
% lagsIn-- integer lags corresponding to elements or rIn
%    this program handles zero lag in r(1) or zero lag 'in-the-middle'
% rIn must be set for each frame
% xlag must be set for each call from BRENT
% nwinIn and lagsIn normally only need to be given once each session
%   local copies of rIn, nwinIn and lagsIn are preserved.
% Brent will call with one arg and give brent a negative tolerence to
% maxiimize
% rIn is assumed to be in 0-lag center form
% Version 2.0 does not normalize and does not do 1-r.
% Give it the function you want sincintepolated
persistent r nwin lags izerolag
if nargin==0
	testtausincterp;
	return
end
% Copy whatever extra arguments are given to persistent arrays
if nargin>1
	r=rIn;
	if nargin>2
		nwin=nwinIn;
		if nargin>3
			lags=lagsIn;
			izerolag=find(lags==0);
		end
	end
end
if isempty(xlag)
	rt=[];
	return
end

% Normal continuation....
% Used by BRENT in BOERSMAPITCH
% Calculate sinc interpolated function (with windowing)
% of tau Assume a fully specified r function from inverse FFT
% zerlag is index in r of zero lag
lagL=floor(xlag); % Left bracketing integer lag
% Hard to know if this is different here than in Boersma 9x report
N=ceil(nwin/2)+lagL;  % see top of p 104
if N>=nwin/2+lagL, N=N-1;end
N=min(500,N);
nlag=2*N+1;
lagStart=floor(xlag)-N+1;
lagVals=[lagStart:lagStart+2*N]';
if izerolag==1 % we have zerolag in first position
	laginx=lagVals+1; % values from zero on become 1+ orig
	% alias zerolags to their proper non-redundant values
	iflip=find(laginx<1);
	% What was -1 is now 0, it should be +1
	laginx(iflip)=-laginx(iflip)+1;
else % assumes
	laginxStart=lagStart-lags(1)+1;
% 	keyboard
	laginx=[laginxStart:laginxStart+2*N]';
end

%lagi=[ceil(xlag-N):floor(xlag+N)]';
sinctau=sinc(lagVals-xlag);
% use a simple exp(quadratic) window -- symmetrical about tau
% we so that lagt is
% 	plot(sinctau)
% 	pause
wint=.5-.5*(cos(2*pi*((lagVals-xlag)/(2*N+1)+.5)));
% 	plot(wint)
% 	pause
% 	plot(r(lagi+izer));
% 	title('r(lagi+izer)')
%incase neg freq is encountered
% Here's where we could fix lagi...depending on wrap
% We assume zerolag is included in r at izer..
% lagi=lagi+izer;
% lagi=max(lagi,-lagi+1); So if izer is 1
rt=sum(r(laginx).*sinctau.*wint);
%keyboard
return


function testtausincterp
%testing(1)
Fs=10000
t=[0:1/Fs:.25]';
f0=173;
y=sin(2*pi*t*f0);
soundsc(y,Fs)
leny=length(y);
% [rIn,lagsIn]=acboersma(y,2*2^nextpow2(leny));
[rIn,lagsIn]=xcorr(y);
rIn=rIn./max(rIn);
figure(1);
clf
plot(lagsIn,rIn);
xlag=Fs/f0
nwinIn=length(y);
xlagSav=xlag;
xlag=floor(xlag)+.5; %put it in the middle
rtstart=tausincterp(xlag,rIn,nwinIn,lagsIn)
rtstart=tausincterp(xlag)
pausemsg('Before brent')
tol=-.001
[bestlag,rtt,neval]=brent('tausincterp',floor(xlag),xlag,floor(xlag+1),tol,10);
xlag
bestlag,rtt, xlagSav,rtstart, f0, f0Hat=Fs/bestlag
[rimax,imax]=max(rIn)
imaxlag=lagsIn(imax)
% keyboard

return

