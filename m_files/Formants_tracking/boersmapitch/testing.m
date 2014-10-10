%  Saved from C:\NeareyMLTools\filetools\testing.m 2006/10/12 15:18

function t=testing(tin);
% function t=testing(tin);
% t=testing; returns current value
% t=testing(val); sets current value testing state
% A boolian pseudo global...
% can be toggled on or off by caller;

persistent testingState
if isempty(testingState)
	testingState=0;
end
if nargin==1
	if ischar(tin)
		ttin=tin;
		ttin=upper(ttin);
		if isequal(upper(ttin),'ON')|isequal(ttin,'1')
			tin=1;
		elseif isequal(upper(ttin),'OFF')|isequal(ttin,'0')
			tin=0;
		else
			warning('Unrecognized argument to TESTING')
			%testing
			return
		end
	end
	testingState=tin;
end
t=testingState;
