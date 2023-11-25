clc;
clear all;
close all;


function [C1,C2] = getkernels(image)
  [M,N] = size(image);
  i = (0:M-1);
  j = (0:M-1);
  C0 = cos(pi*(2*i'+1)*j/(2*M));                
  C1 = C0 * sqrt(diag([1, 2*ones(1,M-1)])/M);
  
  k = (0:N-1);
  l = (0:N-1);
  C0 = cos(pi*(2*k'+1)*l/(2*N));
  C2 = C0 * sqrt(diag([1, 2*ones(1,N-1)])/N);
endfunction


function dct_image = fdct2_scratch(image, C1, C2)
  dct_image = C1*image*C2';
endfunction


function idct_image = ifdct2_scratch(image, C1, C2)
  idct_image = C1'*image*C2;
endfunction


function compressed_img = compressImageDCT(img, compression_factor)
    % Convert the image to grayscale if it's in color
    if size(img, 3) == 3
        img = rgb2gray(img);
        img = im2double(img);
    endif
    
    % Calculate the DCT kernels
    [C1, C2] = getkernels(img);

    % Apply 2D DCT to the image
    img_dct = fdct2_scratch(img, C1, C2);

    % Set high-frequency coefficients to zero based on the compression factor
    #threshold = compression_factor * max(img_dct(:));
    threshold=0.1;
    
    % Find the number of coefficients to keep
    num_coeffs = round(threshold * numel(img_dct));

    % Sort the DCT coefficients in descending order of magnitude
    sorted_coeffs = sort(abs(img_dct(:)), 'descend');

    % Find the threshold value
    threshold_value = sorted_coeffs(num_coeffs);
    
    img_dct(abs(img_dct) < threshold_value) = 0;

    % Apply inverse 2D DCT to get the compressed image
    compressed_img = ifdct2_scratch(img_dct, C1, C2);
 


    % Set a threshold value for compression
    #threshold = 0.1;

    % Find the number of coefficients to keep
    #num_coeffs = round(threshold * numel(dct_img));

    % Sort the DCT coefficients in descending order of magnitude
    #sorted_coeffs = sort(abs(dct_img(:)), 'descend');

    % Find the threshold value
    #threshold_value = sorted_coeffs(num_coeffs);

    % Set the coefficients below the threshold to zero
    #dct_img(abs(dct_img) < threshold_value) = 0;

    % Apply inverse DCT to the compressed image
    #compressed_img = ifdct2_scratch(dct_img, C1, C2);
endfunction






% Read the image
img = imread('C:\Users\HP\Desktop\College\Sem 5\DSP\Project\monalisa.jpg');

% Convert the image to grayscale
gray_img = rgb2gray(img);
gray_img = im2double(gray_img);

% Calculate the DCT kernels
[C1, C2] = getkernels(gray_img);

% Apply DCT to the image
dct_img = fdct2_scratch(gray_img, C1, C2);

Q = input('Q: ');
dct_img = Q*(round(dct_img/Q));


#dct_img(abs(dct_img) < threshold_value) = 0;

% Apply inverse DCT to the compressed image
compressed_img = ifdct2_scratch(dct_img, C1, C2);

% Display the original and compressed images
figure;
subplot(1,2,1);
imshow(img);
title('Original Image');
subplot(1,2,2);
imshow(compressed_img);
title('Compressed Image');


# Calculate size of original image and compressed image in kilobytes
original_size = numel(gray_img);
compressed_size = nnz(dct_img);

# Calculate compression ratio
compression_ratio = original_size/compressed_size;

fprintf("Original size: %d\n", original_size);
fprintf("Compressed size: %d\n", compressed_size);
fprintf("Compression ratio: %d\n", compression_ratio);

