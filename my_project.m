% Clearing command window, workspace, and closing any open figures
clc;
clear;
way = '';

% Select data_train file
msgbox('Please select the data_train file.', 'Select File', 'modal');
pause(2);

[data_file, data_path] = uigetfile({'*.xlsx','Excel Files (*.xlsx)'},'Select Data File');
if isequal(data_file,0)
    msgbox('User selected Cancel', 'Operation Cancelled', 'modal');
    clc;
    clear;
    close;
    return;
end
data_file_path = fullfile(data_path, data_file);

% Select target file
msgbox('Please select the target file.', 'Select File', 'modal');
pause(2);

[output_file, output_path] = uigetfile({'*.xlsx','Excel Files (*.xlsx)'},'Select Output File');
if isequal(output_file,0)
    msgbox('User selected Cancel', 'Operation Cancelled', 'modal');
    clc;
    clear;
    close;
    return;
end
output_file_path = fullfile(output_path, output_file);

% Loading data from selected files
my_data = xlsread(data_file_path);
my_output = xlsread(output_file_path);

% Displaying information about the model and its factors
msgbox({'Hello...','Your model predicts diabetes!!',...
    'The model depends on these factors:',...
    'Pregnancies / Glucose / Blood Pressure / Skin Thickness / Insulin / BMI (Body Mass Index) / Diabetes Pedigree / Age'},...
    'Model Information');
pause(2);

% Define factor names
factor_names = {'Pregnancies', 'Glucose', 'Blood Pressure', 'Skin Thickness', ...
                'Insulin', 'BMI (Body Mass Index)', 'Diabetes Pedigree', 'Age'};

% Initialize test_row to NaN
test_row = NaN;

% Prompt the user to specify test data
choice = questdlg('How would you like to specify test data?', ...
                  'Test Data Specification', ...
                  'Select Row Number', 'Enter Values Manually', 'Select Row Number');
              
% Check if the user canceled the input dialog
if isempty(choice)
        msgbox('User canceled the select.','error');
        clc;
        clear;
        close;
        return;
end

% Based on the user's choice, proceed accordingly
if strcmp(choice, 'Select Row Number')
    way = 'row';
    % Prompt the user to select the row number for test data
    prompt = {'Select the row number (1-2460) to make it test_data:'};
    dlgtitle = 'Input';
    dims = [1 50];
    definput = {'1'}; % Default input value
    answer = inputdlg(prompt, dlgtitle, dims, definput);

    % Check if the user canceled the input dialog
    if isempty(answer)
        msgbox('User canceled the input.','error');
        clc;
        clear;
        close;
        return;
    end
    
    % Convert the user input to numeric value
    test_row = str2double(answer{1});

    % Checking if the input number of rows is within the valid range
    if (test_row > 2460 || test_row < 1 )
        msgbox('Number is not in the range 1 : 2460', 'Invalid Input', 'error', 'modal');
        return; % Exiting the script if the input is out of range
    end
    
    % Set test_data based on the selected row number
    test_data = my_data(test_row, :);
    
    % Create training datasets based on all available data excluding the selected row
    train_data = my_data([1:test_row-1 , test_row+1:end ], :);
    train_target = my_output([1:test_row-1 , test_row+1:end], :);
    
else
    % Enter Values Manually chosen
    way = 'man';
    % Initialize test_data to zeros
    test_data = zeros(1, numel(factor_names));
    
    % Prompt the user to input values for each factor
    for i = 1:numel(factor_names)
        prompt = sprintf('Enter value for %s:', factor_names{i});
        dlgtitle = 'Input';
        dims = [1 50];
        definput = {'0'}; % Default input value
        answer = inputdlg(prompt, dlgtitle, dims, definput);
        
        % Convert the user input to numeric value
        factor_value = str2double(answer{1});
        
        % Check if the user canceled or entered an invalid input
        if isempty(factor_value) || isnan(factor_value)
            msgbox('Invalid input or input canceled.', 'Error', 'error', 'modal');
            return;
        end
        
        % Store the factor value
        test_data(i) = factor_value;
    end
    
    % Use all available data for training
    train_data = my_data;
    train_target = my_output;
end

% Building a decision tree model using training data
tree_model = fitctree(train_data, train_target);

% Ask the user if they want to visualize the decision tree
choice = questdlg('Do you want to show the decision tree?', ...
                  'Decision Tree Visualization', ...
                  'Yes', 'No', 'Yes');

% Check the user's choice
if strcmp(choice, 'Yes')
    view(tree_model, 'Mode', 'graph'); % Displaying the decision tree
end


% Define factor names again
factor_names = {'Pregnancies', 'Glucose', 'Blood Pressure', 'Skin Thickness', ...
                'Insulin', 'BMI (Body Mass Index)', 'Diabetes Pedigree', 'Age'};
if strcmp(way, 'row')
    % Displaying actual class and factors information in one message box
    combined_msg = sprintf(['1 // Means He Has Diabetes, 0 // He Does Not Have Diabetes\n\n', ...
                        'Acual Class : %d\n\nFactors Information:\n\n'], my_output(test_row,:));
else
    % Displaying actual class and factors information in one message box
    combined_msg = sprintf(['1 // Means He Has Diabetes, 0 // He Does Not Have Diabetes\n\n', ...
                        '\nFactors Information:\n\n'], test_row);
end

for i = 1:numel(factor_names)
    combined_msg = [combined_msg, sprintf('%s:  %f\n', factor_names{i}, test_data(i))];
end

% Display the combined message box
msgbox(combined_msg, 'Diabetes Prediction and Information');
pause(3);



% Predicting classes for the test data using the trained model
predict_class = predict(tree_model, test_data);

if strcmp(way, 'row')
    if predict_class == 1
        if predict_class == my_output(test_row,:)
            msgbox('Predicted Class :  1  The Patient Has Diabetes /// result maches the acual class !!', 'Predicted Class Information');
        else
            msgbox('Predicted Class :  1  The Patient Has Diabetes /// result not maches the acual class !!', 'Predicted Class Information');
        end
    else
        if predict_class == my_output(test_row,:)
            msgbox('Predicted Class :  0  The Patient Has not Diabetes /// result maches the acual class !!', 'Predicted Class Information');
        else
            msgbox('Predicted Class :  0  The Patient Has not Diabetes /// result not maches the acual class !!', 'Predicted Class Information');
        end
    end
else
    if predict_class == 1
        msgbox('Predicted Class :  1  The Patient Has Diabetes ', 'Predicted Class Information');
    else
        msgbox('Predicted Class :  0  The Patient Does Not Have Diabetes ', 'Predicted Class Information');
    end
end
