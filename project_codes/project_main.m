%%%%%%%%%%%%%%%    EE 417 COMPUTER VISION TERM PROJECT    %%%%%%%%%%%%%%%

%%%%%%%%%%%%%%    Detection of Basic Traffic Violations     %%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%    EFE ÖZTABAN 25202    %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%    KAYRA BİLGİN 25117     %%%%%%%%%%%%%%%%%%%%%%%

%%
clear all; close all; clc;

%% Video Name

%video_name = "video3_grayscale.mov";
video_name = "video4_grayscale.mov";
%video_name = "video5_grayscale.mp4";


%% Time Calibration

v = VideoReader(video_name);
numImgs = get(v, 'NumFrames');

%duration = 9; % for video3_grayscale
duration = 12; % for video4_grayscale
%duration = 10; % for video5_grayscale

time_coefficient = duration/numImgs;

fprintf("Video has %5.1f number of frames. \n",numImgs);

fprintf("Time coefficient for the video is %5.5f. \n", time_coefficient);

%% Lane Calibration (Line Detection)

videoReader = vision.VideoFileReader(video_name);

for j=2:100:numImgs
    
    
    frame = step(videoReader);
    lab5houghlines(frame);
    
    pause(0.1);
    
end

%% Lane Calibration (Variable Definitions) 

line_lenght1 =13;
line_lenght2=12;
line_lenght3=13;
line_lenght4= 14;

line1_y1 = 400;
line1_y2 = 430;

line1_lane1_x1 = 430;
line1_lane1_x2 = 640;

line1_lane2_x1 = 645;
line1_lane2_x2 = 840;

line1_lane3_x1 = 845;
line1_lane3_x2 = 1027;

line1_lane4_x1 = 1038;
line1_lane4_x2 = 1200;

line2_y1 = 240;
line2_y2 = 270;

line2_lane1_x1 = 555;
line2_lane1_x2 = 684;

line2_lane2_x1 = 690;
line2_lane2_x2 = 823;

line2_lane3_x1 = 827;
line2_lane3_x2 = 951;

line2_lane4_x1 = 963;
line2_lane4_x2 = 1070;

%% ForeGround Detector Training

gaussian_num_for_training = 5;
num_of_repeated_traning = 5;

foregroundDetector = vision.ForegroundDetector('NumGaussians', gaussian_num_for_training, 'NumTrainingFrames', numImgs*num_of_repeated_traning );
videoReader = vision.VideoFileReader(video_name);


for j=1:num_of_repeated_traning
    for i = 1:numImgs

     frame = step(videoReader);                     % takes the next frame from the video
     frame = imgaussfilt(frame);                    % smooth the frame image with gaussian filter
     foreground = step(foregroundDetector, frame);  % trains the detector with the new frame

    end
    
    videoReader = vision.VideoFileReader(video_name);
    
end

%% Frame Processing Example Visulizations

expected_frame_num = 50;


for i = 1:expected_frame_num

    frame = step(videoReader);

end

figure
imshow(frame)           % frame image
title('Video Frame')


frame = imgaussfilt(frame);
foreground = step(foregroundDetector, frame);
    

figure
imshow(frame)           % smoothed frame image
title('Smoothed Video Frame')

figure
imshow(foreground)      % foreground image
title('Foreground')


structing_element = strel('square', 3);  % structing element for removing noise from the foreground
filteredForeground = imopen(foreground, structing_element);  % apply structring element of the foreground

figure; 
imshow(filteredForeground);   % filtered foreground image
title('Cleaned Foreground');

%% Car Detection 


carDetector_blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, 'AreaOutputPort', false, ... 
'CentroidOutputPort', true, 'MinimumBlobArea', 150);

[centerPoints_of_cars,detected_car_boxes] = step(carDetector_blobAnalysis, filteredForeground);

result = insertShape(frame, 'Rectangle', detected_car_boxes, 'Color', 'green');
num_of_car_boxes = size(detected_car_boxes, 1);

result = insertText(result, [10 10], num_of_car_boxes, 'BoxOpacity', 1, 'FontSize', 14);

figure; 
imshow(result);         % example detected cars image
title('Detected Cars');


%% Variable Definitions

speed_converter = 18/5;  % converts speed from m/s into km/h

speed_limit=100;

lower_speed_limit_left= 80;

% breakdown lane
error1 = 0;

%speed limit
error2 = 0;
error3 = 0;
error4 = 0;

%occupancy of left lane in low speed
error5 = 0;

