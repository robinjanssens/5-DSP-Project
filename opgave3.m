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
    clear;  % remove all existign variables and data
    % UIWAIT makes opgave3 wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = opgave3_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
end


% ------------------------------
% Main
% ------------------------------
function update(handles)
    global xls_in;
    global window;
    global output;

    column = str2double(get(handles.edit_column, 'String'));
    columns = size(xls_in,2);
    if 1 <= column && column <= columns

        input = xls_in(:,column); % select column
        input = input(12:end);    % remove first 11 rows

        samples = 300;             % Hz
        n = 0:1:length(input)-1;
        w = (-(length(input)-1)/2:(length(input)-1)/2)*samples/length(input);
        f = 2*pi*w;

        % input FFT
        input_fft = fft(input);
        input_fft = abs(input_fft);
        input_fft = fftshift(input_fft);

        % ------------------------------
        % Window Function
        % ------------------------------
        contents = cellstr(get(handles.menu_window,'String'));
        popChoice = contents(get(handles.menu_window,'Value'));
        if strcmp(popChoice,'No Window')
            window = rectwin(length(input));
        elseif strcmp(popChoice,'Bartlett')
            window = bartlett(length(input));
        elseif strcmp(popChoice,'Chebyshev')
            window = chebwin(length(input));
        elseif strcmp(popChoice,'Hamming')
            window = hamming(length(input));
        elseif strcmp(popChoice,'Hann')
            window = hann(length(input));
        end

        % window FFT
        window_fft = fft(window);
        window_fft = abs(window_fft);
        window_fft = fftshift(window_fft);
        %window_fft = window_fft / max(window_fft);  % amplitude = 1

        % calculate output
        output = input .* window;

        % ------------------------------
        % Filter
        % ------------------------------
        span = str2double(get(handles.edit_span,'String'));     % read span textbox
        span = uint32(span);                                    % make it unsigned integer
        set(handles.edit_span,'string',num2str(span));          % change value in textbox
        
        contents = cellstr(get(handles.menu_filter,'String'));  % get popchoice content
        popChoice = contents(get(handles.menu_filter,'Value')); % get popchoice value
        if strcmp(popChoice,'Moving Average') || strcmp(popChoice,'Savitzky-Golay Filter')
            % in 'Moving Average' mode and 'Savitzky-Golay' mode span needs to be bigger than 1 and an odd number
            if mod(span,2) == 0                                     % if span is not odd
                span = span-1;                                      % make it odd
                set(handles.edit_span,'string',num2str(span));      % change value in textbox
            end
            if span < 1                                             % if span is smaller than 1
                span = 1;                                           % make it 1
                set(handles.edit_span,'string',num2str(span));      % change value in textbox
            end
        elseif strcmp(popChoice,'Local Regression (1th degree)') || strcmp(popChoice,'Local Regression (2de degree)') || strcmp(popChoice,'Robust Local Regression (1th degree)') || strcmp(popChoice,'Robust Local Regression (2de degree)')
            % in regression modes span needs to be a percentage between 0 and 99
            if span > 99                                            % if span is bigger than 99
                span = 99;                                          % make it 99
                set(handles.edit_span,'string',num2str(span));      % change value in textbox
            end
        end
        
        

        degree = str2double(get(handles.edit_degree,'String')); % read degree textbox
        degree = uint32(degree);                                % make it unsigned integer
        set(handles.edit_degree,'string',num2str(degree));      % change value in textbox
        if degree > span-1                                      % if degree is larger than span-1
            degree = span-1;                                    % make it span-1
            set(handles.edit_degree,'string',num2str(degree));  % change value in textbox
        end

        contents = cellstr(get(handles.menu_filter,'String'));  % get popchoice content
        popChoice = contents(get(handles.menu_filter,'Value')); % get popchoice value
        if strcmp(popChoice,'No Filter')                                    % if no filter is selected
                                                                            % output = output (do nothing)
        elseif strcmp(popChoice,'Moving Average')                           % if filter 'Moving Average' is selected
            output = smooth(output,double(span),'moving');                  % perform smooth() on output (span in samples)
        elseif strcmp(popChoice,'Local Regression (1th degree)')            % if filter 'Local Regression (1th degree)' is selected
            output = smooth(output,double(span)/100,'lowess');              % perform smooth() on output (span in percentage)
        elseif strcmp(popChoice,'Local Regression (2de degree)')            % if filter 'Local Regression (2de degree)' is selected
            output = smooth(output,double(span)/100,'loess');               % perform smooth() on output (span in percentage)
        elseif strcmp(popChoice,'Savitzky-Golay Filter')                    % if filter Savitzky-Golay Filter' is selected
            output = smooth(output,double(span),'sgolay',double(degree));   % perform smooth() on output (span in samples)
        elseif strcmp(popChoice,'Robust Local Regression (1th degree)')     % if filter 'Robust Local Regression (1th degree)' is selected
            output = smooth(output,double(span)/100,'rlowess');             % perform smooth() on output (span in percentage)
        elseif strcmp(popChoice,'Robust Local Regression (2de degree)')     % if filter 'Robust Local Regression (2de degree)' is selected
            output = smooth(output,double(span)/100,'rloess');              % perform smooth() on output (span in percentage)
        end




        % output FFT
        output_fft = fft(output);
        output_fft = abs(output_fft);
        output_fft = fftshift(output_fft);

        % plot input
        axes(handles.plot_input);
        if get(handles.checkbox_input,'Value') == 0 % 0 => time / 1 => frequency
            plot(n,input);
            xlabel('n (sample)');
        else
            stem(f,input_fft);
            xlabel('f (Hz)');
        end

        % plot window function
        axes(handles.plot_window);
        if get(handles.checkbox_window,'Value') == 0 % 0 => time / 1 => frequency
            plot(n,window);
            xlabel('n (sample)');
        else
            stem(f,window_fft);
            xlabel('f (Hz)');
        end

        % plot output
        axes(handles.plot_output);
        if get(handles.checkbox_output,'Value') == 0 % 0 => time / 1 => frequency
            plot(n,real(output));
            xlabel('n (sample)');
        else
            stem(f,output_fft);
            xlabel('f (Hz)');
        end
    end
