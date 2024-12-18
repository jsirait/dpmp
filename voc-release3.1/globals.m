% Set up global variables used throughout the code

% directory for caching models, intermediate data, and results
cachedir = '/Users/junitasirait/dpmp/voc-release3.1/voccache/';

% directory for LARGE temporary files created during training
tmpdir = '/Users/junitasirait/dpmp/voc-release3.1/tmp/';

% dataset to use
VOCyear = '2007';

% directory with PASCAL VOC development kit and dataset
% VOCdevkit = ['~/VOC' VOCyear '/VOCdevkit/'];
VOCdevkit = '/Users/junitasirait/dpmp/VOCdevkit/';

% which development kit is being used
% this does not need to be updated
VOCdevkit2006 = false;
VOCdevkit2007 = false;
VOCdevkit2008 = false;
switch VOCyear
  case '2006'
    VOCdevkit2006=true;
  case '2007'
    VOCdevkit2007=true;
  case '2008'
    VOCdevkit2008=true;
end

