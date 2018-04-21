classdef Logger < handle
% Provider a class to do logging.

properties
	logField % A string indiciating the field of log, outputing: '[<logField>]'
	verbose
end

methods

function self = Logger (varargin)
	inp = inputParser;
	inp.addOptional('field', []);
	inp.addOptional('verbose', 0);
	inp.parse(varargin{:});
	self.logField = inp.Results.field;
	self.verbose = inp.Results.verbose;
end

function say (self, str, requireVerbose)
	if nargin == 2 || (exist('requireVerbose', 'var') && self.verbose >= requireVerbose)
		if ~isempty(self.logField)
			head = ['[' self.logField ']'];
		end
		disp([head ' ' str]);
	end

end

end % END: methods

end % END: classdef
