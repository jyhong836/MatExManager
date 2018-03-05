% @Author: Junyuan Hong
% @Date:   2018-03-05
% @Last Modified by:   Junyuan Hong
% @Last Modified time: 2018-03-05
function simple_demo

	init;

	% //////////// demo with data set ////////
	datasetName = 'PreWine';
	options = struct('modelProvider', DemoModelProvider());
	EM = ExperimentManager ( datasetName, options );
	EM.setup();
	EM.runAll(); % Run all required methods.
	results = EM.outputResults();

end


