% %  Saved from C:\NeareyMLTools\PitchDevel\BoersmaPitch.m 2006/10/12 15:18

function [tax,f0,phiBest,ncand,Rpen,Fest,R,rel_absIntensity]=BoersmaPitch(x,Fs,tstart,tend,minF0,maxF0,hopMs,dwinMs,winType,MaxNumCandPerFrame,...
    VoicingThreshold,SilenceThreshold,OctaveCost,OctaveJumpCost,VoicedUnvoicedCost,TerpMeth,tol)%,shouldUpsample);
% [tax,f0,phiBest,ncand,Rpen,Fest,R,rel_absIntensity]=BoersmaPitch(x,Fs,tstart,tend,minF0,maxF0,hopMs,dwinMs,winType,MaxNumCandPerFrame,...
% VoicingThreshold,SilenceThreshold,OctaveCost,OctaveJumpCost,VoicedUnvoicedCost,TerpMeth,tol);
% 1-x,2-Fs,3-tmin, 4-tmax, 5-minF0,6-maxF0,7-hopMs,8-dwinMs,9-winType,10-MaxNumCandPerFrame,
% 11-VoicingThreshold,12-SilenceThreshold,13 -OctaveCost,14 -OctaveJumpCost 15-VoicedUnvoicedCost
% 16-TerpMeth, 17-tol);

%% REQUIRES  BRENT, TAUSINCTERP, BOERSMAPITCHDP. variant requires CUBTERP
%We are following
% P. Boersma IFA Proceedings(Institute of Phontics Sciences, University of Amsterdam
% Proceeding 17 (1993)  17, 1993 Accurate short-term analysis of the fundamental frequency
% and the harmonics-to-noise ratio of a sampled sound. pp 97-110
% --With modifications based on Praat4.0.50 source code Fon/ SoundToPitch.c and Pitch.c (Pitch_pathFinder)
% If winType is 'HANNING' and dwinMs is 3*/minF0 *1000
%   then pars should be same as for Praat without 'VeryAccurate' flag
%  if winType is 'GAUSS' and dwinMS is 6/minF0*1000, then +VeryAccurate flag
% Default settings correspond to PRAAT 4.0.50 16 April 2003
%
% Notable departures from IFA article
% Filtering and upsampling not part of Sound_to_Pitch.c
% Sinc interpolation controlled by  brent_depth (not accuracy)
% and interpolation_depth
%  Departure in our implementation
% We also are also now using 7 pt cubic spline about peak instead of sinc
% interpolation.
% Step 1 p 1o4
%%%%%%%%%%%%%%%
% Do an fft on the whole signal. Filter by multiplication in the frequency domain from 95% of the nyquist frequency to 100%;
% Do an FFT;
% 'Soft upsampling'
% Verson 1.1 Uses BRENT only, not fmin
% Note the function cubterp has uses internal storage trick
% Version 1.1 uses revised tausincterp
% Version 1.2 fixes error OctaveJump multiplier in candidate selection and in
%        in Rpen(i,~zinx) line  of BoersmaPitchDPand inverted time step
%      correction  of OctaveJumpCost and VoicedUnvoicedTransition weights in
%      BoersmaPitchDP function
%      Abandons quadterpiter. Sets phiBest of 0 f0 to zero;
% Version 1.3 'tax' driven a time axis is calculated first off
%  if tstart is a vector, it is taken as tax
%   Also corrected peak logic error Sept 15 2003
%  Also corrected DP references to Rpen 16 sept 2003
% NOW USES EXTERNAL BoersmaPitchDP (q.v.)
% Also correctedintensity calculation. Local mean is calculated over 2 max
% pitch periods with now window, local peak over 1 max pitch perios AFTER
% window
% REQUIRES BOERSMAPITCHDP
% Version 1.3.1 fixes degenerate case

if nargin<16|isempty(TerpMeth)
    TERPMETH='BRENTSINCTERP';
else
    switch upper(TerpMeth)
        case {'BRENT', 'BRENTSINC', 'BRENTSINCTERP', 'SINCTERP','SINC'}
           TERPMETH='BRENTSINCTERP';
       case {'CUBE', 'CUBIC', 'CUBSPLINE','CUBESPLINE'}
           TERPMETH='CUBSPLINE';
       otherwise
           disp('BoersmaPitch possible interp methods: BRENTSINC CUBSPLINE')
           error('Invalid TerpMeth')
   end
end
if nargin<17|isempty(tol);
    tol=.005;
end

peakexceed=inline('[0;min(x(2:end-1)-x(1:end-2),x(2:end-1)-x(3:end));0]');
if nargin==0
    testing(0);
    [x,Fs]=genPitchChirp;
    %dwinMs = 1000*3*Fs/50;
    tic;
    [tax,f0,phiBest]=BoersmaPitch(x,Fs);%50dwinMs);
    tottime=toc;
    sprintf('Boersma pitch time check ', num2str(toc));

    figure
    plotyy(tax,f0,tax,phiBest);
    fig;
    title(['Elapsed time ', num2str(tottime)]);
    pausemsg;
    %     disp( 'Keyboard function called by test program')
    % 	keyboard
    return
