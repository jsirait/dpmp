function [boxes_with_head, boxes_with_upperbody, boxes_with_lowerbody, boxes_with_one, boxes_with_two, boxes_with_all] = pascal_test(cls, model, testset, suffix)

  % [boxes1, boxes2] = pascal_test(cls, model, testset, suffix)
  % Compute bounding boxes in a test set.
  % boxes1 are bounding boxes from root placements
  % boxes2 are bounding boxes using predictor function
  tic
  globals;
  pascal_init;
  ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
  
  % run detector in each image
  try
    load([cachedir cls '_boxes_' testset '_' suffix]);
  catch
    for i = 1:length(ids);
    % for i = 1:3;
      fprintf('%s: testing: %s %s, %d/%d\n', cls, testset, VOCyear, ...
              i, length(ids));
      im = imread(sprintf(VOCopts.imgpath, ids{i}));  
      boxes = detect(im, model, model.thresh);
      % let us use head detector to complement the person detector
      all_head_boxes = detect_part(im, 'head', model.thresh);
      all_upperbody_boxes = detect_part(im, 'upperbody', model.thresh);
      all_lowerbody_boxes = detect_part(im, 'lowerbody', model.thresh);
      if ~isempty(boxes)
        % boxes1{i} = [];
        % b2 is better than b1 so we just use b2
        b2 = getboxes(model, boxes);
        b2 = clipboxes(im, b2);
        % boxes1 is what b2 would have been
        % and b2 is the combined boxes
        just_person = nms(b2, 0.5);
        % for parts only use part root
        head_boxes = nms(clipboxes(im, all_head_boxes(:,[1 2 3 4 end])), 0.5);
        upperbody_boxes = nms(clipboxes(im, all_upperbody_boxes(:,[1 2 3 4 end])), 0.5);
        lowerbody_boxes = nms(clipboxes(im, all_lowerbody_boxes(:,[1 2 3 4 end])), 0.5);
        % then only use person boxes that contain at least 50% of any head box
        boxes_with_head{i} = bbox_intersection(just_person, head_boxes);
        boxes_with_upperbody{i} = bbox_intersection(just_person, upperbody_boxes);
        boxes_with_lowerbody{i} = bbox_intersection(just_person, lowerbody_boxes);
        boxes_with_one{i} = union_(union_(boxes_with_head{i}, boxes_with_upperbody{i}), boxes_with_lowerbody{i});
        boxes_with_two{i} = union_(union_(intersection_(boxes_with_head{i}, boxes_with_upperbody{i}), intersection_(boxes_with_head{i}, boxes_with_lowerbody{i})), intersection_(boxes_with_upperbody{i}, boxes_with_lowerbody{i}));
        boxes_with_all{i} = intersection_(boxes_with_head{i}, intersection_(boxes_with_upperbody{i}, boxes_with_lowerbody{i}));

      else
        boxes_with_head{i} = [];
        boxes_with_upperbody{i} = [];
        boxes_with_lowerbody{i} = [];
        boxes_with_one{i} = [];
        boxes_with_two{i} = [];
        boxes_with_all{i} = [];
      end
      % showboxes(im, boxes1{i});  % does excluding this make faster? not really 
    end    
    save([cachedir cls '_boxes_' testset '_' suffix], 'boxes_with_head', 'boxes_with_upperbody', 'boxes_with_lowerbody', 'boxes_with_one', 'boxes_with_two', 'boxes_with_all');
    toc
  end

function result = intersection_(a, b)
  if isempty(a) || isempty(b) || size(a, 2) < 4 || size(b, 2) < 4
      fprintf('size(a, 1): %d, size(a,2): %d, size(a, 1): %d, size(a,2): %d\n', size(a,1), size(a,2), size(b,1), size(b,2));
      % error('Input bounding boxes must have at least 4 columns [x_min, y_min, x_max, y_max].');
      result = zeros(0, 5);
  else
    result = intersect(a, b, 'rows');
  end

function result = union_(a, b)
  if isempty(a) || isempty(b) || size(a, 2) < 4 || size(b, 2) < 4
      % fprintf('size(a, 1): %d, size(a,2): %d, size(a, 1): %d, size(a,2): %d\n', size(a,1), size(a,2), size(b,1), size(b,2));
      % error('Input bounding boxes must have at least 4 columns [x_min, y_min, x_max, y_max].');
      result = zeros(0, 5);
  else
    result = union(a, b, 'rows');
  end