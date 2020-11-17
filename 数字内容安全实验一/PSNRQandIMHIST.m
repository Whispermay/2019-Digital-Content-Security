close all;
clear all;
clc;
img=imread('lena512.bmp');
[h,w]=size(img);
arr1=1:100;
arr2=1:100;
B=8;                %����һ�������ö��ٶ�����λ
MAX=2^B-1;          %ͼ���ж��ٻҶȼ�

%--------�����������ӵĴ�С����ѹ��--------%
for Q=1:100
    filename=['E:\��������\�������ݰ�ȫ\�������ݰ�ȫʵ��һ\ѹ��ͼ\Q',num2str(Q),'.jpeg'];
    %imwrite(img,filename,'jpeg','quality',Q);  %�����ļ�
    imgn=imread(filename);
    MES=sum(sum((img-imgn).^2))/(h*w);     %������
    PSNR=20*log10(MAX/sqrt(MES));           %��ֵ�����
   arr1(Q)=Q;
   arr2(Q)=PSNR;
end
 plot(arr1,arr2,'r');%��������
 ylabel('��ֵ�����PSNR','FontSize',14);
 xlabel('��������Q','FontSize',14);

 figure('name','ԭͼ�Ҷ�ֱ��ͼ'),imhist(img);
 I=imread('ѹ��ͼ\Q1.jpeg');
 figure('name','ѹ��ͼ��Ҷ�ֱ��ͼ�������'),imhist(I)
 G=imread('ѹ��ͼ\Q100.jpeg');
 figure('name','ѹ��ͼ��Ҷ�ֱ��ͼ�������'),imhist(G)