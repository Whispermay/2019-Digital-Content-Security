clc;
clear; 
close all;

I=imread('lena.bmp'); %读入原图
II=im2double(I);  %转化为[0,1)double型  %II为原图像
[m,n]=size(II);  %原图像大小
af=0.1;  %嵌入强度
[U,S,V]=svd(II);  %进行奇异值分解
M=imread('watermark.bmp');  %读入水印图像
W=im2double(M);  %转化为[0,1)double型
[m1,n1]=size(W);
WW=zeros(m,n);
%进行水印信息的初始化及赋值
for i=1:m1
    for j=1:n1
            WW(i,j)=W(i,j);
    end
end
S1=S+af*WW;%加入水印后的对角阵
[U1,SS,V1]=svd(S1); %再进行奇异值分解

dlmwrite('U.txt', U1, 'delimiter', '\t','precision', 20,'newline', 'pc')%以20的精度存入txt中
dlmwrite('V.txt', V1, 'delimiter', '\t','precision', 20,'newline', 'pc')
CWI=U*SS*V';  %嵌入水印后图像
imwrite(CWI,'lena_watermark.bmp');
%fprintf('原始水印和提取水印的相关系数:%5.4f\n',nc);
subplot(1,2,1); imshow(II); title('原图像');  %显示原图像
subplot(1,2,2);  imshow(CWI); title('嵌入了水印后图像');%显示嵌入了水印后图像
