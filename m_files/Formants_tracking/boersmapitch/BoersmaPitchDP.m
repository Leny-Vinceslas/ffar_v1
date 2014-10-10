%  Saved from C:\NeareyMLTools\PitchDevel\BoersmaPitchDP.m 2006/10/12 15:18

function [bestState,f0,Rpen,phiBest,delta,psi]=BoersmaPitchDP(hopMs,ncand,R,Fest,rel_absIntensity,OctaveJumpCost,VoicedUnvoicedCost,OctaveCost,VoicingThreshold,SilenceThreshold,ceiling,pullFormants)
%function [bestState,f0,Rpen,phiBest]=BoersmaPitchDP(hopMs,ncand,R,Fest,rel_absIntensity,OctaveJumpCost,VoicedUnvoicedCost,OctaveCost,VoicingThreshold,SilenceThreshold,ceiling,pullFormants)
% Ripped out of boersma pitch
% Version 1.2 Rpen  references fixed Sept 16 2003
% AND Intensity calculation delta and psi returned (former BestCostToHere
% and BackPointer)
% disp('BoersmaPitchDP Ver 1.2 Rpen fixed')
% OctaveJumpCost,VoicedUnvoicedCost,OctaveCost,VoicingThreshold,SilenceThreshold,ceiling,pullFormants
if nargin<10 | isempty(pullFormants)
    pullFormants=0;
end
% translagion of C code double ceiling2 = pullFormants ? 2 * ceiling : ceiling;
ceiling2=ceiling;
if pullFormants
    ceiling2= 2 * ceiling;
end
Rpen=R;
% This weighting function was backward till 14 July 2003
% It should cost more to change faster
OctaveJumpCost=10.0./ hopMs*OctaveJumpCost; % relativize to hop size, defaults based on 10 ms
VoicedUnvoicedCost=10.0./ hopMs*VoicedUnvoicedCost;
DPTEST=testing;
maxcand=max(ncand);
nframe=size(R,1);
silMul=SilenceThreshold>0;
RpenDen=SilenceThreshold/(1+VoicingThreshold);
if RpenDen==0,
    RpenDen=eps;
end

for i=1:nframe
    zinx=Fest(i,:)<=0|Fest(i,:)>ceiling2; % These are unvoiced candidates
    % All voiceless candidates set to Unvoiced Strength
    Rpen(i,zinx)=VoicingThreshold+silMul*max(0, 2-[rel_absIntensity(i)./RpenDen]);;
    % The rest
    % The last line had a big error the .* after OctaveCost had been ./
    Rpen(i,~zinx)=Rpen(i,~zinx)-OctaveCost.*log2(ceiling./Fest(i,~zinx));
end


% ncand(iframe) number of candidtes ith frame
% R(iframe,icand)...(penalized) autocorrelation values for candidates
% Fest(iframe,icand)... frequency estimate of above
% Note voiceless candidate assumed in R(:,1)
% OctaveJumpCost... penalty per octave of transition frequency change for voiced-voiced
% VoicedUnvoicedCost ...fixed penalty for voicing switch per frame
% 	above evidently fixed for Boersma... but could be tuned to frame rate

%????? % % % % % Fixed 16 Sept 2003 all former references below are corrected to Rpen
%????% % % % %R(:,1)=0; Here's an example there were many more

% WHY WAS THIS HERE ?????Rpen(:,1)=0;
% OLD NAMES
% delta was BestCostToHere=repmat(inf,nframe,maxcand);
% psi was BackPointer=zeros(nframe,maxcand);
% new names compatible with BoersmaPitch_pathFinder.

 delta=repmat(inf,nframe,maxcand);
 psi=zeros(nframe,maxcand);



psi(1,1:ncand(1))=0;
bestState=zeros(nframe,1);
totalCostFromK=zeros(maxcand,1);
lg2F=Fest;
lg2F(Fest>0)=log2(Fest(Fest>0));

%transitionCost=zeros(maxcand,1);
f0=zeros(nframe,1);
% J is state in current frame K in previous
if DPTEST
    fprintf('iframe j(now) k(last) bestUptoK trans TotKIntoJ LocJ TotJviaK\n')
