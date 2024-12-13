function [ap] = pascal(cls, n)

% [ap1, ap2] = pascal(cls, n)
% Train and score a model with n components.

globals;
pascal_init;

% model = pascal_train(cls, n);
model = load([cachedir 'person_final'], 'model').model;
[boxes1, boxes2] = pascal_test(cls, model, 'test', VOCyear);
ap1 = pascal_eval(cls, boxes1, 'test', ['1_' VOCyear]);
ap2 = pascal_eval(cls, boxes2, 'test', ['2_' VOCyear]);
ap = [ap1 ap2];

% For inference with parts detectors
% [boxes_with_head, boxes_with_upperbody, boxes_with_lowerbody, boxes_with_one, boxes_with_two, boxes_with_all] = pascal_test(cls, model, 'test', VOCyear);
% ap_with_head = pascal_eval(cls, boxes_with_head, 'test', 'with_head');
% ap_with_upperbody = pascal_eval(cls, boxes_with_upperbody, 'test', 'with_upperbody');
% ap_with_lowerbody = pascal_eval(cls, boxes_with_lowerbody, 'test', 'with_lowerbody');
% ap_with_one = pascal_eval(cls, boxes_with_one, 'test', 'with_one');
% ap_with_two = pascal_eval(cls, boxes_with_two, 'test', 'with_two');
% ap_with_all = pascal_eval(cls, boxes_with_all, 'test', 'with_all');
% ap = [ap_with_head ap_with_upperbody ap_with_lowerbody ap_with_one ap_with_two ap_with_all];
end
