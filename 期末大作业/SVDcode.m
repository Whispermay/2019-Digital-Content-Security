I=imread('9.bmp'); %����ԭͼ

II=im2double(I);  %ת��Ϊ[0,1)double��  %IIΪԭͼ��
[m,n]=size(II);  %ԭͼ���С
af=0.1;  %Ƕ��ǿ��
[U,S,V]=svd(II);  %��������ֵ�ֽ� �õ�һ������Ч��С���ķֽ⣬ֻ���������U��ǰn�У�����S�Ĵ�СΪn��n��
M=imread('Ƕ��ˮӡ.bmp');  %����ˮӡͼ��
W=im2double(M);  %ת��Ϊ[0,1)double��
[m1,n1]=size(W);
WW=zeros(m,n);
for i=1:m1
    for j=1:n1
            WW(i,j)=W(i,j);
    end
end
S1=S+af*WW;%����ˮӡ��ĶԽ���
[U1,SS,V1]=svd(S1); %�ٽ�������ֵ�ֽ�
CWI=U*SS*V';  %Ƕ��ˮӡ��ͼ��
subplot(2,2,1); imshow(II); title('ԭͼ��');  %��ʾԭͼ��
subplot(2,2,2);  imshow(CWI); title('Ƕ����ˮӡ��ͼ��');%��ʾǶ����ˮӡ��ͼ��
imwrite(CWI,'����ˮӡͼ.bmp');
%��ȡˮӡ
NCWI=zeros(size(CWI));
AA=randn(size(CWI));
NCWI=CWI+AA*0.01;  %�Ժ�ˮӡ��ͼ�������
[UU,S2,VV]=svd(NCWI); %�Ժ���ˮӡ��ͼ���������ֵ�ֽ�
SN=U1*S2*V1';  %�����м����
WN=(SN-S)/af;  %��ȡˮӡ
WNN=zeros(m1,n1);
for i=1:m1
    for j=1:n1
        WNN(i,j)=WN(i,j);
    end
end
subplot(2,2,3);imshow(W); title('ԭʼ��ˮӡ');
subplot(2,2,4);imshow(WNN); title('��ȡ��ˮӡ');
NC=corrcoef(W,WNN);
nc=NC(1,2);
fprintf('ԭʼˮӡ����ȡˮӡ�����ϵ��:%5.4f\n',nc);
