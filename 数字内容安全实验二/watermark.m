%Ƕ��
    cover=double(imread('lena512.bmp'));
    figure('name','ԭͼ'),imshow('lena512.bmp');
    test1='asdfghjklertyuasdfghjklertyu';
    test1=abs(test1);%תΪASCII��
    test2=dec2base(test1,2,8);%תΪ8λ������
    test3=double(test2);%תΪDOUBLE
    message=mod(test3,2);%תΪ����
    [m,n]=size(message);
    m1=dec2base(m,2,8);
    m1=double(m1);
    m1=mod(m1,2);%4�Ķ����ƾ���
    n1=dec2base(n,2,8);
    n1=double(n1);
    n1=mod(n1,2);%8�Ķ����ƾ���
    message_plus1=2*(double(rand(1,16)>0.5)-0.5);%���������1
    message_plus2=2*(double(rand(m,n)>0.5)-0.5); %���������2
    cover1=mod(cover,2); %ԭͼ��������Чλ
    a=cover1; 
    cover3=cover;
    for x=1:8
        if cover1(x)==m1(x)
            cover3(x)=cover(x);
        elseif cover(x)==0 
                cover3(x)=cover(x)+1; 
        elseif cover3(x)==255 
                cover(x)=cover(x)-1; 
        else 
                cover3(x)=cover(x)+message_plus1(x);%����Ӽ�1
        end
    end 
    for x=1:8
         if cover1(x+8)==n1(x)
            cover3(x+8)=cover(x+8);
        elseif cover(x+8)==0 
                cover3(x+8)=cover(x+8)+1; 
        elseif cover3(x+8)==255 
                cover(x+8)=cover(x+8)-1; 
        else 
                cover3(x+8)=cover(x+8)+message_plus1(x+8);%����Ӽ�1
        end
    end 
        
        
 
 %Ƕ����Ϣ   
    for x=1:m 
        for y=2:n+1
            
            if cover1(x,y-1)==message(x,y-1) %���ȡ0-1����������Чλ��������Ϣ������ͬ
                cover3(x,y)=cover(x,y-1);
            elseif cover(x,y-1)==0 
                cover3(x,y)=cover(x,y-1)+1; 
            elseif cover(x,y-1)==255 
                cover3(x,y)=cover(x,y-1)-1; 
            else 
                cover3(x,y)=cover(x,y-1)+message_plus2(x,y-1);%����Ӽ�1
            end
        end 
    end 
    figure('name','����ͼ'),imshow(uint8(cover3));
    imwrite(uint8(cover3),'lena1.bmp');
  
  %��ȡ
  m2=[];
  n2=[];
  message2=[];
  cover4=mod(cover3,2);
  for y=1:8
      m2(y)=double(cover4(y));
  end
m2=num2str(m2);
m2=bin2dec(m2);
  for y=9:16
      n2(y)=double(cover4(y));
  end
n2=num2str(n2);
n2=bin2dec(n2);
for x=1:m2
    for y=2:n2+1
        message2(x,y-1)=cover4(x,y);
    end
end
message2=num2str(message2);
message2=bin2dec(message2);
message2=char(message2);
disp(message2);

% 
% I=imread('lena512.bmp');
% G=imread('lena1.bmp');
% %figure('name','ԭͼ�Ҷ�ֱ��ͼ'),imhist(I);
% %figure('name','�Ҷ�ֱ��ͼ'),imhist(G);
% for x=1:512
%     for y=1:512
%         if mod(cover3(x,y),2)==0
%             S(x,y)=cover(x,y)-cover3(x,y);
%         end
%     end
% end
