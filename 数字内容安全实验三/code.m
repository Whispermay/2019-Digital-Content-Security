clc
clear all;
close all;
cover = imread('lena512.jpeg');
[m,n]=size(cover);                      
blocksize = 8;         
DCT_quantizer = [ 16 , 11 , 10 , 16 , 24 , 40 , 51 , 61 %DCT������
	  12 , 12 , 14 , 19 , 26 , 58 , 60 , 55 
	  14 , 13 , 16 , 24 , 40 , 57 , 69 , 56
	  14 , 17 , 22 , 29 , 51 , 87 , 80 , 62
	  18 , 22 , 37 , 56 , 68 ,109 ,103 , 77
	  24 , 35 , 55 , 64 , 81 ,104 ,113 , 92
	  49 , 64 , 78 , 87 , 103 ,121,120 ,101
	  72 , 92 , 95 , 98 ,112 ,100 ,103 ,99 ];
%for Q=1:10
watermark=imread('Ƕ��ˮӡ.bmp') ;  %��ҪǶ���ͼ��

wlength = length(watermark);
%figure(1),subplot(2,1,1),imshow(cover),title('ԭͼ');
watermark = uint8(watermark);
coverzero = cover;
wr=0;
pad_n = (1 - (n/blocksize - floor(n/blocksize))) * blocksize; %ȡ����С������,�ֿ�ȡ��
if pad_n == blocksize, pad_n = 0; end
pad_m = (1 - (m/blocksize - floor(m/blocksize))) * blocksize;
if pad_m == blocksize, pad_m = 0; end
for extra_n = 1:pad_n
  coverzero(1:m, n+extra_n) = coverzero(1:m, n);
end %ԭͼ��Ϊ8�ı���ʱ����Ŀ�ȫ��n���
n = n + pad_n;    
for extra_m = 1:pad_m
  coverzero(m+extra_m, 1:n) = coverzero(m, 1:n);
end
m =m + pad_m;    
for m1 = 1: blocksize: m %����Ĵ�Сѭ��
  for n1 = 1: blocksize: n 
      
      DCT_num = coverzero(m1: m1 + blocksize-1, n1: n1 + blocksize-1); %8*8DCT����
      DCT_num = dct2(DCT_num); %��ά����DCT�任
    DCT_num = round(DCT_num ./ (DCT_quantizer(1:blocksize, 1:blocksize)));%����������ȡ���������
      
    jpeg_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1) = DCT_num;
  end
end


bitlength=1;
for i=1:wlength
    for j=1:wlength
        for imbed=1:8
              watermarkshift=bitshift(watermark(i,j),8-imbed);

              singlebit=uint8(watermarkshift);
              singlebit=bitshift(singlebit,-7);

              watermarkbit(i,j)=singlebit; %�õ���Ϣ�Ķ���������
              bitlength=bitlength+1;


         end
    end
end
i=1;
    for m1=1:m
        for n1=1:n
           x=jpeg_img(m1,n1);
           if (x~=0) && (x~=1)  %���DCTϵ������0��1
               r=mod(x,2); %���x��LSB
               if r==0 % ���LSBΪ0��xΪ2k
                   if watermarkbit(m1,n1)==1 %���ˮӡ�Ķ���������Ϊ1
                       x=x+1;
                   end
               else
                   if watermarkbit(m1,n1)==0
                       x=x-1; 
                   end
               end
               i=i+1;
           end
        jpeg_img(m1,n1)=x; %��x��ֵ����ԭDCTϵ��ֵ
        
        if i==bitlength
            break;
        end
          
        end
        
        if i==bitlength
            break;
        end
        
    end


% ������ͼ��
new_img = coverzero - coverzero;  % ����
for m1 = 1: blocksize: m
  for n1 = 1: blocksize: n

      IDCT_num = jpeg_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1);
      IDCT_num = round(idct2(IDCT_num .* (DCT_quantizer(1:blocksize, 1:blocksize))));
      new_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1) = IDCT_num;
  end
end


m = m - pad_m; %ȥ�����Ŀ�
n = n - pad_n;
new_img = new_img(1:m, 1:n);
imshow(new_img);

%filename2=['ˮӡͼ1/',num2str(Q),'.jpeg'];
%imwrite(new_img,filename2,'jpeg','quality',100); %����Ƕ��ˮӡ��ͼ

pad_n = (1 - (n/blocksize - floor(n/blocksize))) * blocksize;
if pad_n == blocksize, pad_n = 0; end
pad_m = (1 - (m/blocksize - floor(m/blocksize))) * blocksize;
if pad_m == blocksize, pad_m = 0; end

for extra_cols = 1:pad_n
  new_img(1:m,n+extra_n) = new_img(1:m,n);
end

n = n + pad_n;    

for extra_m = 1:pad_m
  new_img(m+extra_m, 1:n) = new_img(m, 1:n);
end
m = m + pad_m;    

jpeg_img=0; %����
%��ˮӡͼDCT����
for m1 = 1: blocksize: m
  for n1 = 1: blocksize: n
      DCT_num = new_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1);%8*8�ֿ�
      DCT_num = dct2(DCT_num);%DCT
      DCT_num = round (DCT_num ./ (DCT_quantizer(1:blocksize, 1:blocksize) ));%����ȡ��
     
    jpeg_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1) = DCT_num; %DCT����
   
  end
end
%figure('name','ˮӡͼDCT����ֱ��ͼ'),imhist(jpeg_img);

