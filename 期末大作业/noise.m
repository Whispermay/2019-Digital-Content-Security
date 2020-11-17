clc
clear
close all
im=imread('lena512.bmp');
figure(1),subplot(1,3,1),imshow(im),title('原始图像')
imNois1 = imnoise(im,'gaussian',0,0.005);
figure(1),subplot(1,3,2),imshow(imNois1),title('高斯噪声干扰')
imwrite(imNois1,'高斯噪声干扰.bmp');
imNois2 = imnoise(im,'salt & pepper',0.1);
figure(1),subplot(1,3,3),imshow(imNois2),title('椒盐噪声干扰')
imwrite(imNois1,'椒盐噪声干扰.bmp');
%均值滤波后
figure(11),subplot(2,3,1),imshow(imNois1),title('高斯噪声干扰')
imNois11 = imfilter(imNois1,ones(3,3)/9);
figure(11),subplot(2,3,2),imshow(imNois11),title('3x3 均值滤波')
imwrite(imNois11,'高斯噪声干扰3x3均值滤波.bmp');
imNois11 = imfilter(imNois1,ones(5,5)/25);
figure(11),subplot(2,3,3),imshow(imNois11),title('5x5 均值滤波')
imwrite(imNois11,'高斯噪声干扰5x5均值滤波.bmp');
imNois11 = imfilter(imNois1,ones(7,7)/49);
figure(11),subplot(2,3,4),imshow(imNois11),title('7x7 均值滤波')
imwrite(imNois11,'高斯噪声干扰7x7均值滤波.bmp');
imNois11 = imfilter(imNois1,ones(9,9)/81);
figure(11),subplot(2,3,5),imshow(imNois11),title('9x9 均值滤波')
imwrite(imNois11,'高斯噪声干扰9x9均值滤波.bmp');
H=[1 2 1;2 4 2;1 2 1]/16;
imNois11 = imfilter(imNois1,H);
figure(11),subplot(2,3,6),imshow(imNois11),title('3x3 加权均值滤波')
imwrite(imNois11,'高斯噪声干扰3x3加权均值滤波.bmp');
% 中值滤波后
figure(22),subplot(2,3,1),imshow(imNois2),title('椒盐噪声干扰')
imNois22 = uint8(medfilt2(imNois2,[3 3]));
figure(22),subplot(2,3,2),imshow(imNois22),title('3x3 中值滤波')
imwrite(imNois22,'椒盐噪声干扰3x3均值滤波.bmp');
imNois22 = uint8(medfilt2(imNois2,[5 5]));
figure(22),subplot(2,3,3),imshow(imNois22),title('5x5 中值滤波')
imwrite(imNois22,'椒盐噪声干扰5x5中值滤波.bmp');
imNois22 = uint8(medfilt2(imNois2,[7 7]));
figure(22),subplot(2,3,4),imshow(imNois22),title('7x7 中值滤波')
imwrite(imNois22,'椒盐噪声干扰7x7中值滤波.bmp');
imNois22 = imfilter(imNois2,ones(3,3)/9);
figure(22),subplot(2,3,5),imshow(imNois22),title('3x3 均值滤波')
imwrite(imNois22,'椒盐噪声干扰3x3均值滤波.bmp');
imNois22 = imfilter(imNois2,ones(5,5)/25);
figure(22),subplot(2,3,6),imshow(imNois22),title('5x5 均值滤波')
imwrite(imNois22,'椒盐噪声干扰5x5均值滤波.bmp');