function Iout = lab5houghlines(Img)

[r,c,s] = size(Img);

if(s == 3)
    Img = rgb2gray(Img);
end

Img_operation = double(Img);


Im_edge = edge(Img_operation,"Canny");

[H,theta,rho] = hough(Im_edge, "RhoResolution",0.5,"Theta", -90:0.5:89);

th = ceil(0.8*max(H(:))); %threshold

a = 0.8*max(H(:));

P  = houghpeaks(H, 3,"Threshold",th); %peak number



figure

subplot(2,2,1)
imshow(Img);
title('Original Image');

subplot(2,2,2)
imshow(Im_edge);
title('Edges');

subplot(2,2,3.5)
imshow(imadjust(rescale(H)),'XData',theta,'YData',rho,'InitialMagnification','fit');
title('Hough Trasnform');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;

figure

subplot(1,1,1)
imshow(H,[],'XData',theta,'YData',rho,'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
title("Detected Hough Peaks")
plot(theta(P(:,2)),rho(P(:,1)),'s','color','white');


lines = houghlines(Im_edge,theta,rho,P,'FillGap',50,'MinLength',400); %fillgap minlenght
figure
imshow(Img), hold on
title("Founds lines ")
max_len = 5;
min_len = 2000;

for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   
   % Plot beginnings and ends of lines
   %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   %plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');


   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   elseif(len<min_len)
       min_len = len;
       xy_short = xy; 
   end
   
end

   plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');
   plot(xy_short(:,1),xy_short(:,2),'LineWidth',2,'Color','red');



end