%��ȡˮӡ
stego=jpeg_img; %ˮӡͼ�������DCTϵ��
stegoindex=1;
imbed=1;
watermarkchar=0;
watermarkindex=1;

for m1=1:m
    for n1=1:n
    stegowatermark = stego(m1,n1); %DCTϵ��
    if (stegowatermark~=0)&&(stegowatermark~=1) %���DCTϵ����Ϊ0��1
      
        r=mod(stegowatermark,2); %DCTϵ����LSB
        if (r==0)     
            singlebit=0;
        else singlebit=1;
        end
        
        singlebit=uint8(singlebit);  
        
        singlebit=bitshift(singlebit,(imbed-1)); %��λ����ˮӡ�Ķ��������루ʮ���Ʊ�ʾ��
        watermarkchar=uint8(watermarkchar+singlebit);%��ʽת��
        watermark1(m1,n1)=watermarkchar;%�洢�����ÿ���ַ���ASCII��
        
        stegoindex = stegoindex+1;
        imbed=imbed+1;
        if (imbed==9) 
            watermarkindex=watermarkindex+1;
            watermark1(m1,n1)=watermarkchar;
            
            watermarkchar=0;
            imbed=1;
        end
        
    end
    if (stegoindex==wlength*8)
        break;
    end
    end
    if (stegoindex==wlength*8)
        break;
    end
end


watermark1=uint8(watermark1);  %��ASCII��ת��Ϊ�ַ���

%disp(messagestring);%������ص���Ϣ
%end
 
 
%  %��ˮӡͼ��ѹ�����ٽ���ˮӡ��ȡ
% clc
% clear all;
% close all;
% img = imread('ˮӡͼ1/5.jpeg');
% DCT_quantizer = [ 16 , 11 , 10 , 16 , 24 , 40 , 51 , 61 %DCT������
% 	  12 , 12 , 14 , 19 , 26 , 58 , 60 , 55 
% 	  14 , 13 , 16 , 24 , 40 , 57 , 69 , 56
% 	  14 , 17 , 22 , 29 , 51 , 87 , 80 , 62
% 	  18 , 22 , 37 , 56 , 68 ,109 ,103 , 77
% 	  24 , 35 , 55 , 64 , 81 ,104 ,113 , 92
% 	  49 , 64 , 78 , 87 , 103 ,121,120 ,101
% 	  72 , 92 , 95 , 98 ,112 ,100 ,103 ,99 ];
% 
% blocksize=8;
% watermark=fopen('ˮӡ�ļ�/5.txt','r');
% watermark=fgetl(watermark);
% wlength = length(watermark);
% 
% for Q=1:20:100
%     wr=0;
%     filename=['ˮӡͼѹ��/Q=',num2str(Q),'.jpeg'];
%     imwrite(img,filename,'jpeg','quality',Q);  %�����ļ�
%     cover=imread(filename); 
%     [m,n]=size(cover);
%     for m1 = 1: blocksize: m
%      for n1 = 1: blocksize: n                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
%       DCT_num = cover(m1: m1 + blocksize-1, n1: n1 + blocksize-1);%8*8�ֿ�
%       DCT_num = dct2(DCT_num);%DCT
%       DCT_num = round (DCT_num ./ (DCT_quantizer(1:blocksize, 1:blocksize)));%����ȡ��
%      
%      jpeg_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1) = DCT_num; %DCT����
%    
%      end
%     end
% stego=jpeg_img; %ˮӡͼ�������DCTϵ��
% stegoindex=1;
% imbed=1;
% watermarkchar=0;
% watermarkindex=1;
% for m1=1:m
%     for n1=1:n
%     stegowatermark = stego(m1,n1); %DCTϵ��
%     if (stegowatermark~=0)&&(stegowatermark~=1) %���DCTϵ����Ϊ0��1
%       
%         r=mod(stegowatermark,2); %DCTϵ����LSB
%         if (r==0)     
%             singlebit=0;
%         else singlebit=1;
%         end
%         
%         singlebit=uint8(singlebit);  
%         
%         singlebit=bitshift(singlebit,(imbed-1)); %��λ����ˮӡ�Ķ��������루ʮ���Ʊ�ʾ��
%         watermarkchar=uint8(watermarkchar+singlebit);%��ʽת��
%         watermark1(watermarkindex)=watermarkchar;%�洢�����ÿ���ַ���ASCII��
%         
%         stegoindex = stegoindex+1;
%         imbed=imbed+1;
%         if (imbed==9) 
%             watermarkindex=watermarkindex+1;
%             watermark1(watermarkindex-1)=watermarkchar;
%             
%             watermarkchar=0;
%             imbed=1;
%         end
%         
%     end
%     if (stegoindex==wlength*8)
%         break;
%     end
%     end
%     if (stegoindex==wlength*8)
%         break;
%     end
% end
% watermark1=char(watermark1);  %��ASCII��ת��Ϊ�ַ���
% if(isequal(watermark,watermark1)==0)
%  if(wlength~=length(watermark1))%������Ȳ����
%      for i=length(watermark1):wlength
%          watermark1(i)=0;%��2���
%      end
%      for i=1:wlength
%          if(watermark1(i)~=watermark(i))
%          wr=wr+1;
%          end
%      end
%  else %���������
%      for i=1:wlength
%          if(watermark1(i)~=watermark(i))
%          wr=wr+1;
%          end
%      end
%      
%  end
% p=wr/wlength;
% end
% disp('�����ʣ�'),disp(p);
% end
% 
% 
%   
%    
%  
%  
% 
