function b = boxplot_fam2nov(resp_matrix)
figure;
b = boxplot(resp_matrix, 'Labels', {'familiar', 'novel1', 'novel2'}, 'Notch', 'on');

% Hold on to add points and lines
hold on;

% Define x positions of each boxplot group
x_positions = [1, 2, 3];

% Plot individual data points and connect them
for i = 1:size(resp_matrix, 1)  % Loop through each row
    y_values = resp_matrix(i, :);  % Extract the i-th row
    
    % Scatter plot for individual data points
    scatter(x_positions, y_values, 50, 'filled', 'MarkerFaceColor', 'k', 'MarkerFaceAlpha',0.1); 
    
    % Connect the points with lines
    plot(x_positions, y_values, '-o', 'Color', [0.5, 0.5, 0.5], 'MarkerSize', 5);
end

% Formatting
hold off;
grid on;
title('Boxplot with Individual Data Points and Connecting Lines');
ylabel('Response');
end