%Original code
myIm = zeros(100,100);
 myIm(40:60, 20:80) = 1;
 imshow(myIm)
 imshow(bwmorph(myIm,'skel',Inf))
 
 
 
 
 
 
% Z = length and height of whole image%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 Z = 500;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 %  Rectange - object dimensions 80 by 250
 RecWidth = 80;   %according to anton's image
 RecLength = 250; %according to anton's image
 recIm = zeros (Z,Z);
recIm(((Z/2)-(RecWidth/2)):((Z/2)+(RecWidth/2)),((Z/2)-(RecLength/2)):((Z/2)+(RecLength/2)) ) = 1;
  imshow(recIm)
  imshow(bwmorph(recIm,'skel',Inf))
  
  
  % two overlapping circles  - r =  65, vertically stacked with center of
  % each spaced 120, leaving 10 overlap.
  
myIm = zeros(500,500);
RGB = insertShape(myIm,'filledcircle',[(Z/2) (Z/2)-60 65],'Color', [255 255 255]);
RGB = insertShape(RGB,'filledcircle',[(Z/2) (Z/2)+60 65],'Color', [255 255 255]);
imshow(RGB)



grayImage = rgb2gray(RGB);
imshow(bwmorph(grayImage,'skel',Inf))