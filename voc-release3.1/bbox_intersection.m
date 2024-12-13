function result = bbox_intersection(a, b)
    if isempty(a) || isempty(b) || size(a, 2) < 4 || size(b, 2) < 4
        fprintf('size(a, 1): %d, size(a,2): %d, size(a, 1): %d, size(a,2): %d\n', size(a,1), size(a,2), size(b,1), size(b,2));
        % error('Input bounding boxes must have at least 4 columns [x_min, y_min, x_max, y_max].');
        result = zeros(0, 5);
    else

        [x_min, x_max, y_min, y_max] = compute_extents([a; b]);

        % Define grid cell size based on average box size 
        avg_width = mean([a(:, 3) - a(:, 1); b(:, 3) - b(:, 1)]);
        avg_height = mean([a(:, 4) - a(:, 2); b(:, 4) - b(:, 2)]);
        cell_size = [avg_width, avg_height];

        grid = create_grid(a, x_min, x_max, y_min, y_max, cell_size);
        result = [];

        for i = 1:size(b, 1)
            box_b = b(i, :);
            b_area = compute_area(box_b);
            overlapping_cells = find_cells_for_box(box_b, x_min, y_min, cell_size);
            candidates = [];
            for cell_idx = 1:size(overlapping_cells, 1)
                row = overlapping_cells(cell_idx, 1);
                col = overlapping_cells(cell_idx, 2);
                if row > 0 && row <= size(grid, 1) && col > 0 && col <= size(grid, 2)
                    candidates = [candidates; grid{row, col}(:)];
                end
            end

            candidates = unique(candidates); % Remove duplicates
            for j = 1:numel(candidates)
                box_a_idx = candidates(j);
                box_a = a(box_a_idx, :);
                intersection_area = compute_intersection(box_a, box_b);
                if intersection_area >= 0.5 * b_area
                    result = [result; box_a];
                end
            end
        end
        result = unique(result, 'rows');
    end
end

function [x_min, x_max, y_min, y_max] = compute_extents(boxes)
    x_min = min(boxes(:, 1));
    x_max = max(boxes(:, 3));
    y_min = min(boxes(:, 2));
    y_max = max(boxes(:, 4));
end

function grid = create_grid(boxes, x_min, x_max, y_min, y_max, cell_size)
    num_rows = ceil((y_max - y_min) / cell_size(2));
    num_cols = ceil((x_max - x_min) / cell_size(1));
    grid = cell(num_rows, num_cols);
    for i = 1:size(boxes, 1)
        box = boxes(i, :);
        cells = find_cells_for_box(box, x_min, y_min, cell_size);
        for cell_idx = 1:size(cells, 1)
            row = cells(cell_idx, 1);
            col = cells(cell_idx, 2);
            if row > 0 && row <= num_rows && col > 0 && col <= num_cols
                grid{row, col} = [grid{row, col}, i];
            end
        end
    end
end

function cells = find_cells_for_box(box, x_min, y_min, cell_size)
    col_min = max(1, floor((box(1) - x_min) / cell_size(1)) + 1);
    col_max = max(1, floor((box(3) - x_min) / cell_size(1)) + 1);
    row_min = max(1, floor((box(2) - y_min) / cell_size(2)) + 1);
    row_max = max(1, floor((box(4) - y_min) / cell_size(2)) + 1);

    [rows, cols] = ndgrid(row_min:row_max, col_min:col_max);
    cells = [rows(:), cols(:)];
end

function area = compute_area(box)
    width = max(0, box(3) - box(1));
    height = max(0, box(4) - box(2));
    area = width * height;
end

function intersection = compute_intersection(box1, box2)
    x1 = max(box1(1), box2(1));
    y1 = max(box1(2), box2(2));
    x2 = min(box1(3), box2(3));
    y2 = min(box1(4), box2(4));
    intersection = max(0, x2 - x1) * max(0, y2 - y1);
end
