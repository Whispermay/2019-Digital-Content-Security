close all;
clear all;
clc;
img=imread('lena512.bmp');
[h,w]=size(img);
arr1=1:100;
arr2=1:100;
B=8;                %编码一个像素用多少二进制位
MAX=2^B-1;          %图像有多少灰度级

%--------根据质量因子的大小批量压缩--------%
for Q=1:100
    filename=['E:\赵婧宇大三\数字内容安全\数字内容安全实验一\压缩图\Q',num2str(Q),'.jpeg'];
    %imwrite(img,filename,'jpeg','quality',Q);  %保存文件
    imgn=imread(filename);
    MES=sum(sum((img-imgn).^2))/(h*w);     %均方差
    PSNR=20*log10(MAX/sqrt(MES));           %峰值信噪比
   arr1(Q)=Q;
   arr2(Q)=PSNR;
end
 plot(arr1,arr2,'r');%生成曲线
 ylabel('峰值信噪比PSNR','FontSize',14);
 xlabel('质量因子Q','FontSize',14);

 figure('name','原图灰度直方图'),imhist(img);
 I=imread('压缩图\Q1.jpeg');
 figure('name','压缩图像灰度直方图质量最低'),imhist(I)
 G=imread('压缩图\Q100.jpeg');
 figure('name','压缩图像灰度直方图质量最高'),imhist(G)