end

BOERSMATEST=testing;
%3-tstart MS
if nargin<3|isempty(tstart)|isequal(tstart,-inf)
    tstart=0;
end
%4- tend MS
if nargin<4|isempty(tend)|isequal(tend,inf)
    tend=samp2ms(length(x),Fs);
end


%5-minF0
if nargin<5|isempty(minF0)
    minF0=75;
end
%6-maxF0
if nargin<6 |isempty(maxF0)
    maxF0=600;
end
%7-hopMs
if nargin<7|isempty(hopMs)
    hopMs=10;
end
%8-dwinMs
if nargin<8|isempty (dwinMs)
    dwinMs= 1000*3/minF0;
end
%9-winType
if nargin<9 |isempty(winType)
    winType='HANNING';
end
%10-MaxNumCandPerFrame,
if nargin<10|isempty(MaxNumCandPerFrame)
    MaxNumCandPerFrame=15;
end
% 11-VoicingThreshold,10-SilenceThreshold,11-OctaveCost,12-OctaveJumpCost);

if nargin<11|isempty(VoicingThreshold)
    VoicingThreshold=.45;
end
%12-SilenceThreshold,11-OctaveCost,12-OctaveJumpCost);

if nargin<12|isempty(SilenceThreshold)
    SilenceThreshold=.03;
end

%13-OctaveCost
if nargin<13 | isempty(OctaveCost)
    OctaveCost=.01;
end
% 14-OctaveJumpCost;
if nargin<14 | isempty(OctaveJumpCost)
    OctaveJumpCost=.35;
end
% 15 VoicedUnvoicedCost
if nargin<15| isempty(VoicedUnvoicedCost)
    VoicedUnvoicedCost=.14;
end
MAXCAND=MaxNumCandPerFrame;
%%%%%%
% CEILING IS NOT CLEAR IN DOCUMENTATION ... IT APPEARS TO BE SET TO MAXIMUM PITCH VALUE
% BY DEFAULT IN PRAAT
ceiling = maxF0;
if ceiling>.5*Fs,
    ceiling=.5*Fs;
end

% We're doing an interpolation based on Praat4.0.50 defaults
% for ACC_HANNING  brent_depth=70; and interpolation_depth=.50
% for ACC_GAUSS, brent_depth=700; and interpolation_depth=.25

if isequal(upper(winType),'HANNING')
    brent_depth = 70;
    interpolation_depth= 0.50;
else
    brent_depth = 700;
    interpolation_depth = 0.25;
end
if BOERSMATEST %| 1
    %close all;
    xsav=x;
    FsSav=Fs;
end
% Set up TAX and drive analysis by that
if length(tstart)>1
    tax=tstart(:);
else
   nhop=round(hopMs/1000*Fs);
   hopMs=samp2ms(nhop,Fs);
% This was too big....nx2 has points padded already
% nx2Insig is the last signal point in the requested range
tax = [tstart:hopMs:tend]';
end
% Window
win=getwin(dwinMs,winType,Fs);
nwin=length(win);
% Starting and ending points of frames
nShiftLeft=round(nwin/2);
isampStart=ms2samp(tax,Fs)-nShiftLeft;
isampEnd=isampStart+nwin-1;
% first and last are actual parts of signal available
first=max(1,isampStart(1));
last=min(length(x),isampEnd(end));
x(first:last)=x(first:last)-mean(x(first:last));
nframe=length(tax);


% if shouldUpsample
%     warning(' Upsampling is obsolete do externally')
% end
%
%
% Step2;
globalMaxAbs=max(abs(x(first:last)));
% Step 3.1

%
R=zeros(nframe,MaxNumCandPerFrame);
Tau=R;
Fest=R;
rel_absIntensity=zeros(nframe,1);
%=R;
%%% Prep
% see step 3.6 & 7 window length + half window length of zeros
n2loc=2^nextpow2((1+interpolation_depth)*nwin);
% The lags... see acboersma for comparisons with XCORR.
lags=[0:n2loc/2, (-n2loc/2+1):-1];
rWin=real(fft(abs(fft(win,n2loc)).^2));

rWin=rWin./rWin(1);
rWin=max(rWin,.0001); % limit the size of the effect TMN
if testing
    figure(37)
    plot(rWin);
