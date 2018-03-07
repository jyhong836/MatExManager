classdef InfoSystem

methods (Static)

function say (str, actualVerbose, requireVerbose)
	if exist('actualVerbose', 'var') && exist('requireVerbose', 'var') && actualVerbose >= requireVerbose || nargin == 1
		disp(str);
	end
end

end

end