%wrong way
error6 = 0;
error7 = 0;
error8 = 0;

error1_disp=0;
error2_disp=0;
error3_disp=0;
error4_disp=0;
error5_disp=0;
error6_disp=0;
error7_disp=0;
error8_disp=0;


error1_counter = 0;
error2_counter = 0;
error3_counter = 0;
error4_counter = 0;
error5_counter = 0; 
error6_counter = 0;
error7_counter = 0;
error8_counter = 0; 

error_message_timeout = 30;


text_message1= "There is a vehicle in the breakdown lane";
text_message2= "There is a vehicle exceding speed limit in first lane";
text_message3= "There is a vehicle exceding speed limit in second lane";
text_message4= "There is a vehicle exceding speed limit in second lane";
text_message5= "There is occupancy of the left lane by a vehicle in low speed";
text_message6= "There is a vehicle on wrong way in first lane";
text_message7= "There is a vehicle on wrong way in second lane";
text_message8= "There is a vehicle on wrong way in third lane";


%% Main Loop for Traffic Violation Detection (for video3_grayscale and video4_grayscale)

videoReader = vision.VideoFileReader(video_name);
videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
videoPlayer.Position(3:4) = [950,400]; 

se = strel('square', 3);                          % morphological filter for noise removal

lane1_car_detector=1;
lane2_car_detector=1;
lane3_car_detector=1;
lane4_car_detector=1;

lane1_wrong_way = 0;
lane2_wrong_way = 0;
lane3_wrong_way = 0;
lane4_wrong_way = 0;

speed_of_lane1=0;
speed_of_lane2=0;
speed_of_lane3=0;
speed_of_lane4=0;

prev_speed_of_lane1 = 0;
prev_speed_of_lane2 = 0;
prev_speed_of_lane3 = 0;
prev_speed_of_lane4 = 0;
prev_speed_of_lane5 = 0;

frame_num=1;


while ~isDone(videoReader)
    
    tic

    frame = step(videoReader);                    % takes the next frame from the video
    foreground = step(foregroundDetector, frame); % smooth the frame image with gaussian filter
    filteredForeground = imopen(foreground, se);  % trains the detector with the new frame
    
    
    % Detect cars from the frame with filtered foreground
    [centerPoints_of_cars,detected_car_boxes] = step(carDetector_blobAnalysis, filteredForeground);
    center_of_detected_cars = step(carDetector_blobAnalysis, filteredForeground);
    
    
    % Filters the founded cars and boxes
     num = size(detected_car_boxes);
 
     if(num>1)
        detected_car_boxes = car_filter(detected_car_boxes,150);
        center_of_detected_cars = car_filter_center(center_of_detected_cars,150);
     end
     

    % Draw boxes around the detected cars
    result = insertShape(frame, 'Rectangle', detected_car_boxes, 'Color', 'green');
    [number_of_detected_cars,cc]=size(center_of_detected_cars);
    
    num_of_car_boxes = size(detected_car_boxes, 1);
    
    
    if(num_of_car_boxes>0)
        for i=1:number_of_detected_cars
            
            x_location = center_of_detected_cars(i,1);
            y_location = center_of_detected_cars(i,2);

            % first line detection for speed extraction
            
            if(y_location>line1_y1 && y_location<line1_y2)
                
                if x_location>line1_lane1_x1 && x_location<line1_lane1_x2
                    if(lane1_car_detector==1)
                        a1=frame_num;
                        lane1_car_detector=0;
%                         disp("first check line 1")

                    end
                end
                
                if x_location>line1_lane2_x1 && x_location<line1_lane2_x2
                    if(lane2_car_detector==1)
                        a2=frame_num;
                        lane2_car_detector=0;
%                         disp("first check line 2")

                    end
                end
                
                if x_location>line1_lane3_x1 && x_location<line1_lane3_x2
                    if(lane3_car_detector==1)
                        a3=frame_num;
                        lane3_car_detector=0;
%                         disp("first check line 3")

                    end
                end
                
                if x_location>line1_lane4_x1 && x_location<line1_lane4_x2
                    if(lane4_car_detector==1)
                        a4=frame_num;
                        lane4_car_detector=0;
                        
%                         disp("first check line 4")
                    end
                end
                
            end
            
            % second line detection for speed extraction

            if(y_location>line2_y1&&y_location<line2_y2)

                if x_location>line2_lane1_x1 && x_location<line2_lane1_x2
                    if(lane1_car_detector==0)
                        
                        b1=frame_num;
                        t1=b1-a1;
                        t1 = t1*time_coefficient;
                        
                        speed_of_lane1=line_lenght1/t1;
                        speed_of_lane1=speed_of_lane1*speed_converter;
                       

                        lane1_car_detector=1;
                        lane1_wrong_way = 0;
                        
