function bbox = process(image, model, thresh, as_head)

% bbox = process(image, model, thresh)
% Detect objects that score above a threshold, return bonding boxes.
% If the threshold is not included we use the one in the model.
% This should lead to high-recall but low precision.

if nargin < 4
  as_head = false;
end

if nargin < 3
  thresh = model.thresh
end

bbox = [];

if as_head
  % boxes_head = detect_head(image, model, thresh);
  boxes = detect_head(image, model, thresh);
  % set the values of bbox to be x1, y1, x2, y2+4*(y2-y1), score
  % bbox = [bbox(:, 1), bbox(:, 2), bbox(:, 3), bbox(:, 4) + 4*(bbox(:, 4)-bbox(:, 3)), bbox(:, end)];
  % bbox = [bbox(:, 1), bbox(:, 2), bbox(:, 3), bbox(:, 4) + 4*(bbox(:, 4)-bbox(:, 2)), bbox(:, end)];
else
  boxes = detect(image, model, thresh);
  % bbox = getboxes(model, boxes);
end

bbox = getboxes(model, boxes, as_head);
bbox = nms(bbox, 0.5);
bbox = clipboxes(image, bbox);