end
inxPrevVoiced=2:ncand(1);
% Cost of initial state
delta(1,1:ncand(1))=-Rpen(1,1:ncand(1));
% Calculate cost of moving from state k in frame iframe-1 to state j in iframe;

for iframe=2:nframe
    %	DPTEST=DPTEST | iframe>133;

    if DPTEST
        printsep('-')
        iframe
    end
    if DPTEST
        pausemsg newFrame
    end


    for j=1:ncand(iframe)
        VLESS_j=Fest(iframe,j)==0|Fest(iframe,j)>ceiling2;

        if DPTEST
            printfmt('iframe j(now) k(last) fj fk bestUptoK trans TotKIntoJ TotCostKthruJ \n');
        end
        % Must limit to available candates
        krng=1:ncand(iframe-1);
        for k= krng
            VLESS_k=Fest(iframe-1,k)==0|Fest(iframe-1,k)>ceiling2;
            transitionCost=NaN; % sentinel
            if (VLESS_k & VLESS_j) % voiceless to voiceless
                transitionCost=0;
            elseif (VLESS_k | VLESS_j) % one is voiceless but not both
                transitionCost = VoicedUnvoicedCost;
            else
                transitionCost = OctaveJumpCost.*abs(lg2F(iframe-1,k)-lg2F(iframe,j));
            end
            totalCostFromK(k) = transitionCost+delta(iframe-1,k);
            if DPTEST
                fprintf('%4d ',[iframe,j,k,round([Fest(iframe,j),Fest(iframe-1,k)])]);
                fprintf('%10.5f ',delta(iframe-1,k));
                fprintf('%10.5f ',[transitionCost,totalCostFromK(k),-Rpen(iframe,j),totalCostFromK(k)-Rpen(iframe,j)]);
                fprintf('\n');
            end
        end
        [bestCostToStateJ,kmin]=min(totalCostFromK(krng)); %But not including its local cost

        psi(iframe,j)=kmin;
        delta(iframe,j)=bestCostToStateJ-Rpen(iframe,j);
        if DPTEST
            fprintf('bestToJ %g from k = %d F=%4.0f\n', bestCostToStateJ, kmin, Fest(iframe-1,kmin));

        end
    end
    if DPTEST
        [bestSoFar,bestJ]=min(delta(iframe,:));
        kbpt=psi(iframe,bestJ);

        fprintf('bestScoreNow %g, j %d  freq %4.0f k %d prevfreq %4.0f ', ...
            bestSoFar,bestJ,Fest(iframe,bestJ),kbpt,Fest(iframe-1,kbpt));
        pausemsg DoneFrame
    end

end
% Traceback
[bestFinalCost,bestFinalState]=min(delta(nframe,:));
bestState(nframe)=bestFinalState;
f0(nframe)=Fest(nframe,bestFinalState);
for iframe=(nframe-1):-1:1
    bestState(iframe)=psi(iframe+1,bestState(iframe+1));
    % You had a terrible mistake here
    f0(iframe)=Fest(iframe,bestState(iframe));

end
if 0
    whaaat=find(f0>ceiling2);
    for ii=whaaat(:)'
        disp(' Overshoot????')
        theF0=f0(ii)
        theBestState=bestState(ii)
        theNcand=ncand(ii)
        theFest=Fest(ii,:);
        theRpen=Rpen(ii,:);
        FestRpen=[theFest',theRpen']
        pausemsg('OverShoot DBG')
    end

end
f0(f0>ceiling2)=0;

% bestState
% f0
%% NOTE THIS DOES USE ORIGINA UNPENALIZED R
phiBest=zeros(nframe,1);
for i=1:nframe
    phiBest(i)=R(i,bestState(i))*(f0(i)>0);
end
%keyboard


if pullFormants
    % just replace best candidate with 0 if it is above ceiling
    pullBool= f0(iframe)>ceiling & f0(iframe)<ceiling2;
   f0(pullBool)=0;
   phiBest(pullBool)=0; % Not sure what he's doing here
    % Boersma does fancy sorting of the Rpen array... we condider it meaningless
end
return
