function varargout = process_options (options, varargin)
% PROCESS_OPTIONS Process options.
%
% INPUT:   
%            options         - a struct of input arguments.
%            str1, ..., strn - Strings that are associated with a 
%                              particular variable
%            def1, ..., defn - Default values returned if no option
%                              is supplied
%
% OUTPUT:
%            var1, ..., varn - values to be assigned to variables
%            unused          - an optional cell array of those 
%                              string-value pairs that were unused;
%                              if this is not supplied, then a
%                              warning will be issued for each
%                              option in args that lacked a match.
%	
% Author: Junyuan Hong, 2017-12-02, jyhong836@gmail.com

% This fill was modified from PMTK3
% original comments

%% Process named arguments to a function
%
% This allows you to pass in arguments using name, value pairs
% eg func(x, y, 'u', 0, 'v', 1)
% Or you can pass in a  struct with named fields
% eg  S.u = 0; S.v = 1; func(x, y, S)
%
% Usage:  [var1, var2, ..., varn[, unused]] = ...
%           process_options(args, ...
%                           str1, def1, str2, def2, ..., strn, defn)
%
%
% Arguments:   
%            args            - a cell array of input arguments, such
%                              as that provided by VARARGIN.  Its contents
%                              should alternate between strings and
%                              values.
%            str1, ..., strn - Strings that are associated with a 
%                              particular variable
%            def1, ..., defn - Default values returned if no option
%                              is supplied
%
% Returns:
%            var1, ..., varn - values to be assigned to variables
%            unused          - an optional cell array of those 
%                              string-value pairs that were unused;
%                              if this is not supplied, then a
%                              warning will be issued for each
%                              option in args that lacked a match.
%
% Examples:
%
% Suppose we wish to define a Matlab function 'func' that has
% required parameters x and y, and optional arguments 'u' and 'v'.
% With the definition
%
%   function y = func(x, y, varargin)
%
%     [u, v] = process_options(varargin, 'u', 0, 'v', 1);
%
% calling func(0, 1, 'v', 2) will assign 0 to x, 1 to y, 0 to u, and 2
% to v.  The parameter names are insensitive to case; calling 
% func(0, 1, 'V', 2) has the same effect.  The function call
% 
%   func(0, 1, 'u', 5, 'z', 2);
%
% will result in u having the value 5 and v having value 1, but
% will issue a warning that the 'z' option has not been used.  On
% the other hand, if func is defined as
%
%   function y = func(x, y, varargin)
%
%     [u, v, unused_args] = process_options(varargin, 'u', 0, 'v', 1);
%
% then the call func(0, 1, 'u', 5, 'z', 2) will yield no warning,
% and unused_args will have the value {'z', 2}.  This behaviour is
% useful for functions with options that invoke other functions
% with options; all options can be passed to the outer function and
% its unprocessed arguments can be passed to the inner function.
%

% This file is from pmtk3.googlecode.com


%PMTKauthor Mark Paskin
%PMTKurl http://ai.stanford.edu/~paskin/software.html
%PMTKmodified Matt Dunham 

% Copyright (C) 2002 Mark A. Paskin

if ~isempty(options)
  optionsFields = fieldnames(options);
else
  optionsFields = [];
end
% Check the number of input arguments
n = length(varargin);
if (mod(n, 2))
  error('Each option must be a string/value pair.');
end

% Check the number of supplied output arguments
if (nargout < (n / 2))
  error('Insufficient number of output arguments given');
elseif (nargout == (n / 2))
  warn = true;
  nout = n / 2;
else
  warn = false;
  nout = n / 2 + 1;
end

% Set outputs to be defaults
varargout = cell(1, nout);
for i=2:2:n
  varargout{i/2} = varargin{i};
end

% Now process all arguments
nunused = 0;
for i=1:length(optionsFields)
  found = false;
  arg = optionsFields{i};
  for j=1:2:n
    if strcmpi(arg, varargin{j}) % || strcmpi(args{i}(2:end),varargin{j})
      varargout{(j + 1)/2} = options.(arg);
      found = true;
      break;
    end
  end
  if (~found)
    if (warn)
      % warning(sprintf('Option ''%s'' not used.', arg));
      % arg
    else
      nunused = nunused + 1;
      unused{2 * nunused - 1} = arg;
      unused{2 * nunused} = options.(arg);
    end
  end
end

% Assign the unused arguments
if (~warn)
  if (nunused)
    varargout{nout} = unused;
  else
    varargout{nout} = cell(0);
  end
end

end