%                         disp("second check line 1")

%                         disp("wrong way start lane1")
                    end
                    
                end
                
                if x_location >line2_lane2_x1 && x_location<line2_lane2_x2
                    if(lane2_car_detector==0)

                        b2=frame_num;
                        t2=b2-a2;
                        t2 = t2*time_coefficient;
                        
                        speed_of_lane2=line_lenght2/t2;
                        speed_of_lane2=speed_of_lane2*speed_converter;
                        
                        
                        lane2_car_detector=1;
                        lane2_wrong_way = 0;
                        
%                         disp("second check line 2")

%                         disp("wrong way start lane2")
                    end    
                end
                
                if x_location>line2_lane3_x1 &&x_location<line2_lane3_x2
                    if(lane3_car_detector==0)

                        b3=frame_num;
                        t3=b3-a3;                        
                        t3 = t3*time_coefficient;
                        
                        speed_of_lane3=line_lenght3/t3;
                        speed_of_lane3=speed_of_lane3*speed_converter;
                        
                        
                        lane3_car_detector=1;
                        lane3_wrong_way = 0;
                       
%                         disp("second check line 3")

%                         disp("wrong way start lane3")
                    end    
                end
                
                
                if x_location>line2_lane4_x1 &&x_location<line2_lane4_x2
                    if(lane4_car_detector==0)
 
                        b4=frame_num;
                        t4=b4-a4;
                        t4 = t4*time_coefficient;

                        speed_of_lane4=line_lenght4/t4;
                        speed_of_lane4=speed_of_lane4*speed_converter;

                                                
                        lane4_car_detector=1;
%                         disp("second check line 4")  

                    end 
                end
                
            end
            
        end
    end

  
    num_of_car_boxes = size(detected_car_boxes, 1);


    % display the results on the frame image
    
    result = insertText(result, [10 10], num_of_car_boxes, 'BoxOpacity', 1, 'FontSize', 14);
    result = insertText(result, [720 10], round(speed_of_lane1), 'BoxOpacity', 1, 'FontSize', 14);
    result = insertText(result, [765 10], round(speed_of_lane2), 'BoxOpacity', 1, 'FontSize', 14);
    result = insertText(result, [810 10], round(speed_of_lane3), 'BoxOpacity', 1, 'FontSize', 14);
    result = insertText(result, [855 10], round(speed_of_lane4), 'BoxOpacity', 1, 'FontSize', 14);


    % error message displays
    if(error1 == 1)

