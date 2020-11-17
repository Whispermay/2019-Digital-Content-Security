%提取水印
%在水印的检测过程中，如果给出矩阵U1、S、V1 和可能损坏CWI的水印图像，那么通过简单的逆过程就可以提取出可能已经失真的水印 ，即：
%1) 可能损坏的水印图像进行奇异值分解
%2) 计算中间矩阵
%3) 获得水印图像

clc;
clear; 
close all;
U1=importdata('U.txt');%读入U1，V1
V1=importdata('V.txt');
I=imread('lena.bmp'); %读入原图
II=im2double(I);  %转化为[0,1)double型  %II为原图像
[m,n]=size(II);  %原图像大小
[U,S,V]=svd(II);  %对原图进行奇异值分解
CWI=imread('lena_watermark.bmp');
CWI=im2double(CWI);
[UU,S1,VV]=svd(CWI); %对含有水印的图像进行奇异值分解
af=0.1; %强度
%NCWI=zeros(size(CWI));

SN=U1*S1*V1';  %计算中间矩阵

WN=(SN-S)/af;  %提取水印

M=imread('watermark.bmp');  %读入水印图像
W=im2double(M);  %转化为[0,1)double型
[m1,n1]=size(W);
WNN=zeros(m1,n1);
for i=1:m1
    for j=1:n1
        WNN(i,j)=WN(i,j);
    end
end
subplot(2,2,3);imshow(W); title('原始的水印');
subplot(2,2,4);imshow(WNN); title('提取的水印');
NC=corrcoef(W,WNN);
nc=NC(1,2);
fprintf('原始水印和提取水印的相关系数:%5.4f\n',nc);
subplot(2,2,1); imshow(II); title('原图像');  %显示原图像
subplot(2,2,2);  imshow(CWI); title('嵌入了水印后图像');%显示嵌入了水印后图像
psnr=imPSNR(II,CWI);
disp("该图片的PSNR值为:");
disp(psnr);



%%高斯噪声干扰%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PSNR_GAOSI=zeros(50);
x=zeros(50);
Relate_GAOSI=zeros(50);
for i=1:50
a=i/100;
imNois1 = imnoise(CWI,'gaussian',0,a);%不同的均值
imNois1=im2double(imNois1);
%figure(1),subplot(1,3,2),imshow(imNois1),title('高斯噪声干扰');
%imwrite(imNois1,'高斯噪声干扰.bmp');
PSNR_GAOSI(i)=imPSNR(imNois1,II);
x(i)=i;
[Ui,Si,Vi]=svd(imNois1); %对含有水印的图像进行奇异值分解
af=0.1; %强度
%NCWI=zeros(size(CWI));
AA=randn(size(imNois1));
SN=U1*Si*V1';  %计算中间矩阵
WN_g=(SN-S)/af;  %提取水印
WNN_g=zeros(m1,n1);
for k=1:m1
    for j=1:n1
        WNN_g(k,j)=WN_g(k,j);
    end
end
NC=corrcoef(W,WNN_g);
Relate_GAOSI(i)=NC(1,2);%计算相关系数

end

figure;
subplot(1,2,1); plot(x,PSNR_GAOSI); title('高斯噪声与PSNR的关系');xlabel('高斯干扰程度');ylabel('PSNR');  %显示原图像
subplot(1,2,2);  plot(x,Relate_GAOSI); title('高斯噪声与相关系数的关系');xlabel('高斯干扰程度');ylabel('相关系数');%显示嵌入了水印后图像
%%%%%%高斯干扰测试%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%均值滤波%%%%%%%%%%%%%%%%%%%%%%%
PSNR_LB=zeros(50);
x=zeros(50);
Relate_LB=zeros(50);
for i=1:50
a=i*i;
imNois11 = imfilter(CWI,ones(i,i)/a);
imNois11=im2double(imNois11);
PSNR_LB(i)=imPSNR(imNois11,II);
x(i)=i;
[Uii,Sii,Vii]=svd(imNois11); %对含有水印的图像进行奇异值分解
af=0.1; %强度
%NCWI=zeros(size(CWI));
AA=randn(size(imNois11));
SNi=U1*Sii*V1';  %计算中间矩阵
WN_l=(SNi-S)/af;  %提取水印
WNN_l=zeros(m1,n1);
for k=1:m1
    for j=1:n1
        WNN_l(k,j)=WN_l(k,j);
    end
