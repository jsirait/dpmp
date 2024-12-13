function test_passed = bbox_intersection_test()
    test_passed = false;
    % Define input variables
    a = [0, 0, 5, 5; 10, 10, 20, 20; 5, 5, 15, 15];
    b = [3, 3, 7, 7; 12, 12, 14, 14];
    
    % Expected output
    expected_result = [10, 10, 20, 20; 5, 5, 15, 15]
    
    % Call the function
    result = bbox_intersection(a, b);
    fprintf('Result: %s\n', mat2str(result));
    
    %  sort both the result and expected_result
    result = sort(result, 1);
    expected_result = sort(expected_result, 1);

    % Test the result
    test_passed = isequal(result, expected_result);
end