end


% ------------------------------
% Buttons
% ------------------------------
function button_open_Callback(hObject, eventdata, handles)
    global xls_in;                                              % make 'xls_in' variable accesable
    [FileName,PathName] = uigetfile('*.xlsx','Excel-files (*.xlsx)','Select the Excel code file'); % ask user to select input file
    filename = strcat(PathName,FileName);                       % get complete path
    xls_in = xlsread(filename);                                 % read file to 'xls_in'
    update(handles);                                            % run calculation and plot
end
function button_save_Callback(hObject, eventdata, handles)
    global output;                                              % make 'output' variable accesable
    xls_out = [zeros(11,1);output]                              % create offset
    [FileName,PathName] = uiputfile('*.xlsx','Excel-files (*.xlsx)','Select the Excel code file'); % ask user to select output file
    filename = strcat(PathName,FileName);                       % get complete path
    status = xlswrite(filename,xls_out);           % try to write xls file
    if status                                                   % if saving is succesful 
        msgbox('File saved succesfully', 'File Saved');         % show dialog
    else                                                        % if saving is not succesful
        msgbox('Failed to save File', 'Saving failed','error'); % show error dialog
    end
    %outputFile = get(handles.edit_output, 'String');
    %csvwrite(outputFile,output);
end

% ------------------------------
% menu_window
% ------------------------------
function menu_window_Callback(hObject, eventdata, handles)
    update(handles);
end
function menu_filter_Callback(hObject, eventdata, handles)
    % enable and disable the right tweakable parameters
    contents = cellstr(get(handles.menu_filter,'String'));  % get popchoice content
    popChoice = contents(get(handles.menu_filter,'Value')); % get popchoice value
    if strcmp(popChoice,'No Filter')
        set(handles.text_span,'visible','off');
        set(handles.edit_span,'visible','off');
        set(handles.text_samples,'visible','off');
        set(handles.text_percent,'visible','off');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    elseif strcmp(popChoice,'Moving Average')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','on');
        set(handles.text_percent,'visible','off');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    elseif strcmp(popChoice,'Local Regression (1th degree)')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','off');
        set(handles.text_percent,'visible','on');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    elseif strcmp(popChoice,'Local Regression (2de degree)')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','off');
        set(handles.text_percent,'visible','on');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    elseif strcmp(popChoice,'Savitzky-Golay Filter')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','on');
        set(handles.text_percent,'visible','off');
        set(handles.text_degree,'visible','on');
        set(handles.edit_degree,'visible','on');
    elseif strcmp(popChoice,'Robust Local Regression (1th degree)')
        set(handles.text_span,'visible','on');
        set(handles.edit_span,'visible','on');
        set(handles.text_samples,'visible','off');
        set(handles.text_percent,'visible','on');
        set(handles.text_degree,'visible','off');
        set(handles.edit_degree,'visible','off');
    elseif strcmp(popChoice,'Robust Local Regression (2de degree)')
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
