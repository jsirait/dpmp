function showboxes(im, boxes, threshold)

% showboxes(im, boxes)
% Draw boxes on top of image.

if nargin < 3
  thresh = -inf;
end

clf;
image(im); 
axis equal;
axis off;
if ~isempty(boxes)
  % Filter boxes based on the last column
  valid_boxes = boxes(boxes(:, end) > threshold, :);
  
  numfilters = floor(size(valid_boxes, 2)/4);
  for i = 1:numfilters
    x1 = valid_boxes(:,1+(i-1)*4);
    y1 = valid_boxes(:,2+(i-1)*4);
    x2 = valid_boxes(:,3+(i-1)*4);
    y2 = valid_boxes(:,4+(i-1)*4);
    if i == 1
      c = 'r';
    else
      c = 'b';
    end
    line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', 'color', c, 'linewidth', 3);
  end
end
drawnow;