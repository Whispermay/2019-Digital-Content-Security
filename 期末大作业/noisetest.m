clc
clear
close all
im=imread('');
figure(1),subplot(1,3,1),imshow(im),title('原始图像')
imNois1 = imnoise(im,'gaussian',0,0.005);
figure(1),subplot(1,3,2),imshow(imNois1),title('高斯噪声干扰')
imNois2 = imnoise(im,'salt & pepper',0.1);
figure(1),subplot(1,3,3),imshow(imNois2),title('椒盐噪声干扰')

%% 均值滤波后
% % figure(11),subplot(2,3,1),imshow(imNois1),title('高斯噪声干扰')
% % imNois11 = imfilter(imNois1,ones(3,3)/9);
% % figure(11),subplot(2,3,2),imshow(imNois11),title('3x3 均值滤波')
% % imNois11 = imfilter(imNois1,ones(5,5)/25);
% % figure(11),subplot(2,3,3),imshow(imNois11),title('5x5 均值滤波')
% % imNois11 = imfilter(imNois1,ones(7,7)/49);
% % figure(11),subplot(2,3,4),imshow(imNois11),title('7x7 均值滤波')
% % imNois11 = imfilter(imNois1,ones(9,9)/81);
% % figure(11),subplot(2,3,5),imshow(imNois11),title('9x9 均值滤波')
% % H=[1 2 1;2 4 2;1 2 1]/16;
% % imNois11 = imfilter(imNois1,H);
% % figure(11),subplot(2,3,6),imshow(imNois11),title('3x3 加权均值滤波')
% 
% figure(11),subplot(1,3,1),imshow(imNois1),title('高斯噪声干扰')
% imNois11 = imfilter(imNois1,ones(3,3)/9);
% figure(11),subplot(1,3,2),imshow(imNois11),title('3x3 均值滤波')
% imNois11 = imfilter(imNois1,ones(5,5)/25);
% figure(11),subplot(1,3,3),imshow(imNois11),title('5x5 均值滤波')
% imNois11 = imfilter(imNois1,ones(7,7)/49);
% figure(12),subplot(1,3,1),imshow(imNois11),title('7x7 均值滤波')
% imNois11 = imfilter(imNois1,ones(9,9)/81);
% figure(12),subplot(1,3,2),imshow(imNois11),title('9x9 均值滤波')
% H=[1 2 1;2 4 2;1 2 1]/16;
% imNois11 = imfilter(imNois1,H);
% figure(12),subplot(1,3,3),imshow(imNois11),title('3x3 加权均值滤波')

%% 中值滤波后
figure(22),subplot(1,3,1),imshow(imNois2),title('椒盐噪声干扰')
imNois22 = uint8(filter_median(imNois2,1));%[im_med] = filter_median(im,radius)
figure(22),subplot(1,3,2),imshow(imNois22),title('3x3 中值滤波')
imNois22 = uint8(filter_median(imNois2,2));%[im_med] = filter_median(im,radius)
figure(22),subplot(1,3,3),imshow(imNois22),title('5x5 中值滤波')

imNois22 = uint8(filter_median(imNois2,3));%[im_med] = filter_median(im,radius)
figure(23),subplot(1,3,1),imshow(imNois22),title('7x7 中值滤波')
imNois22 = imfilter(imNois2,ones(3,3)/9);
figure(23),subplot(1,3,2),imshow(imNois22),title('3x3 均值滤波')
imNois22 = imfilter(imNois2,ones(5,5)/25);
figure(23),subplot(1,3,3),imshow(imNois22),title('5x5 均值滤波')