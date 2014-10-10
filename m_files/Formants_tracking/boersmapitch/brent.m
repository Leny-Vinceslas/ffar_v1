%  Saved from C:\NeareyMLTools\PitchDevel\brent.m 2006/10/12 15:18

function [lambda,fx,evalct]=brent(fname,ax,bx,cx,tol,MAXITER,varargin);
%function [lambda,fx,evalct]=brent(fname,ax,bx,cx,tol,MAXITER,varargin);
% if tol is negative, a function max is found instead of a min
if nargin==0
	[lambda,fx,evalct]=	brent('sin',-pi,1,pi,.001,30)
	pausemsg('Done Min search')
    [lambda,fx,evalct]=	brent('sin',-pi,1,pi,-.001,30)
	pausemsg('Done Max search')

	return
end
if tol<0,
    sgn=-1;
    tol=abs(tol);
else
    sgn=1;
end
% fname
% ax
% bx
% cx
% tol
% MAXITER
% varargin
% TESTBRENT=testing;
Kmax=MAXITER;
eta=tol;
% This is a gutted version of  Lowen's % linsrch.m
% It removes the brent part and gives an envelope comparable to NumRecipies original
% --  Elementary line search for a minimum
% looks in vector space for best possible  t  in [0,inf)
% to minimize fname(zz+t*vv)
%
% Uses transparent rip-off of Brent's method from Numerical Recipes.
% Philip D. Loewen
% 26 Feb 98 - original
% 30 Apr 01 - tuning
% function [lambda,evalct] = linsrch(fname,zz,vv,eta,Kmax)
% if nargin==0
% 	[ lambda,evalct] =linsrch('sin',7/13*pi,1,.001,10)
% 	return
% end
%% Phase I: generate a bracketing triple.
%% Triple will have form (0,tm,tr), in golden-mean proportions.
%% Suffixes:  l=left, m=mid, r=right.
%% Assumes that direction vv is a descent direction from point zz.
bnum = 1;
gold   = (3.0+sqrt(5.0))/2.0;   % Golden ratio expansion factor
% maxdil = 20;                    % Maximum number of dilations allowed
%
% tl = 0.0; fl = eval([fname,'(zz + tl*vv)']);   % Starting interval has endpoints
% tm = 1.0; fm = eval([fname,'(zz + tm*vv)']);   % tl=0, tm=1=tr.
% tr = tm;  fr = fm;
%
% if fr<fl,
% 	% This is the expected case, where f decreases from t=0 to t=1.
% 	tr = gold*tr; fr = eval([fname,'(zz + tr*vv)']);
% 	bnum = 1;
% 	vp(4,['linsrch:  Expansion ',int2str(bnum), ...
% 	':  tl = ',num2str(tl),', tm = ',num2str(tm),', tr = ',num2str(tr),'.']);
% 	while (fm > min([fl,fr])) & (bnum < maxdil),
% 		tm = tr;  fm = fr;
% 		tr = gold*tr; fr = eval([fname,'(zz + tr*vv)']);
% 		bnum = bnum+1;
% 		vp(4,['linsrch:  Expansion ',int2str(bnum), ...
% 		':  tl = ',num2str(tl),', tm = ',num2str(tm),', tr = ',num2str(tr),'.']);
% 	end;
% else
% 	% This is the strange case, where f increases from t=0 to t=1.
% 	% Here we shrink the interval instead of expanding it.
% 	tm = tm/gold; fm = eval([fname,'(zz + tm*vv)']);
% 	bnum = 1;
% 	vp(4,['linsrch:  Contraction ',int2str(bnum), ...
% 	':  tl = ',num2str(tl),', tm = ',num2str(tm),', tr = ',num2str(tr),'.']);
% 	while (fm > min([fl,fr])) & (bnum < maxdil),
% 		tr = tm;  fr = fm;
% 		tm = tm/gold; fm = eval([fname,'(zz + tm*vv)']);
% 		bnum = bnum+1;
% 		vp(4,['linsrch:  Contraction ',int2str(bnum), ...
% 		':  tl = ',num2str(tl),', tm = ',num2str(tm),', tr = ',num2str(tr),'.']);
% 	end;
% end;
% % diagnostic printing
% l10tm = log10(tm);
% xp = ceil(abs(l10tm))*sign(l10tm);
% vp(3,['linsrch:  Found bracket  [tl,tm,tr] = (1E',num2str(xp),')*',...
% sprintf('[%4.2f, %4.2f, %4.2f]',0.1^xp*[tl,tm,tr]),'.']);
% vp(3,['linsrch:  fm = ',sprintf('%6.0e',fm),', fl-fm = ',sprintf('%6.0e',fl-fm),...
% ', fr-fm = ',sprintf('%6.0e',fr-fm),'.']);
%
% if fm > min([fl,fr]),
% 	vp(1,['linsrch:  Failed to bracket a minimum in ',int2str(bnum), ...
% 	' tries, so quitting in disgust.']);
% 	if tr-tl<0.001,
% 		vp(1,['linsrch:  (Suspect given direction vv is not a descent direction.)']);
% 	elseif tr-tl>1000,
% 		vp(1,['linsrch:  (Suspect function unbounded below in direction vv.)']);
% 	end;
% 	evalct = bnum+2;
% 	lambda = tm;
% 	return;
% end;