end
NC=corrcoef(W,WNN_l);
Relate_LB(i)=NC(1,2);%计算相关系数

end

figure;
subplot(1,2,1); plot(x,PSNR_LB); title('均值滤波与PSNR的关系');xlabel('均值滤波程度');ylabel('PSNR');  %显示原图像
subplot(1,2,2);  plot(x,Relate_LB); title('均值滤波与相关系数的关系');xlabel('均值滤波程度');ylabel('相关系数');%显示嵌入了水印后图像
%%%%%均值滤波










%%%%%%添加椒盐噪声
PSNR_Z=zeros(50);
x=zeros(50);
Relate_ZLB=zeros(50);
for i=1:50
  nu=i/100;
imNois22 = imnoise(CWI,'salt',nu);
imNois22=im2double(imNois22);
PSNR_Z(i)=imPSNR(imNois22,II);
x(i)=i;
[Uiii,Siii,Viii]=svd(imNois22); %对含有水印的图像进行奇异值分解
af=0.1; %强度
%NCWI=zeros(size(CWI));
AA=randn(size(imNois22));
SNi=U1*Siii*V1';  %计算中间矩阵
WN_z=(SNi-S)/af;  %提取水印
WNN_z=zeros(m1,n1);
for k=1:m1
    for j=1:n1
        WNN_z(k,j)=WN_z(k,j);
    end
end
NC=corrcoef(W,WNN_z);
Relate_ZLB(i)=NC(1,2);%计算相关系数
    
end

figure;
subplot(1,2,1); plot(x,PSNR_Z); title('椒盐噪声与PSNR的关系');xlabel('椒盐噪声程度');ylabel('PSNR');  %显示原图像
subplot(1,2,2);  plot(x,Relate_ZLB); title('椒盐噪声与相关系数的关系');xlabel('椒盐噪声程度');ylabel('相关系数');%显示嵌入了水印后图像

%%%%椒盐噪声%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



















%%%随机噪声%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AA=randn(size(CWI));

% [UU,S2,VV]=svd(NCWI); %对含有水印的图像进行奇异值分解
% SN=U2*S2*V2';  %计算中间矩阵
PSNR_S=zeros(50);
x=zeros(50);
Relate_S=zeros(50);
for i=1:50

num=i/10;
imNois4 =CWI+AA*num;
imNois4=im2double(imNois4);
PSNR_S(i)=imPSNR(imNois4,II);
x(i)=i;
[Uiii4,Siii4,Viii4]=svd(imNois4); %对含有水印的图像进行奇异值分解
af=0.1; %强度
%NCWI=zeros(size(CWI));
AA=randn(size(imNois4));
SNi=U1*Siii4*V1';  %计算中间矩阵
WN_S=(SNi-S)/af;  %提取水印
WNN_S=zeros(m1,n1);
for k=1:m1
    for j=1:n1
        WNN_S(k,j)=WN_S(k,j);
    end
end
NC=corrcoef(W,WNN_S);
Relate_S(i)=NC(1,2);%计算相关系数
    
end

figure;
subplot(1,2,1); plot(x,PSNR_S); title('随机噪声程度与PSNR的关系');xlabel('随机噪声程度');ylabel('PSNR');  %显示原图像
subplot(1,2,2);  plot(x,Relate_S); title('随机噪声程度与相关系数的关系');xlabel('随机噪声程度');ylabel('相关系数');%显示嵌入了水印后图像
%%%%%%%%%%%%%随机噪声%%%%%%%%%%%%%%%%%






%%%计算PSNR值
function [ PSNR ] = imPSNR( J , I )
%   I is a image with high quality
%   J is a image with noise
%   the function will return the PSNR of the noise image
width = size(I,2);
heigh = size(I,1);
K = (I-J).*(I-J);
PSNR = sum(sum(K,1));%每列进行求和
PSNR = PSNR / (width * heigh);
PSNR=10*log10(255*255/PSNR);
end