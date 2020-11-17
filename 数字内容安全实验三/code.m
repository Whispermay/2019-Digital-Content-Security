clc
clear all;
close all;
cover = imread('lena512.jpeg');
[m,n]=size(cover);                      
blocksize = 8;         
DCT_quantizer = [ 16 , 11 , 10 , 16 , 24 , 40 , 51 , 61 %DCT量化表
	  12 , 12 , 14 , 19 , 26 , 58 , 60 , 55 
	  14 , 13 , 16 , 24 , 40 , 57 , 69 , 56
	  14 , 17 , 22 , 29 , 51 , 87 , 80 , 62
	  18 , 22 , 37 , 56 , 68 ,109 ,103 , 77
	  24 , 35 , 55 , 64 , 81 ,104 ,113 , 92
	  49 , 64 , 78 , 87 , 103 ,121,120 ,101
	  72 , 92 , 95 , 98 ,112 ,100 ,103 ,99 ];
%for Q=1:10
watermark=imread('嵌入水印.bmp') ;  %打开要嵌入的图像

wlength = length(watermark);
%figure(1),subplot(2,1,1),imshow(cover),title('原图');
watermark = uint8(watermark);
coverzero = cover;
wr=0;
pad_n = (1 - (n/blocksize - floor(n/blocksize))) * blocksize; %取比它小的整数,分块取整
if pad_n == blocksize, pad_n = 0; end
pad_m = (1 - (m/blocksize - floor(m/blocksize))) * blocksize;
if pad_m == blocksize, pad_m = 0; end
for extra_n = 1:pad_n
  coverzero(1:m, n+extra_n) = coverzero(1:m, n);
end %原图像不为8的倍数时格外的宽，全用n填充
n = n + pad_n;    
for extra_m = 1:pad_m
  coverzero(m+extra_m, 1:n) = coverzero(m, 1:n);
end
m =m + pad_m;    
for m1 = 1: blocksize: m %按块的大小循环
  for n1 = 1: blocksize: n 
      
      DCT_num = coverzero(m1: m1 + blocksize-1, n1: n1 + blocksize-1); %8*8DCT矩阵
      DCT_num = dct2(DCT_num); %二维矩阵DCT变换
    DCT_num = round(DCT_num ./ (DCT_quantizer(1:blocksize, 1:blocksize)));%除以量化表并取最近的整数
      
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

              watermarkbit(i,j)=singlebit; %得到信息的二进制数码
              bitlength=bitlength+1;


         end
    end
end
i=1;
    for m1=1:m
        for n1=1:n
           x=jpeg_img(m1,n1);
           if (x~=0) && (x~=1)  %如果DCT系数不是0或1
               r=mod(x,2); %获得x的LSB
               if r==0 % 如果LSB为0，x为2k
                   if watermarkbit(m1,n1)==1 %如果水印的二进制数码为1
                       x=x+1;
                   end
               else
                   if watermarkbit(m1,n1)==0
                       x=x-1; 
                   end
               end
               i=i+1;
           end
        jpeg_img(m1,n1)=x; %用x的值代替原DCT系数值
        
        if i==bitlength
            break;
        end
          
        end
        
        if i==bitlength
            break;
        end
        
    end


% 生成新图像
new_img = coverzero - coverzero;  % 清零
for m1 = 1: blocksize: m
  for n1 = 1: blocksize: n

      IDCT_num = jpeg_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1);
      IDCT_num = round(idct2(IDCT_num .* (DCT_quantizer(1:blocksize, 1:blocksize))));
      new_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1) = IDCT_num;
  end
end


m = m - pad_m; %去掉补的块
n = n - pad_n;
new_img = new_img(1:m, 1:n);
imshow(new_img);

%filename2=['水印图1/',num2str(Q),'.jpeg'];
%imwrite(new_img,filename2,'jpeg','quality',100); %保存嵌入水印的图

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

jpeg_img=0; %清零
%新水印图DCT量化
for m1 = 1: blocksize: m
  for n1 = 1: blocksize: n
      DCT_num = new_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1);%8*8分块
      DCT_num = dct2(DCT_num);%DCT
      DCT_num = round (DCT_num ./ (DCT_quantizer(1:blocksize, 1:blocksize) ));%量化取整
     
    jpeg_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1) = DCT_num; %DCT矩阵
   
  end
end
%figure('name','水印图DCT量化直方图'),imhist(jpeg_img);