%% Phase II:  Apply Brent's Method
%%  This is just typed from Numerical Recipes, modified for Matlab.

% TMN, ensure  initial conditions on x
t=sort([ax,bx,cx]);
ax=t(1);
bx=t(2);
cx=t(3);

% Initializations...
% a = tl;  % Left bracket point
% b = tr;  % Right bracket point
% v = tm;  % Middle bracket point

% TMN initilaizaitons
a=ax;
v=bx;
b=cx;
x = v;   % Point with best fcn value so far
w = v;   % Point with second-best fcn value so far
%   (Later, v stores the previous value of w.)
e = 0.0; % Distance moved on the step before last.

t = x;
%fx = fm;
if isempty(varargin)
    % sgn added tmn
	fx=sgn*feval(fname,x);
else
	fx=sgn*feval(fname,x,varargin);
end% can't Remember fcn value at middle pt of bracket from before.
fv = fx;
fw = fx;

Zeps = eps^0.75;

for iter=1:Kmax         % Main program loop.

% 	if TESTBRENT
% 		vp(4,['linsrch:  Iteration ',int2str(iter),' begins:']);
% 	end

	xm = 0.5*(a+b);  % Midpoint of current bracket
	tol1 = eta*abs(x)+Zeps;
	tol2 = 2.*tol1;

	% Test for done here.
	if ( abs(x-xm) <= (tol2-0.5*(b-a)) ),
		% Exit with best values.
		lambda = x;
		evalct  = iter+bnum+1;
% 		if TESTBRENT
% 			vp(3,['linsrch:  Error tolerance met in ',int2str(evalct),' function evaluations.']);
% 			vp(3,['linsrch:  Returning lambda = ',sprintf(' %22.16e',lambda),'.']);
% 		end
        fx=sgn*fx; % TMN
		return
	end;

	if ( abs(e) <= tol1),
		% Step before last was very small, so
		% take a Golden Section Step:
% 		if TESTBRENT
% 			vp(4,['linsrch:  Golden section step (very small e).']);
% 		end
		if (x >= xm),
			e = a-x;
		else
			e = b-x;
		end;
		d = e/gold;
	else
		% Step before last was of decent size, so
		% construct a trial parabolic fit.
		r = (x-w)*(fx-fv);
		q = (x-v)*(fx-fw);
		p = (x-v)*q - (x-w)*r;
		q = 2.0*(q-r);
		if (q>0.0),
			p = -p;
		end;
		q = abs(q);
		etemp = e;
		e = d;

		% Test viability of trial fit.
		if (abs(p)>= abs(0.5*q*etemp)) | (p <= q*(a-x)) | ( p>= q*(b-x))
			% Parabolic fit is poor, so take golden section step.
% 			if TESTBRENT
% 				vp(4,['linsrch:  Golden section step (poor parabolic fit).']);
% 			end
			if (x >= xm),
				e = a-x;
			else
				e = b-x;
			end;
			d = e/gold;
		else
			% Parabolic fit is OK, so use it.
% 			if TESTBRENT
% 				vp(4,['linsrch:  Parabolic interpolation step.']);
% 			end
			d = p/q;
			u = x+d;
			if (u-a < tol2) | (b-u < tol2),
				d = tol1*sign(xm-x);
			end;
		end;
	end;

	% Arrive here with increment  d  in hand.
	% Use d to form new x-value, insisting on moving at least tol1.
	if (abs(d) >= tol1),
		u = x+d;
	else
		u = x + tol1*sign(d);
	end;
% if TESTBRENT
% 	vp(4,['linsrch:  New point u=',num2str(u),'.']);
% end

	% Evaluate given function at point u
	% (This is the one function evaluation per iteration.)
	%		fu = eval([fname,'(zz+u*vv)']);
	if isempty(varargin)
		fu = sgn*feval(fname,u);
	else
		fu = sgn*feval(fname,u,varargin);
	end
	if (fu <= fx),
		% New evaluation point  u  is better than best-so-far  x
		if (u >= x), a=x; else b=x; end;   % Contract bracketing interval
			v=w; fv=fw;
			w=x; fw=fx;
			x=u; fx=fu;
		else
			% New evaluation point  u  is worse than best-so-far  x
			if (u < x), a=u;
		else b=u;
	end;
	if (fu <= fw) | (w==x),
		v = w; fv = fw;
		w = u; fw = fu;
	elseif(fu<=fv) | (v==x) | (v==w),
		v=u; fv=fu;
	end;
end;

end;    % End of main program loop

% if TESTBRENT
% 	vp(4,['linsrch:  brent exceeded maximum iterations']);
% end
lambda = x;
evalct = -(iter+bnum+1);
fx=sgn*fx;
return;

function vp(num,msg)
if ~testing
	return
end
disp('brent message')
num
msg
return
