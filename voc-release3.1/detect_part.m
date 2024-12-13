function [boxes] = detect_part(input, part_name, thresh)

% Detect part objects in input using a model and a score threshold.
% Higher threshold leads to fewer detections.
%
% The function returns a matrix with one row per detected object.  The
% last column of each row gives the score of the detection.  The
% column before last specifies the component used for the detection.
% The first 4 columns specify the bounding box for the root filter and
% subsequent columns specify the bounding boxes of each part.


globals; 

if strcmp(part_name, 'head')
  model = load([cachedir 'head_final']).model;
elseif strcmp(part_name, 'upperbody')
  model = load([cachedir 'upperbody_final']).model;
elseif strcmp(part_name, 'lowerbody')
  model = load([cachedir 'lowerbody_final']).model;
else 
  error('Unknown part');
end

% we assume color images
input = color(input);

% prepare model for convolutions
rootfilters = [];
for i = 1:length(model.rootfilters)
  rootfilters{i} = model.rootfilters{i}.w;
end
partfilters = [];
for i = 1:length(model.partfilters)
  partfilters{i} = model.partfilters{i}.w;
end

% cache some data
for c = 1:model.numcomponents
  ridx{c} = model.components{c}.rootindex;
  oidx{c} = model.components{c}.offsetindex;
  root{c} = model.rootfilters{ridx{c}}.w;
  rsize{c} = [size(root{c},1) size(root{c},2)];
  numparts{c} = length(model.components{c}.parts);
  % numparts{c} = 0;
  for j = 1:numparts{c}
    pidx{c,j} = model.components{c}.parts{j}.partindex;
    % fprintf('pidx{%d,%d} = %d\n', c, j, pidx{c,j});
    didx{c,j} = model.components{c}.parts{j}.defindex;
    part{c,j} = model.partfilters{pidx{c,j}}.w;
    psize{c,j} = [size(part{c,j},1) size(part{c,j},2)];
    % reverse map from partfilter index to (component, part#)
    rpidx{pidx{c,j}} = [c j];
  end
end

% we pad the feature maps to detect partially visible objects
padx = ceil(model.maxsize(2)/2+1);
pady = ceil(model.maxsize(1)/2+1);

% the feature pyramid
interval = model.interval;
[feat, scales] = featpyramid(input, model.sbin, interval);

% detect at each scale
best = -inf;
ex = [];
boxes = [];
% fprintf('when detecting part, length(feat) = %d\n', length(feat));
for level = interval+1:length(feat)
  scale = model.sbin/scales(level); 
    
  % convolve feature maps with filters 
  featr = padarray(feat{level}, [pady padx 0], 0);
  rootmatch = fconv(featr, rootfilters, 1, length(rootfilters));
  if length(partfilters) > 0
    featp = padarray(feat{level-interval}, [2*pady 2*padx 0], 0);
    partmatch = fconv(featp, partfilters, 1, length(partfilters));
  end
  
  for c = 1:model.numcomponents
    % root score + offset
    score = rootmatch{ridx{c}} + model.offsets{oidx{c}}.w;  
    
    % add in parts
    for j = 1:numparts{c}
      def = model.defs{didx{c,j}}.w;
      anchor = model.defs{didx{c,j}}.anchor;
      % the anchor position is shifted to account for misalignment
      % between features at different resolutions
      ax{c,j} = anchor(1) + 1;
      ay{c,j} = anchor(2) + 1;
      match = partmatch{pidx{c,j}};
      [M, Ix{c,j}, Iy{c,j}] = dt(-match, def(1), def(2), def(3), def(4));
      score = score - M(ay{c,j}:2:ay{c,j}+2*(size(score,1)-1), ...
                        ax{c,j}:2:ax{c,j}+2*(size(score,2)-1));
    end

    % get all good matches
    I = find(score > thresh);
    [Y, X] = ind2sub(size(score), I);        
    tmp = zeros(length(I), 4*(1+numparts{c})+2);
    for i = 1:length(I)
      x = X(i);
      y = Y(i);
      [x1, y1, x2, y2] = rootbox_part(x, y, scale, padx, pady, rsize{c});
      % b is instantiated below
      b = [x1 y1 x2 y2];
      for j = 1:numparts{c}
        [probex, probey, px, py, px1, py1, px2, py2] = ...
            partbox(x, y, ax{c,j}, ay{c,j}, scale, padx, pady, ...
                    psize{c,j}, Ix{c,j}, Iy{c,j});
        % b is updated below to add parts
        b = [b px1 py1 px2 py2];
      end
      tmp(i,:) = [b c score(I(i))];
    end
    boxes = [boxes; tmp];
  end
end


% The functions below compute a bounding box for a root or part 
% template placed in the feature hierarchy.
%
% coordinates need to be transformed to take into account:
% 1. padding from convolution
% 2. scaling due to sbin & image subsampling
% 3. offset from feature computation    

function [x1, y1, x2, y2] = rootbox_part(x, y, scale, padx, pady, rsize)
  % unlike in the original code, 
  % we add horizontal padding to the head detection bounding box
x1 = (x-padx)*scale+1;
y1 = (y-pady)*scale+1;
x2 = x1 + rsize(2)*scale - 1;
y2 = y1 + rsize(1)*scale - 1;


function [probex, probey, px, py, px1, py1, px2, py2] = ...
    partbox(x, y, ax, ay, scale, padx, pady, psize, Ix, Iy)
probex = (x-1)*2+ax;
probey = (y-1)*2+ay;
px = double(Ix(probey, probex));
py = double(Iy(probey, probex));
px1 = ((px-2)/2+1-padx)*scale+1;
py1 = ((py-2)/2+1-pady)*scale+1;
px2 = px1 + psize(2)*scale/2 - 1;
py2 = py1 + psize(1)*scale/2 - 1;

% write an example to the data file
function exwrite(fid, ex)
fwrite(fid, ex.header, 'int32');
buf = [ex.offset.bl; ex.offset.w(:); ...
       ex.root.bl; ex.root.w(:)];
fwrite(fid, buf, 'single');
for j = 1:length(ex.part)
  if ~isempty(ex.part(j).w)
    buf = [ex.part(j).bl; ex.part(j).w(:); ...
           ex.def(j).bl; ex.def(j).w(:)];
    fwrite(fid, buf, 'single');
  end
end
