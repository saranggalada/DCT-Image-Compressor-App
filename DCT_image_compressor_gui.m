classdef dct_img_compressor_exported < matlab.apps.AppBase
    
   % Properties that correspond to app components
   properties (Access = public)
       UIFigure                      matlab.ui.Figure
       CompressionFactorSlider       matlab.ui.control.Slider
       CompressionFactorSliderLabel  matlab.ui.control.Label
       CompressButton                matlab.ui.control.Button
       DownloadImageButton           matlab.ui.control.Button
       UploadImageButton             matlab.ui.control.Button
       UIAxes                        matlab.ui.control.UIAxes
       UIAxes2                       matlab.ui.control.UIAxes
       VariableTextLabel             matlab.ui.control.Label
   end

   % Callbacks that handle component events
   methods (Access = private)
       % Button pushed function: UploadImageButton
       function UploadImageButtonPushed(app, event)

           % Allow user to select an image
           [file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'}, 'Select an Image');
           if isequal(file, 0)
               % User canceled the operation
               return;
           end

           % Load the selected image
           img = imread(fullfile(path, file));
          
           % If image is RGB, convert to grayscale
           if size(img, 3) == 3
               img = rgb2gray(img);
           end
         
           % Convert image to double
           img = im2double(img);

           % Display the original image
           imshow(img, 'Parent', app.UIAxes);
       end

       % Value changed function: CompressionFactorSlider
       function CompressionFactorSliderValueChanged(app, event)
           value = app.CompressionFactorSlider.Value;
           setappdata(0,'value', value);
       end

       % Button pushed function: DownloadImageButton
       function DownloadImageButtonPushed(app, event)
           % Allow user to save the compressed image
           [file, path] = uiputfile({'*.jpg', 'JPEG Image (*.jpg)'}, 'Save Compressed Image');
           if isequal(file, 0)
               % User canceled the operation
               return;
           end
           % Get the compressed image from the UIAxes
           compressed_img = getimage(app.UIAxes);
           % Save the compressed image
           imwrite(compressed_img, fullfile(path, file));
       end

       % Button pushed function: CompressButton
       function CompressButtonPushed(app, event)
            image = getimage(app.UIAxes);
                
            % If image is RGB, convert to grayscale
            if size(image, 3) == 3
                image = rgb2gray(image);
                image = im2double(image);
            end
                    
            % Generate the first DCT kernel (C1)
            [M,N] = size(image);
            i = (0:M-1);
            j = (0:M-1);
            C0 = cos(pi*(2*i'+1)*j/(2*M));               
            C1 = C0 * sqrt(diag([1, 2*ones(1,M-1)])/M);
                    
            % Generate the second DCT kernel (C2)
            k = (0:N-1);
            l = (0:N-1);
            C0 = cos(pi*(2*k'+1)*l/(2*N));
            C2 = C0 * sqrt(diag([1, 2*ones(1,N-1)])/N);
                    
            % Apply DCT
            img_dct = C1*image*C2';
                                
            % Apply Quantization using quantization factor Q
            Q = getappdata(0, 'value');
            img_dct = Q*(round(img_dct/Q));

            % Apply Inverse DCT to the quantized image
            compressed_img = C1'*img_dct*C2;
                    
            % Display the compressed image
            imshow(compressed_img, 'Parent', app.UIAxes2);

            % Calculate the compression ratio
            compression_ratio = numel(image)/nnz(img_dct);
                    
            % Display the variable
            app.VariableTextLabel.Text = ['CR: ', num2str(compression_ratio)];
       end
   end


   % Component initialization
   methods (Access = private)
       % Create UIFigure and components
       function createComponents(app)

           % Create UIFigure and hide until all components are created
           app.UIFigure = uifigure('Visible', 'off');
           app.UIFigure.Position = [100 100 640 480];
           app.UIFigure.Name = 'DCT Image Compressor';

           % Create UIAxes2
           app.UIAxes2 = uiaxes(app.UIFigure);
           title(app.UIAxes2, 'Compressed Image')
           app.UIAxes2.XTick = [];
           app.UIAxes2.YTick = [];
           app.UIAxes2.Position = [350 161 283 267];

           % Create UIAxes
           app.UIAxes = uiaxes(app.UIFigure);
           title(app.UIAxes, 'Original Image')
           app.UIAxes.XTick = [];
           app.UIAxes.YTick = [];
           app.UIAxes.Position = [9 161 283 267];

           % Create UploadImageButton
           app.UploadImageButton = uibutton(app.UIFigure, 'push');
           app.UploadImageButton.ButtonPushedFcn = createCallbackFcn(app, @UploadImageButtonPushed, true);
           app.UploadImageButton.BusyAction = 'cancel';
           app.UploadImageButton.Position = [97 104 100 22];
           app.UploadImageButton.Text = 'Upload Image';

           % Create DownloadImageButton
           app.DownloadImageButton = uibutton(app.UIFigure, 'push');
           app.DownloadImageButton.ButtonPushedFcn = createCallbackFcn(app, @DownloadImageButtonPushed, true);
           app.DownloadImageButton.Position = [437 104 104 22];
           app.DownloadImageButton.Text = 'Download Image';

           % Create CompressButton
           app.CompressButton = uibutton(app.UIFigure, 'push');
           app.CompressButton.ButtonPushedFcn = createCallbackFcn(app, @CompressButtonPushed, true);
           app.CompressButton.Position = [272 40 100 22];
           app.CompressButton.Text = 'Compress';

           % Create CompressionFactorSliderLabel
           app.CompressionFactorSliderLabel = uilabel(app.UIFigure);
           app.CompressionFactorSliderLabel.HorizontalAlignment = 'right';
           app.CompressionFactorSliderLabel.Position = [265 140 113 22];
           app.CompressionFactorSliderLabel.Text = 'Quantization Factor';

           % Create CompressionFactorSlider
           app.CompressionFactorSlider = uislider(app.UIFigure);
           app.CompressionFactorSlider.Limits = [0 1];
           app.CompressionFactorSlider.MajorTicks = [0 0.5 1];
           app.CompressionFactorSlider.ValueChangedFcn = createCallbackFcn(app, @CompressionFactorSliderValueChanged, true);
           app.CompressionFactorSlider.Position = [285 120 74 3];
           app.CompressionFactorSlider.Value = 0.001;

           % Create VariableTextLabel
           app.VariableTextLabel = uilabel(app.UIFigure);
           app.VariableTextLabel.HorizontalAlignment = 'left';
           app.VariableTextLabel.Position = [437 40 200 22];
           app.VariableTextLabel.Text = 'Compression Ratio: ';

           % Show the figure after all components are created
           app.UIFigure.Visible = 'on';
       end
   end


   % App creation and deletion
   methods (Access = public)

       % Construct app
       function app = dct_img_compressor_exported
           % Create UIFigure and components
           createComponents(app)
           % Register the app with App Designer
           registerApp(app, app.UIFigure)
           if nargout == 0
               clear app
           end
       end

       % Code that executes before app deletion
       function delete(app)
           % Delete UIFigure when app is deleted
           delete(app.UIFigure)
       end

   end
end
