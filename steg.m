clc;
clear all;
close all;
nMod = 7 ;
%% cover image 
[FileName,PathName] = uigetfile('*.jpg','Select the Cover Image');
file = fullfile(PathName,FileName);
disp(['User selected : ', file]);
cover = imresize(imread(file),[128 128]);
cover = double(cover);
if ndims(cover) ~= 3
msgbox('The cover image must be colour');
break;
end
figure;
subplot(1,2,1);
imshow(uint8(cover),[]);
title('Cover image');
%% secret image 
[FileName,PathName] = uigetfile('*.jpg','Select the Secret Image');
file = fullfile(PathName,FileName);
disp(['User selected : ', file]);
secret = imresize(imread(file),[128 128]);
if ndims(secret) ~= 3
msgbox('The cover image must be colour');
break;
end
subplot(1,2,2);
imshow(uint8(secret),[]);
title('Secret Image');
%% Stegnography
% Quantification of secret image by a factor 45
[nRow, nColumn] = size(cover);
secret = double(secret)/45;
stegImg1 = zeros(size(cover));
stegImg2 = zeros(size(cover));
stegImg3 = zeros(size(cover));
shadowImg1 = zeros(size(cover));
shadowImg2 = zeros(size(cover));
shadowImg3 = zeros(size(cover));
encrykey = input('Please Enter an Encryption Key Between 0 - 255:\n');
if encrykey < 0 || encrykey > 255
error('Invalid Key enter');
end
encrykey = uint8(encrykey);
for k=1:3
m = mod(cover(:,:,k), nMod);
quantification = floor(cover(:,:,k)/nMod)*nMod;
[R C] = size(cover(:,:,k));
for i = 1:R
for j = 1:C      
shadowImg1(i,j,k) = mod(m(i,j)*1,nMod);
shadowImg2(i,j,k) = mod(m(i,j)*2,nMod);
shadowImg3(i,j,k) = mod(m(i,j)*3,nMod);
stegImg1(i,j,k) = quantification(i,j)+ mod(m(i,j)*1 + secret(i,j,k),nMod);
stegImg2(i,j,k) = quantification(i,j)+mod(m(i,j)*2+ secret(i,j,k),nMod);
stegImg3(i,j,k) = quantification(i,j)+mod(m(i,j)*3+ secret(i,j,k),nMod);
end
end
end
figure;
subplot(1,3,1)
imshow(uint8(shadowImg1),[]);
title('Shadow Image 1');
subplot(1,3,2);
imshow(uint8(shadowImg2),[]);
title('Shadow Image 2');
subplot(1,3,3);
imshow(uint8(shadowImg3),[]);
title('Shadow Image 3');
figure;
subplot(1,3,1)
imshow(uint8(stegImg1),[]);
title('Stegno Image 1');
subplot(1,3,2);
imshow(uint8(stegImg2),[]);
title('Stegno Image 2');
subplot(1,3,3);
imshow(uint8(stegImg3),[]);
title('Stegno Image 3');
%%
decrykey = input('Please Enter an Decryption Key:\n');
if encrykey == decrykey    
%Reverse secret image
revsecret = zeros(size(secret));
for k=1:3
mod1 = mod(stegImg1(:,:,k), nMod);
mod2 = mod(stegImg2(:,:,k), nMod);
mod3 = mod(stegImg3(:,:,k), nMod);
for e = 1:R
for f = 1:C
if mod2(e, f) < mod1(e, f) || mod2(e, f) == 0
mod2(e, f) = mod2(e, f)+nMod;
end     
end
end
a1 = mod2 - mod1;
temp = mod1 - a1;
for e = 1:R
for f = 1:C
if temp(e,f) < 0
temp(e,f) = temp(e,f) + nMod;
end
end
end
revsecret(:,:,k) = temp*45 ; % dequantification
end
figure;
subplot(1,2,1);
imshow(uint8(revsecret),[]);
title('Reconstructed Secret Image');
%% Cover image reconstruction
dequantification = zeros(size(cover));
for k=1:3
dequantification1 = floor(stegImg1(:,:,k)/nMod)*nMod;
dequantification2 = floor(stegImg2(:,:,k)/nMod)*nMod;
dequantification3 = floor(stegImg3(:,:,k)/nMod)*nMod;    
dequantification(:,:,k) = floor((dequantification1+dequantification2+dequantification3)/3);    
end
subplot(1,2,2);
imshow(uint8(dequantification),[]);
title('Reconstructed Cover Image');
%% PSNR FOR STEGNO IMAGE
Q = 255;
MSE = sum(sum((stegImg1-cover).^2))/nRow / nColumn ;
PSNR=10*log10(Q*Q/MSE);
fprintf('The stegImg1PSNR performance is %.2f dB\n',sum(PSNR)/3);
MSE = sum(sum((stegImg2-cover).^2))/nRow / nColumn ;
PSNR=10*log10(Q*Q/MSE);
fprintf('The stegImg2PSNR performance is %.2f dB\n',sum(PSNR)/3);
MSE = sum(sum((stegImg3-cover).^2))/nRow / nColumn ;
PSNR=10*log10(Q*Q/MSE);
fprintf('The stegImg3PSNR performance is %.2f dB\n',sum(PSNR)/3);
else
msgbox('You have enter the invalid key');
end
