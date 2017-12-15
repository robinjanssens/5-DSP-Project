function varargout = opgave3(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @opgave3_OpeningFcn, ...
                       'gui_OutputFcn',  @opgave3_OutputFcn, ...
                       'gui_LayoutFcn',  [], ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
       gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end

% ------------------------------
% Opening window
% ------------------------------
function opgave3_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;   % varargin   unrecognized PropertyName/PropertyValue pairs from the
    guidata(hObject, handles);  % Update handles structure
    %clear;  % remove all existign variables and data
    global xls_in;      % make 'xls_in' variable accesable
    global input;       % make 'input' variable accesable
    global fs;          % make 'fs' variable accesable
    xls_in = xlsread('./data/defaultdata.xlsx','A12:G2011');        % read data to 'xls_in' for a maximum of 2000 values
    fs = xlsread('./data/defaultdata.xlsx','A9:A9');                % read sample frequency to 'fs'
    input = xls_in(:,1);                                            % select first column from 'xls_in'
    menu_window_Callback(handles.menu_window, eventdata, handles);  % generate window function
    % add UAntwerpen logo
    axes(handles.axes_logo_uantwerpen);
    logo_uantwerpen = imread('./images/uantwerpen.png');
    image(logo_uantwerpen);
    axis off;
    axis image;
end


% --- Outputs from this function are returned to the command line.
function varargout = opgave3_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
end


% ------------------------------
% Functions
% ------------------------------
function update(handles)
    global xls_in;              % make 'xls_in' variable accesable
    global output;              % make 'output' variable accesable
    global fs;                  % make 'fs' variable accesable
    global selected_window;     % make 'selected_window' variable accesable
    global window;              % make 'window' variable accesable
    global selected_filter;     % make 'selected_filter' variable accesable
    global span;                % make 'span' variable accesable
    global degree;              % make 'degree' variable accesable

    % ------------------------------
    % Select Column
    % ------------------------------
    column = str2double(get(handles.edit_column, 'String'));	  % read column textbox
    column = uint32(column);                                    % make it unsigned integer to remove negative numbers and decimal numbers
    columns = size(xls_in,2);                                   % get the amount of columns in 'xls_in'
    if column < 1                                               % if selected column is smaller than first existing column
        column = 1;                                             % select first column
    elseif column > columns                                     % if selected column is larger than amount of existing columns
        column = columns;                                       % select last column
    end
    set(handles.edit_column,'string',num2str(column));          % change value in textbox
    input = xls_in(:,column);                                   % select column from 'xls_in'

    % ------------------------------
    % x-axis values
    % ------------------------------
    n = 0:1:length(input)-1;                      % generate sample x-axis values
    f = fs*(0:(length(input)/2))/length(input);   % generate frequency x-axis values

    % ------------------------------
    % Window Function
    % ------------------------------



    output = input .* window;       % calculate output using window function


    % ------------------------------
    % Filter
    % ------------------------------
    span = str2double(get(handles.edit_span,'String'));           % read span textbox
    span = uint32(span);                                          % make it unsigned integer to remove negative numbers and decimal numbers
    set(handles.edit_span,'string',num2str(span));                % change value in textbox

    contents = cellstr(get(handles.menu_filter,'String'));        % get popchoice content
    selected_filter = contents(get(handles.menu_filter,'Value')); % get popchoice value
    if strcmp(selected_filter,'Moving Average') || strcmp(selected_filter,'Savitzky-Golay Filter')
        % in 'Moving Average' mode and 'Savitzky-Golay' mode span needs to be bigger than 1 and an odd number
        if mod(span,2) == 0                                       % if span is not odd
            span = span-1;                                        % make it odd
            set(handles.edit_span,'string',num2str(span));        % change value in textbox
        end
        if span < 1                                               % if span is smaller than 1
            span = 1;                                             % make it 1
            set(handles.edit_span,'string',num2str(span));        % change value in textbox
        end
    elseif strcmp(selected_filter,'Local Regression (1th degree)') || strcmp(selected_filter,'Local Regression (2de degree)') || strcmp(selected_filter,'Robust Local Regression (1th degree)') || strcmp(selected_filter,'Robust Local Regression (2de degree)')
        % in regression modes span needs to be a percentage between 0 and 99
        if span > 99                                              % if span is bigger than 99
            span = 99;                                            % make it 99
            set(handles.edit_span,'string',num2str(span));        % change value in textbox
        end
    end

    degree = str2double(get(handles.edit_degree,'String')); % read degree textbox
    degree = uint32(degree);                                % make it unsigned integer to remove negative numbers and decimal numbers
    set(handles.edit_degree,'string',num2str(degree));      % change value in textbox
    if degree > span-1                                      % if degree is larger than span-1
        degree = span-1;                                    % make it span-1
        set(handles.edit_degree,'string',num2str(degree));  % change value in textbox
    end

    if strcmp(selected_filter,'No Filter')                                    % if no filter is selected
        % output = output (do nothing)
    elseif strcmp(selected_filter,'Moving Average')                           % if filter 'Moving Average' is selected
        output = smooth(output,double(span),'moving');                  % perform smooth() on output (span in samples)
    elseif strcmp(selected_filter,'Local Regression (1th degree)')            % if filter 'Local Regression (1th degree)' is selected
        output = smooth(output,double(span)/100,'lowess');              % perform smooth() on output (span in percentage)
    elseif strcmp(selected_filter,'Local Regression (2de degree)')            % if filter 'Local Regression (2de degree)' is selected
        output = smooth(output,double(span)/100,'loess');               % perform smooth() on output (span in percentage)
    elseif strcmp(selected_filter,'Savitzky-Golay Filter')                    % if filter Savitzky-Golay Filter' is selected
        output = smooth(output,double(span),'sgolay',double(degree));   % perform smooth() on output (span in samples)
    elseif strcmp(selected_filter,'Robust Local Regression (1th degree)')     % if filter 'Robust Local Regression (1th degree)' is selected
        output = smooth(output,double(span)/100,'rlowess');             % perform smooth() on output (span in percentage)
    elseif strcmp(selected_filter,'Robust Local Regression (2de degree)')     % if filter 'Robust Local Regression (2de degree)' is selected
        output = smooth(output,double(span)/100,'rloess');              % perform smooth() on output (span in percentage)
    end


    % ------------------------------
    % Plotting
    % ------------------------------
    % plot input
    axes(handles.plot_input);                       % select input plot
    if get(handles.checkbox_input,'Value') == 0     % 0 means time and 1 means frequency
        plot(n,input);                              % plot 'input' data
        xlabel('n (sample)');                       % set x-axis label
    else
        input_fft = fft(input);                                 % calculate fft from the input data
        input_fft = abs(input_fft);                             % take the absolute value of the vector to eliminate phase
        input_fft = input_fft/fs;                               % devide by sampling frequency to get the right amplitudes
        input_fft = input_fft(1:floor(length(input)/2+1));      % only take upperband
        input_fft(1) = input_fft(1)/2;                          % correct DC component (doubled because of overlap of upper- and lowerband)
        stem(f,input_fft);                          % plot fft from 'input' data
        xlabel('f (Hz)');                           % set x-axis label
    end

    % plot window function
    axes(handles.plot_window);                      % select window function plot
    if get(handles.checkbox_window,'Value') == 0    % 0 means time and 1 means frequency
        plot(n,window);                             % plot window function
        xlabel('n (sample)');                       % set x-axis label
    else
        window_fft = fft(window);                               % calculate fft from the window data
        window_fft = abs(window_fft);                           % take the absolute value of the vector to eliminate phase
        window_fft = window_fft/fs;                             % devide by sampling frequency to get the right amplitudes
        window_fft = window_fft(1:floor(length(input)/2+1));    % only take upperband
        window_fft(1) = window_fft(1)/2;                        % correct DC component (doubled because of overlap of upper- and lowerband)
        stem(f,window_fft);                         % plot fft from window function
        xlabel('f (Hz)');                           % set x-axis label
    end

    % plot output
    axes(handles.plot_output);                      % select output plot
    if get(handles.checkbox_output,'Value') == 0    % 0 means time and 1 means frequency
        plot(n,real(output));                       % plot 'output' data
        xlabel('n (sample)');                       % set x-axis label
    else
        output_fft = fft(output);                               % calculate fft from the output data
        output_fft = abs(output_fft);                           % take the absolute value of the vector to eliminate phase
        output_fft = output_fft/fs;                             % devide by sampling frequency to get the right amplitudes
        output_fft = output_fft(1:floor(length(input)/2+1));    % only take upperband
        output_fft(1) = output_fft(1)/2;                        % correct DC component (doubled because of overlap of upper- and lowerband)
        stem(f,output_fft);                         % plot fft from 'output' data
        xlabel('f (Hz)');                           % set x-axis label
    end
end


% ------------------------------
% Buttons
% ------------------------------
function button_open_Callback(hObject, eventdata, handles)
    global xls_in;                                  % make 'xls_in' variable accesable
    global fs;                                      % make 'fs' variable accesable
    [filename,pathname] = uigetfile('*.xlsx','Excel-files (*.xlsx)','Select the Excel file'); % ask user to select input file
    if not(isequal(filename,0))                     % if file is choosen (and not canceled)
        filename = strcat(pathname,filename);       % get complete path
        xls_in = xlsread(filename,'A12:G2011');     % read data to 'xls_in' for a maximum of 2000 values
        fs = xlsread(filename,'A9:A9');             % read sample frequency to 'fs'
        update(handles);                            % run calculation and plot
    end
end
function button_save_Callback(hObject, eventdata, handles)
    global output;              % make 'output' variable accesable
    global fs;                  % make 'fs' variable accesable
    global selected_window;     % make 'selected_window' variable accesable
    global selected_filter;     % make 'selected_filter' variable accesable
    global span;                % make 'span' variable accesable
    global degree;              % make 'degree' variable accesable
    % select file
    [filename,pathname] = uiputfile('*.xlsx','Excel-files (*.xlsx)','Select the Excel file'); % ask user to select output file
    if not(isequal(filename,0))                                                 % if file is choosen (and not canceled)
        filename = strcat(pathname,filename);                                   % get complete path
        % try to write everything
        status = xlswrite(filename,output,'Blad1','A12');                       % try to write output to xls file and write status response to status vector
        status = [status xlswrite(filename,fs,'Blad1','A9')];                   % try to write sample frequency to xls file and write status response to status vector
        status = [status xlswrite(filename,{'HZ'},'Blad1','B9')];               % try to write sample frequency unit to xls file and write status response to status vector
        status = [status xlswrite(filename,{'Window'},'Blad1','B6')];           % try to write 'Window' to xls file and write status response to status vector
        status = [status xlswrite(filename,selected_window,'Blad1','C6')];      % try to write selected_window to xls file and write status response to status vector
        status = [status xlswrite(filename,{'Filter'},'Blad1','B7')];           % try to write 'Filter' to xls file and write status response to status vector
        status = [status xlswrite(filename,selected_filter,'Blad1','C7')];      % try to write selected_filter to xls file and write status response to status vector
        if not(strcmp(selected_filter,'No Filter'))                             % unless 'No Filter' is selected
            status = [status xlswrite(filename,{'Span'},'Blad1','D7')];         % try to write 'Span' to xls file and write status response to status vector
            status = [status xlswrite(filename,span,'Blad1','E7')];             % try to write span value to xls file and write status response to status vector
            if strcmp(selected_filter,'Savitzky-Golay Filter')                  % if 'Savitzky-Golay Filter' is selected
                status = [status xlswrite(filename,{'Degree'},'Blad1','F7')];   % try to write 'Degree' to xls file and write status response to status vector
                status = [status xlswrite(filename,degree,'Blad1','G7')];       % try to write degree value to xls file and write status response to status vector
            end
        end
        status = prod(status);                                                  % take the product of all statuses (one '0' wil make the result '0')
        % message box with feedback
        if status                                                   % if saving is succesful
            msgbox('File saved succesfully', 'File Saved');         % show dialog
        else                                                        % if saving is not succesful
            msgbox('Failed to save File', 'Saving failed','error'); % show error dialog
        end
    end
end

% ------------------------------
% menu_window
% ------------------------------
function menu_window_Callback(hObject, eventdata, handles)
    global input;               % make 'input' varaible accesable
    global selected_window;     % make 'selected_window' variable accesable
    global window;              % make 'window' variable accesable
    contents = cellstr(get(handles.menu_window,'String'));          % get menu content
    selected_window = contents(get(handles.menu_window,'Value'));   % get menu value
    if strcmp(selected_window,'No Window')
        window = rectwin(length(input));
    elseif strcmp(selected_window,'Bartlett')
        window = bartlett(length(input));
    elseif strcmp(selected_window,'Chebyshev')
        window = chebwin(length(input));
    elseif strcmp(selected_window,'Hamming')
        window = hamming(length(input));
    elseif strcmp(selected_window,'Hann')
        window = hann(length(input));
    end
    update(handles);
end
function menu_filter_Callback(hObject, eventdata, handles)
    contents = cellstr(get(handles.menu_filter,'String'));          % get menu content
    selected_filter = contents(get(handles.menu_filter,'Value'));   % get menu value
    % enable and disable the right tweakable parameters
    if strcmp(selected_filter,'No Filter')
        set(handles.text_span,'visible','off');
        set(handles.edit_span,'visible','off');
        set(handles.text_samples,'visible','off');
        set(handles.text_percent,'visible','off');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    elseif strcmp(selected_filter,'Moving Average')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','on');
        set(handles.text_percent,'visible','off');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    elseif strcmp(selected_filter,'Local Regression (1th degree)')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','off');
        set(handles.text_percent,'visible','on');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    elseif strcmp(selected_filter,'Local Regression (2de degree)')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','off');
        set(handles.text_percent,'visible','on');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    elseif strcmp(selected_filter,'Savitzky-Golay Filter')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','on');
        set(handles.text_percent,'visible','off');
        set(handles.text_degree,'visible','on');
        set(handles.edit_degree,'visible','on');
    elseif strcmp(selected_filter,'Robust Local Regression (1th degree)')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','off');
        set(handles.text_percent,'visible','on');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    elseif strcmp(selected_filter,'Robust Local Regression (2de degree)')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','off');
        set(handles.text_percent,'visible','on');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    end
    update(handles);
end

% ------------------------------
% Textbox
% ------------------------------
function edit_low_Callback(hObject, eventdata, handles)
    update(handles);
end
function edit_column_Callback(hObject, eventdata, handles)
    update(handles);
end
function edit_span_Callback(hObject, eventdata, handles)
    update(handles);
end
function edit_degree_Callback(hObject, eventdata, handles)
    update(handles);
end

% ------------------------------
% Checkbox
% ------------------------------
function checkbox_input_Callback(hObject, eventdata, handles)
    update(handles)
end
function checkbox_window_Callback(hObject, eventdata, handles)
    update(handles);
end
function checkbox_output_Callback(hObject, eventdata, handles)
    update(handles)
end


% ------------------------------
% Create fucntions
% ------------------------------
function menu_window_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function menu_filter_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function edit_column_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function edit_span_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function edit_degree_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
