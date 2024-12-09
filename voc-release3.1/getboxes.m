function bbox = getboxes(model, boxes, from_head)

% bbox = getboxes(model, boxes)
% Predict bounding boxes from root and part locations.

if nargin < 3
  from_head = false;
end

if isempty(boxes)
  bbox = [];
else
  bbox = zeros(size(boxes,1), 5);
  for i = 1:size(boxes,1)
    A = [boxes(i,3)-boxes(i,1)];
    for j=1:4:size(boxes, 2)-2;
      A = [A boxes(i, j:j+1)];
    end
    c = boxes(i, end-1);
    bbox(i,:) = [A*model.components{c}.x1 ... 
                 A*model.components{c}.y1 ...
                 A*model.components{c}.x2 ...
                 A*model.components{c}.y2 ...
                 boxes(i, end)];
    % add padding if head 
    if from_head
      bbox(i, 4) = bbox(i, 4) + 4*(bbox(i, 4)-bbox(i, 2));
    end
  end
end
