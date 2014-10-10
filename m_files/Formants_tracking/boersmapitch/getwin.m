%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/getwin.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:getwin.m 2002/11/6 19:5

function [window]=getwin(nwin,wintype,Fs)
% function window=getwin(nwin,wintype)
% or window=getwin(windurms,wintype,Fs)
% if there are three input arguments, nwin is taken to be
% a duration in ms
% Windows implemented HAMMING, HANNING, COS4, GAUSS, RECT
% Copyright 1997-2001 T.M. Nearey
if nargin==3
	nwin=ceil(nwin/1000*Fs);
end
if nargin<2|isempty(wintype)
	wintype='HAMMING';
end
wintype=upper(wintype);
switch wintype
case 'HAMMING'
	window = 0.54 - 0.46*cos(2*pi*(0:nwin-1)/nwin)';
	%disp('hamming');
case 'COS4'
	window=coswin(nwin,4);
	%disp('Cos4');
case {'HANNING', 'HANN'}
	window = .5*(1 - cos(2*pi*(1:nwin)'/(nwin+1)));
case {'GAU','GAUSS','GAUSSIAN'}
	% P. Boersma IFA proceedinfgs(Institute of Phontics Sciences, University of Amsterdam
	% Proceeding 17 (1993)  17, 1993
	% Accurate short-term analysis of the fundamental frequency
	% and the harmonics-to-noise ratio
	% of a sampled sound. pp 97-110
	window=exp(-12*(([1:nwin]'-.5)/nwin-.5).^2)/(1-exp(-12));
case {'RECT','RECTANGULAR'}
	window=ones(nwin,1);

otherwise
	warning('Window not defined ... hamming substituted')
	legalwins='HAMMING, COS4, RECT, HANNING, GAUSS'
	window = 0.54 - 0.46*cos(2*pi*(0:nwin-1)/nwin)';
	pause
end
