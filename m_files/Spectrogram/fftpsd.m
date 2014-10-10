% FFTPSD - function to compute a sequence of spectra
%        - spectral stored as a matrix of nframes x nfilts
% Usage: y=fftpsd(wave,rate,nfilt,nsampf,nhop,pre,plotflag);

function y=fftpsd(wave,rate,nfilt,nsampf,nhop,pre,plotflag);

if ~exist('rate','var'), rate=10000; end;
if ~exist('nfilt','var'), nfilt=256; end;
if ~exist('nsampf','var'), nsampf=256; end;
if ~exist('nhop','var'), nhop=40; end;
if ~exist('pre','var'), pre=0; end;
if ~exist('plotflag','var'), plotflag=0; end;
 
nframes=round(((length(wave)-1)-(nsampf-nhop))/nhop);
nfft=nfilt*2;
delf=rate/(2*(nfilt-1));
y=zeros(nfilt,nframes);
freq=(1:nfilt)/nfilt*(rate/2);
maxw=max(wave);
minw=min(wave);
for iframe=1:nframes
 s1=round(((iframe-1)*nhop)+1);
 s2=round(s1+nsampf-1);
 s2=min(s2,length(wave)-1);
w=(wave(s1+1:s2+1)-(pre*(wave(s1:s2)))).*hanning(length(s1+1:s2+1));
 f=fft(w,nfft);
 pow=(f(1:nfilt).*conj(f(1:nfilt)))./(nfilt-1);
 y(:,iframe)=pow(1:nfilt);
end;
y=y';
