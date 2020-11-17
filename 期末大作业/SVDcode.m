I=imread('9.bmp'); %读入原图

II=im2double(I);  %转化为[0,1)double型  %II为原图像
[m,n]=size(II);  %原图像大小
af=0.1;  %嵌入强度
[U,S,V]=svd(II);  %进行奇异值分解 得到一个“有效大小”的分解，只计算出矩阵U的前n列，矩阵S的大小为n×n。
M=imread('嵌入水印.bmp');  %读入水印图像
W=im2double(M);  %转化为[0,1)double型
[m1,n1]=size(W);
WW=zeros(m,n);
for i=1:m1
    for j=1:n1
            WW(i,j)=W(i,j);
    end
end
S1=S+af*WW;%加入水印后的对角阵
[U1,SS,V1]=svd(S1); %再进行奇异值分解
CWI=U*SS*V';  %嵌入水印后图像
subplot(2,2,1); imshow(II); title('原图像');  %显示原图像
subplot(2,2,2);  imshow(CWI); title('嵌入了水印后图像');%显示嵌入了水印后图像
imwrite(CWI,'生成水印图.bmp');
%提取水印
NCWI=zeros(size(CWI));
AA=randn(size(CWI));
NCWI=CWI+AA*0.01;  %对含水印的图像加噪声
[UU,S2,VV]=svd(NCWI); %对含有水印的图像进行奇异值分解
SN=U1*S2*V1';  %计算中间矩阵
WN=(SN-S)/af;  %提取水印
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
