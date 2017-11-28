function varargout = projectDSP(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @projectDSP_OpeningFcn, ...
                       'gui_OutputFcn',  @projectDSP_OutputFcn, ...
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
function projectDSP_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;   % varargin   unrecognized PropertyName/PropertyValue pairs from the
    guidata(hObject, handles);  % Update handles structure
    clear;  % remove all existign variables and data
    % UIWAIT makes projectDSP wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = projectDSP_OutputFcn(hObject, eventdata, handles)
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
        
        input = xls_in(:,column);
        input = transpose(input);
        input = cat(2,input(1:length(input)-1),flip(input));
        
        samples = 100;   % Hz or Sa/s
        x = -(length(input)-1)/2/samples:1/samples:(length(input)-1)/2/samples;
        w = (-(length(input)-1)/2:(length(input)-1)/2)*samples/length(input);
        f = 2*pi*w;

        % input FFT
        input_fft = fft(input);
        input_fft = abs(input_fft);
        input_fft = fftshift(input_fft);
        
        % get the window function
        cutoff = str2double(get(handles.edit_cutoff,'String'));
        contents = cellstr(get(handles.popupmenu,'String'));
        popChoice = contents(get(handles.popupmenu,'Value'));
        if (strcmp(popChoice,'Boxcar'))
            window = rectwin(2*cutoff);
        elseif (strcmp(popChoice,'Chebyshev'))
            window = chebwin(2*cutoff);     % *2 because mirrored
        elseif (strcmp(popChoice,'Hamming'))
            window = hamming(2*cutoff);
        elseif (strcmp(popChoice,'Hann'))
            window = hann(2*cutoff);
        end
        window(length(input)) = 0;
        window = circshift(window,floor(length(window)/2)-cutoff);
        window = transpose(window);   % window functions gives vertical matrices back
        % FFT
        window_fft = window;
        %window_fft = fft(window);
        %window_fft = abs(window_fft);
        %window_fft = fftshift(window_fft);
        %window_fft = window_fft / max(window_fft);  % amplitude = 1
        
        length(input)
        length(window)
        
        % calculate output
        output_fft = input_fft .* window_fft;
        % inverse FFT
        output = ifft(fftshift(output_fft));


        % plot input
        axes(handles.plot_input);
        if get(handles.checkbox_input,'Value') == 0 % 0 => time / 1 => frequency
            plot(x,input);
            xlabel('t (s)');
        else
            stem(f,input_fft);
            xlabel('f (Hz)');
        end

        % plot window function
        axes(handles.plot_function);
        if get(handles.checkbox_window,'Value') == 0 % 0 => time / 1 => frequency
            plot(x,window);
            xlabel('t (s)');
        else
            stem(f,window_fft);
            xlabel('f (Hz)');
        end

        % plot output
        axes(handles.plot_output);
        if get(handles.checkbox_output,'Value') == 0 % 0 => time / 1 => frequency
            plot(x,real(output));
            xlabel('t (s)');
        else
            stem(f,output_fft);
            xlabel('f (Hz)');
        end 
    end
end


% ------------------------------
% Buttons
% ------------------------------
function button_select_input_Callback(hObject, eventdata, handles)
    global xls_in;
    [FileName,PathName] = uigetfile('*.xlsx','Excel-files (*.xlsx)','Select the Excel code file');
    filename = strcat(PathName,FileName);
    % input = uiimport(filename);
    xls_in = xlsread(filename);
    update(handles);
end
function button_save_Callback(hObject, eventdata, handles)
    global output;
    outputFile = get(handles.edit_output, 'String');
    csvwrite(outputFile,output);
end

% ------------------------------
% Popupmenu
% ------------------------------
function popupmenu_Callback(hObject, eventdata, handles)
    %contents = cellstr(get(handles.popupmenu,'String'));
    %popChoice = contents(get(handles.popupmenu,'Value'));
    %if (strcmp(popChoice,'Boxcar')) ...
    update(handles);
end

% ------------------------------
% Textbox
% ------------------------------
function edit_low_Callback(hObject, eventdata, handles)
    update(handles);
end
function edit_cutoff_Callback(hObject, eventdata, handles)
    update(handles);
end
function edit_column_Callback(hObject, eventdata, handles)
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
function popupmenu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function edit_output_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function edit_cutoff_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function edit_column_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