%         disp(text_message1)
        result = insertText(result, [15 80], text_message1, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red');
        error1_counter = error1_counter+1;
        
        if (error1_counter == error_message_timeout)
            error1 = 0;
        elseif(error1_counter==1)
            error1_disp=1;          
        end
        

    end

    if(error2 == 1)

%         disp(text_message2)
        result = insertText(result, [15 110], text_message2, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red');
        error2_counter = error2_counter+1;
        
        if (error2_counter == error_message_timeout)
            error2 = 0;
        elseif(error2_counter==1)
            error2_disp=1;
        end

      
    end
    
    if(error3 == 1)

%         disp(text_message3)
        result = insertText(result, [15 140], text_message3, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red');
        error3_counter = error3_counter+1;
        
        if (error3_counter == error_message_timeout)
            error3 = 0;
        elseif(error3_counter==1)
            error3_disp=1;       
        end
        
      
    end
    
    if(error4 == 1)

%         disp(text_message4)
        result = insertText(result, [15 170], text_message4, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red'); 
        error4_counter = error4_counter+1;
        
        if (error4_counter == error_message_timeout)
            error4 = 0;
        elseif(error4_counter==1)
            error4_disp=1;
        end
        

      
    end
    
    if(error5 == 1)
      
%         disp(text_message5)
        result = insertText(result, [15 200], text_message5, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','yellow');
        error5_counter = error5_counter+1;
        
        if (error5_counter == error_message_timeout)
            error5 = 0;
        elseif(error5_counter==1)
            error5_disp=1;
        end
        
      
    end
    



    % error detectors
    
    if(lane4_car_detector == 0)
        if(error1 == 0)
            
            error1 = 1;
            error1_counter = 0;
            
        end
    end
    
    if(speed_of_lane1>speed_limit)
       
        if(error2 == 0 && speed_of_lane1 ~= prev_speed_of_lane1)
            
            error2 = 1;
            error2_counter = 0;
            prev_speed_of_lane1 = speed_of_lane1;
            
        end
    end
    
    if(speed_of_lane2>speed_limit)
       
        if(error3 == 0 && speed_of_lane2 ~= prev_speed_of_lane2)
            
            error3 = 1;
            error3_counter = 0;
            prev_speed_of_lane2 = speed_of_lane2;
            
        end
     end
    
    if(speed_of_lane3>speed_limit)
       
        if(error4 == 0 && speed_of_lane3 ~= prev_speed_of_lane3)
            
            error4 = 1;
            error4_counter = 0;
            prev_speed_of_lane3 = speed_of_lane3;
            
        end
    end
    
    if(speed_of_lane1<lower_speed_limit_left)
       
        if(error5 == 0 && speed_of_lane1 ~= prev_speed_of_lane5)
            
            error5 = 1;
            error5_counter = 0;
            prev_speed_of_lane5 = speed_of_lane1;
            
        end
    end
    

step(videoPlayer, result); % display the result on the result video

frame_num = frame_num+1;

if( error1_disp)
    
    figure;
    imshow(result);
    title("Detected Breakdown lane violation")
    
    error1_disp = 0;

    
elseif (error2_disp || error3_disp || error4_disp )
    
    figure;
    imshow(result);
    title("Detected speed limit violation")
    
    error2_disp = 0;
    error3_disp = 0;
    error4_disp = 0;
    
    
elseif (error5_disp)
    
    figure;
    imshow(result);
    title("Occupancy of left lane in low speed warning")
    
    error5_disp = 0;


end
    

end


release(videoReader); % close the video file
%% Main Loop for Traffic Violation Detection (for video6_grayscale)

videoReader = vision.VideoFileReader(video_name);
videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
videoPlayer.Position(3:4) = [950,400]; 

se = strel('square', 3);                          % morphological filter for noise removal

lane1_car_detector=1;
lane2_car_detector=1;
lane3_car_detector=1;
lane4_car_detector=1;

lane1_wrong_way = 0;
lane2_wrong_way = 0;
lane3_wrong_way = 0;
lane4_wrong_way = 0;

speed_of_lane1=0;
speed_of_lane2=0;
speed_of_lane3=0;
speed_of_lane4=0;

prev_speed_of_lane1 = 0;
prev_speed_of_lane2 = 0;
prev_speed_of_lane3 = 0;
prev_speed_of_lane4 = 0;
prev_speed_of_lane5 = 0;

frame_num=1;


while ~isDone(videoReader)
    
    tic

    frame = step(videoReader);                    % takes the next frame from the video
    foreground = step(foregroundDetector, frame); % smooth the frame image with gaussian filter
    filteredForeground = imopen(foreground, se);  % trains the detector with the new frame
    
    
    % Detect cars from the frame with filtered foreground
    [centerPoints_of_cars,detected_car_boxes] = step(carDetector_blobAnalysis, filteredForeground);
    center_of_detected_cars = step(carDetector_blobAnalysis, filteredForeground);
    
    
    % Filters the founded cars and boxes
     num = size(detected_car_boxes);
 
     if(num>1)
        detected_car_boxes = car_filter(detected_car_boxes,150);
        center_of_detected_cars = car_filter_center(center_of_detected_cars,150);
     end
     

    % Draw boxes around the detected cars
    result = insertShape(frame, 'Rectangle', detected_car_boxes, 'Color', 'green');
    [number_of_detected_cars,cc]=size(center_of_detected_cars);
    
    num_of_car_boxes = size(detected_car_boxes, 1);
    
    
    if(num_of_car_boxes>0)
        for i=1:number_of_detected_cars
            
            x_location = center_of_detected_cars(i,1);
            y_location = center_of_detected_cars(i,2);

            % first line detection for speed extraction
            
            if(y_location>line1_y1 && y_location<line1_y2)
                
                if x_location>line1_lane1_x1 && x_location<line1_lane1_x2
                    if(lane1_car_detector==1)
                        a1=frame_num;
                        lane1_car_detector=0;
%                         disp("first check line 1")
                    elseif(lane1_wrong_way == 1)
                        lane1_wrong_way = 0;
                        error6=1;
                    end
                end
                
                if x_location>line1_lane2_x1 && x_location<line1_lane2_x2
                    if(lane2_car_detector==1)
                        a2=frame_num;
                        lane2_car_detector=0;
%                         disp("first check line 2")
                    elseif(lane2_wrong_way == 1)
                        lane2_wrong_way = 0;
                        error7=1;
                    end
                end
                
                if x_location>line1_lane3_x1 && x_location<line1_lane3_x2
                    if(lane3_car_detector==1)
                        a3=frame_num;
                        lane3_car_detector=0;
%                         disp("first check line 3")
                    elseif(lane3_wrong_way == 1)
                        lane3_wrong_way = 0;
                        error8=1;
                    end
                end
                
                if x_location>line1_lane4_x1 && x_location<line1_lane4_x2
                    if(lane4_car_detector==1)
                        a4=frame_num;
                        lane4_car_detector=0;
                        
%                         disp("first check line 4")
                    end
                end
                
            end
            
            % second line detection for speed extraction

            if(y_location>line2_y1&&y_location<line2_y2)

                if x_location>line2_lane1_x1 && x_location<line2_lane1_x2
                    if(lane1_car_detector==0)
                        
                        b1=frame_num;
                        t1=b1-a1;
                        t1 = t1*time_coefficient;
                        
                        speed_of_lane1=line_lenght1/t1;
                        speed_of_lane1=speed_of_lane1*speed_converter;
                       

                        lane1_car_detector=1;
                        lane1_wrong_way = 0;
                        
%                         disp("second check line 1")
                    elseif (lane1_wrong_way == 0)
                        lane1_wrong_way = 1;
%                         disp("wrong way start lane1")
                    end
                    
                end
                
                if x_location >line2_lane2_x1 && x_location<line2_lane2_x2
                    if(lane2_car_detector==0)

                        b2=frame_num;
                        t2=b2-a2;
                        t2 = t2*time_coefficient;
                        
                        speed_of_lane2=line_lenght2/t2;
                        speed_of_lane2=speed_of_lane2*speed_converter;
                        
                        
                        lane2_car_detector=1;
                        lane2_wrong_way = 0;
                        
%                         disp("second check line 2")
                    elseif (lane2_wrong_way == 0)
                        lane2_wrong_way = 1;
%                         disp("wrong way start lane2")
                    end    
                end
                
                if x_location>line2_lane3_x1 &&x_location<line2_lane3_x2
                    if(lane3_car_detector==0)

                        b3=frame_num;
                        t3=b3-a3;                        
                        t3 = t3*time_coefficient;
                        
                        speed_of_lane3=line_lenght3/t3;
                        speed_of_lane3=speed_of_lane3*speed_converter;
                        
                        
                        lane3_car_detector=1;
                        lane3_wrong_way = 0;
                       
%                         disp("second check line 3")
                    elseif (lane3_wrong_way == 0)
                        lane3_wrong_way = 1;
%                         disp("wrong way start lane3")
                    end    
                end
                
                
                if x_location>line2_lane4_x1 &&x_location<line2_lane4_x2
                    if(lane4_car_detector==0)
 
                        b4=frame_num;
                        t4=b4-a4;
                        t4 = t4*time_coefficient;

                        speed_of_lane4=line_lenght4/t4;
                        speed_of_lane4=speed_of_lane4*speed_converter;

                                                
                        lane4_car_detector=1;
                        lane4_wrong_way = 0;
%                         disp("second check line 4")  

                    end 
                end
                
            end
            
        end
    end

  
    num_of_car_boxes = size(detected_car_boxes, 1);


    % display the results on the frame image
    
    result = insertText(result, [10 10], num_of_car_boxes, 'BoxOpacity', 1, 'FontSize', 14);
    result = insertText(result, [720 10], round(speed_of_lane1), 'BoxOpacity', 1, 'FontSize', 14);
    result = insertText(result, [765 10], round(speed_of_lane2), 'BoxOpacity', 1, 'FontSize', 14);
    result = insertText(result, [810 10], round(speed_of_lane3), 'BoxOpacity', 1, 'FontSize', 14);
    result = insertText(result, [855 10], round(speed_of_lane4), 'BoxOpacity', 1, 'FontSize', 14);


    % error message displays
    if(error1 == 1)

%         disp(text_message1)
        result = insertText(result, [15 80], text_message1, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red');
        error1_counter = error1_counter+1;
        
        if (error1_counter == error_message_timeout)
            error1 = 0;
        elseif(error1_counter==1)
            error1_disp=1;          
        end
        

    end

    if(error2 == 1)

%         disp(text_message2)
        result = insertText(result, [15 110], text_message2, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red');
        error2_counter = error2_counter+1;
        
        if (error2_counter == error_message_timeout)
            error2 = 0;
        elseif(error2_counter==1)
            error2_disp=1;
        end

      
    end
    
    if(error3 == 1)

%         disp(text_message3)
        result = insertText(result, [15 140], text_message3, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red');
        error3_counter = error3_counter+1;
        
        if (error3_counter == error_message_timeout)
            error3 = 0;
        elseif(error3_counter==1)
            error3_disp=1;       
        end
        
      
    end
    
    if(error4 == 1)

%         disp(text_message4)
        result = insertText(result, [15 170], text_message4, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red'); 
        error4_counter = error4_counter+1;
        
        if (error4_counter == error_message_timeout)
            error4 = 0;
        elseif(error4_counter==1)
            error4_disp=1;
        end
        

      
    end
    
    if(error5 == 1)
      
%         disp(text_message5)
        result = insertText(result, [15 200], text_message5, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','yellow');
        error5_counter = error5_counter+1;
        
        if (error5_counter == error_message_timeout)
            error5 = 0;
        elseif(error5_counter==1)
            error5_disp=1;
        end
        
      
    end
    
    if(error6 == 1)
      
%         disp(text_message5)
        result = insertText(result, [15 230], text_message6, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red');
        error6_counter = error6_counter+1;
        
        if (error6_counter == error_message_timeout)
            error6 = 0;
        elseif(error6_counter==1)
            error6_disp=1;
        end
        
      
    end
    if(error7 == 1)
      
%         disp(text_message5)
        result = insertText(result, [15 260], text_message7, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red');
        error7_counter = error7_counter+1;
        
        if (error7_counter == error_message_timeout)
            error7 = 0;
        elseif(error7_counter==1)
            error7_disp=1;
        end
        
      
   end
   if(error8 == 1)
      
%         disp(text_message5)
        result = insertText(result, [15 290], text_message8, 'BoxOpacity', 1, 'FontSize', 14,'BoxColor','red');
        error8_counter = error8_counter+1;
        
        if (error8_counter == error_message_timeout)
            error8 = 0;
        elseif(error8_counter==1)
            error8_disp=1;
        end
        
      
    end

    % error detectors
    
    if(lane4_car_detector == 0)
        if(error1 == 0)
            
            error1 = 1;
            error1_counter = 0;
            
        end
    end
    
    if(speed_of_lane1>speed_limit)
       
        if(error2 == 0 && speed_of_lane1 ~= prev_speed_of_lane1)
            
            error2 = 1;
            error2_counter = 0;
            prev_speed_of_lane1 = speed_of_lane1;
            
        end
    end
    
    if(speed_of_lane2>speed_limit)
       
        if(error3 == 0 && speed_of_lane2 ~= prev_speed_of_lane2)
            
            error3 = 1;
            error3_counter = 0;
            prev_speed_of_lane2 = speed_of_lane2;
            
        end
     end
    
    if(speed_of_lane3>speed_limit)
       
        if(error4 == 0 && speed_of_lane3 ~= prev_speed_of_lane3)
            
            error4 = 1;
            error4_counter = 0;
            prev_speed_of_lane3 = speed_of_lane3;
            
        end
    end
    
    if(speed_of_lane1<lower_speed_limit_left)
       
        if(error5 == 0 && speed_of_lane1 ~= prev_speed_of_lane5)
            
            error5 = 1;
            error5_counter = 0;
            prev_speed_of_lane5 = speed_of_lane1;
            
        end
    end
    

step(videoPlayer, result); % display the result on the result video

frame_num = frame_num+1;

if( error1_disp)
    
    figure;
    imshow(result);
    title("Detected Breakdown lane violation")
    
    error1_disp = 0;

    
elseif (error2_disp || error3_disp || error4_disp )
    
    figure;
    imshow(result);
    title("Detected speed limit violation")
    
    error2_disp = 0;
    error3_disp = 0;
    error4_disp = 0;
    
    
elseif (error5_disp)
    
    figure;
    imshow(result);
    title("Occupancy of left lane in low speed warning")
    
    error5_disp = 0;



elseif (error6_disp || error7_disp || error8_disp)
    
    figure;
    imshow(result);
    title("Detected wrong way driving violation")
    
    error6_disp = 0;
    error7_disp = 0;
    error8_disp = 0;

end
    

end


release(videoReader); % close the video file