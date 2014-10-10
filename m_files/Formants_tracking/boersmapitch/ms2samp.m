%  Saved from C:\NeareyMLTools\Sigantools\ms2samp.m 2006/10/12 15:18

function ithsamp=ms2samp(ms,Fs);
%function ithsamp=ms2samp(ms,Fs);
% convert milliseconds to sample number
% see also getsamp samp2ms getsig
ithsamp=round(ms./1000.*Fs)+1;