end
% the full number of lags here represents Fs
% WRONG>>>>>>>>>>
% zero based lags
lagmin=ceil(Fs/maxF0);
lagmax=floor(Fs/minF0);
% This will be the location of the zero time lag after FFT shift
izero=n2loc/2+1;


% tausincterp(0,rx,nwin,lags);


% inxLocalStart and inxLocalEnd delimit TWO periods in the middle of thewindow
% These are the samples of xx (which is LONGER 2 periods) to use;
% Fixed 16 Sept 2003
inxLocalMeanStart=round(nwin/2-lagmax);
inxLocalMeanEnd=inxLocalMeanStart+2*lagmax-1;
inxLocalPeakStart=round(nwin/2-lagmax/2);
inxLocalPeakEnd=inxLocalPeakStart+lagmax-1;
brent_ixmax=floor(nwin*interpolation_depth);
ncand=zeros(nframe,1);
for i=1:nframe
    xx=getsamp(x,isampStart(i),isampEnd(i));

    % step 3.2 5 Mean calculated BEFORE
    xx=xx-mean(xx(inxLocalMeanStart:inxLocalMeanEnd));
    % step 3.3
    % Noop points to stuff in 3.11)
    % step 3.4-3.8
    xx=xx.*win; % NOW WINDOW IS APPLIED (for local peak too)
    XX=abs(fft(xx, n2loc)).^2;
    % steps 3.9-3.10
    rx=real(fft(XX))./rWin;
    if isequal(rx(1),0);
        rx(1)=10e-6*globalMaxAbs;
    end
    rx=rx./rx(1);
    if BOERSMATEST
        ra=real(fft(XX));
        clf
        subplot(3,1,1);
        plot(ra);
        subplot(3,1,2);
        plot(rWin);
        subplot(3,1,3);
        plot([0:length(rx)-1]',rx)
        pausemsg
    end
    % Boersma Local peak looks ONE FULL longest period to left and right of center
     localMaxAbs=max(abs(xx(inxLocalPeakStart:inxLocalPeakEnd)));
    % EXPERIMENT make this longer and see if its closer to his
      % localMaxAbs=max(abs(xx(inxLocalMeanStart:inxLocalMeanEnd)));

    rel_absIntensity(i)=min(localMaxAbs/globalMaxAbs,1);

    % Part ofstep 3.11
    % Now the interpolation part;
    % Perform fft shift to put zero lag in the middle
    % find the lags and good taus to start with quadpeaks
    % Following Boersma, we do not enforce the minimum lag search until PathFinder (BoersmaPitchDP)
    % lagsSearched=[1:lagmax+1]'; % This excludes some cases near zero... there can be ripple there
    % This is not quite BOERSMA.... He keeps all candidates based on raw R, then
    % THROWS AWAY based on Penalized R... We'd have to implement that here outside of quadpeaks
    %
    %[lagEst,rEst]=quadpeak(lagsSearched,rx(lagsSearched+1),MaxNumCandPerFrame-1,0,.5*VoicingThreshold);

    %Boersma's way
    %
    % Save the largest 15 penalized peaks then interpolate their values.

    lagsSearched=[2:min(lagmax,brent_ixmax)];
    isaved=0;
    rEst=zeros(MAXCAND-1,1);
    lagEst=zeros(MAXCAND-1,1);
    nLagEst=0;
    for ii=lagsSearched(:)'
        ix=ii+1;
        % acf  of (lag) is in rx(lag+1)
        % corrected peak logic 15 Sept 2003
        if rx(ii)<rx(ix)&rx(ix)>=rx(ix+1) & rx(ix)>.5*VoicingThreshold
            newPeak=0;
            if isaved<MAXCAND
                isaved=isaved+1;
                R(i,isaved+1)=rx(ix);
                newPeak=1;
                ithLag=isaved;
                nLagEst=isaved;
            else
                [rmin,iimin]=min(R(i,2:MAXCAND));
                ithLag=iimin;
                % Started search at 2l
                % Mul not divide  after OctaveCost in next line....
                if rx(ix)-OctaveCost.*log2(ceiling./(Fs/ii))>rmin
                    R(i,iimin+1)=rx(ix);
                    newPeak=1;
                end
            end

            if newPeak,
                % quad terp
                denQuad=(2*rx(ix)-rx(ix-1)-rx(ix+1)); % Degenerate case
                if denQuad~=0
                lagEst(ithLag)= ii+ .5* (rx(ix+1)-rx(ix-1) )/denQuad ;
                else
                     lagEst(ithLag)=ii;
                end
                rEst(ithLag)=rx(ix);
                %keyboard
            end % new acceptable peak

        end	% potential peak

    end %  lagSearchLoop
    if any(lagEst) & 0
        trx=rx(:)';
        tlagEst=lagEst(:)';

        trEst=rEst(:)';
        [ttlagEst,ttrEst]=quadpeak(lagsSearched(:),rx(lagsSearched+1),MaxNumCandPerFrame-1,0,.5*VoicingThreshold);
        ttlagEst(:)';
        tlagEst';
        ttrEst(:)';
        keyboard
    end
    R(i,1)=0; % VOICELESS CANDIDATE..Now voiceless values set in  BoersmaPitchDP


    if BOERSMATEST
        tlag=lagEst(rEst>0);
        tr=rEst(rEst>0);
        hold on
        plot(lagsSearched,rx(lagsSearched+1),'r',lagEst,rEst,'*');
        pausemsg
    end

    savtest=BOERSMATEST;
    testing(0);
    nlagEst=max(find(rEst>0));
    if isempty(nlagEst)
        nlagEst=0;
    end
    ncand(i)=nlagEst+1; % include the voicless candidate
    TERPMETH='BRENTSINC';
   	%TERPMETH='CUBSPLINE';
    % TERPMETH='CUBQUADITER';
    % MEDAN can't be used here... require cross-correlation
    rtemp=0;
    for j=1:nlagEst;
        rtemp=0;
        if  ~ (rEst(j)>0 & lagEst(j)>=2) % Not really a candidate if these aren't met
            lagBest=0;
        else
            switch TERPMETH
                case 'BRENTSINC'
                    % BRENT ATTEMPT
                    MAXITER=brent_depth;
                    MAXITER=max(.005/tol*10,10);
                    % I have no idea may have to get very low for PRAAT
                    % match
                    tolt=-abs(tol);
                    ax=floor(lagEst(j)-1);
                    cx=ceil(lagEst(j)+1);
                    bx=lagEst(j);
                    % Setup the call
                    tausincterp(0,rx,nwin,lags);
                    % end
                    [lagBest,rtemp]=brent('tausincterp',ax,bx,cx,tolt,MAXITER);
                    %  disp 'Lagbest', disp(lagBest)
                    %%%
                    if rtemp>1,
                        rtemp=1./rtemp;
                    end

                case {'CUBSPLINE'}% % SPLINE ON 7 points using cubterp funcion
                    ax=floor(lagEst(j)-1);
                    cx=ceil(lagEst(j)+1);
                    bx=lagEst(j);
                    imid=round(lagEst(j));
                    splinwid=7;
                    irng=[imid-7:imid+7]';
                    if irng(1)<0,
                        irng=irng-irng(1);
                    end
                    if irng(end)>length(rx)-1,
                        irng=irng-irng(end)+length(rx)-1;
                    end;

                    cubterp(irng,rx(irng+1)); % first call set up POS ere
                  tolt=-abs(tol); % Negative TOL to get MAXIMUM of function
                    MAXITER=10;
                    %function [lambda,fx,evalct]=brent(fname,ax,bx,cx,tol,MAXITER,varargin)
                    lagBest=brent('cubterp',ax-1,bx,cx+1,tolt,MAXITER);
                    %lagBest
                    if lagBest<2 % Double check degenerate case
                        rtemp=0;
                    else
                        rtemp=cubterp(lagBest); % subsequent calls.. one input arg
                    end

%                     % Debugging code
%                     if 1./lagBest>ceiling % Where are these short lags coming from
%                         imid
%                         lagBest
%                         irng
%                         [l_f_r_pk]=[lagsSearched,1./lagsSearched, rx(lagsSearched+1),peakexceed(rx(lagsSearched+1))]
%                         pausemsg(' Rinfo on short lags', 'KEYBORD ENABLED','OK');
%                         keyboard
%                     end
%


            end % Main Method Switchyard

        end % worth searching
        if lagBest>0
            R(i,j+1)=rtemp;
            Tau(i,j+1)=lagBest/Fs;
            Fest(i,j+1)=Fs/lagBest;
        else
            R(i,j+1)=0;
            Tau(i,j+1)=0;
            Fest(i,j+1)=0;
        end


    end % for jth lag this frame

end % for iframe
testing(savtest);

% We have not imposed octave penalties on R this will be done in DP part
% score. At this point, R(:,2:end) could be presented to raptDP.


% Go for the DP  % Need penalized Rpen for this
pullFormants=0;
[bestState,f0,Rpen]=BoersmaPitchDP(hopMs,ncand,R,Fest,rel_absIntensity,OctaveJumpCost,VoicedUnvoicedCost,OctaveCost,VoicingThreshold,SilenceThreshold,ceiling,pullFormants);
%
% Restore best true phi (except at zero)
phiBest=zeros(nframe,1);
for i=1:nframe
    phiBest(i)=R(i,bestState(i))*(f0(i)>0);
end
%keyboard
return
