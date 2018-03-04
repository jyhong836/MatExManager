classdef InfoSystem

methods (Static)

function say (str, actualVerbose, requireVerbose)
	if actualVerbose >= requireVerbose
		disp(str);
	end
end

end

end
