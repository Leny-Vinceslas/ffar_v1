%  Saved from C:\NeareyMLTools\Sigantools\samp2ms.m 2006/10/12 15:18

function ms=samp2ms(ithsamp,Fs);
persistent FsSave
% function ms=samp2ms(ithsamp,Fs);
% convert milliseconds to sample number
% see also getsamp samp2ms getsig
if nargin<2|isempty(Fs);
    if ~isempty(FsSave)
        Fs=FsSave;
        warning('Last saved sampling rate being used')
    end
end
ms=(ithsamp-1)./Fs * 1000;
FsSave=Fs;