%提取水印
stego=jpeg_img; %水印图量化后的DCT系数
stegoindex=1;
imbed=1;
watermarkchar=0;
watermarkindex=1;

for m1=1:m
    for n1=1:n
    stegowatermark = stego(m1,n1); %DCT系数
    if (stegowatermark~=0)&&(stegowatermark~=1) %如果DCT系数不为0或1
      
        r=mod(stegowatermark,2); %DCT系数的LSB
        if (r==0)     
            singlebit=0;
        else singlebit=1;
        end
        
        singlebit=uint8(singlebit);  
        
        singlebit=bitshift(singlebit,(imbed-1)); %逐位生成水印的二进制数码（十进制表示）
        watermarkchar=uint8(watermarkchar+singlebit);%格式转换
        watermark1(m1,n1)=watermarkchar;%存储提出的每个字符的ASCII码
        
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


watermark1=uint8(watermark1);  %将ASCII码转换为字符串

%disp(messagestring);%输出隐藏的信息
%end
 
 
%  %将水印图像压缩后再进行水印提取
% clc
% clear all;
% close all;
% img = imread('水印图1/5.jpeg');
% DCT_quantizer = [ 16 , 11 , 10 , 16 , 24 , 40 , 51 , 61 %DCT量化表
% 	  12 , 12 , 14 , 19 , 26 , 58 , 60 , 55 
% 	  14 , 13 , 16 , 24 , 40 , 57 , 69 , 56
% 	  14 , 17 , 22 , 29 , 51 , 87 , 80 , 62
% 	  18 , 22 , 37 , 56 , 68 ,109 ,103 , 77
% 	  24 , 35 , 55 , 64 , 81 ,104 ,113 , 92
% 	  49 , 64 , 78 , 87 , 103 ,121,120 ,101
% 	  72 , 92 , 95 , 98 ,112 ,100 ,103 ,99 ];
% 
% blocksize=8;
% watermark=fopen('水印文件/5.txt','r');
% watermark=fgetl(watermark);
% wlength = length(watermark);
% 
% for Q=1:20:100
%     wr=0;
%     filename=['水印图压缩/Q=',num2str(Q),'.jpeg'];
%     imwrite(img,filename,'jpeg','quality',Q);  %保存文件
%     cover=imread(filename); 
%     [m,n]=size(cover);
%     for m1 = 1: blocksize: m
%      for n1 = 1: blocksize: n                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
%       DCT_num = cover(m1: m1 + blocksize-1, n1: n1 + blocksize-1);%8*8分块
%       DCT_num = dct2(DCT_num);%DCT
%       DCT_num = round (DCT_num ./ (DCT_quantizer(1:blocksize, 1:blocksize)));%量化取整
%      
%      jpeg_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1) = DCT_num; %DCT矩阵
%    
%      end
%     end
% stego=jpeg_img; %水印图量化后的DCT系数
% stegoindex=1;
% imbed=1;
% watermarkchar=0;
% watermarkindex=1;
% for m1=1:m
%     for n1=1:n
%     stegowatermark = stego(m1,n1); %DCT系数
%     if (stegowatermark~=0)&&(stegowatermark~=1) %如果DCT系数不为0或1
%       
%         r=mod(stegowatermark,2); %DCT系数的LSB
%         if (r==0)     
%             singlebit=0;
%         else singlebit=1;
%         end
%         
%         singlebit=uint8(singlebit);  
%         
%         singlebit=bitshift(singlebit,(imbed-1)); %逐位生成水印的二进制数码（十进制表示）
%         watermarkchar=uint8(watermarkchar+singlebit);%格式转换
%         watermark1(watermarkindex)=watermarkchar;%存储提出的每个字符的ASCII码
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
% watermark1=char(watermark1);  %将ASCII码转换为字符串
% if(isequal(watermark,watermark1)==0)
%  if(wlength~=length(watermark1))%如果长度不相等
%      for i=length(watermark1):wlength
%          watermark1(i)=0;%用2填充
%      end
%      for i=1:wlength
%          if(watermark1(i)~=watermark(i))
%          wr=wr+1;
%          end
%      end
%  else %若长度相等
%      for i=1:wlength
%          if(watermark1(i)~=watermark(i))
%          wr=wr+1;
%          end
%      end
%      
%  end
% p=wr/wlength;
% end
% disp('误码率：'),disp(p);
% end
% 
% 
%   
%    
%  
%  
% 
