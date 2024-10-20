function filtered_data = car_filter(data,threshold)

filtered_data = data(1,:);

[row,col] = size(data);

data = sortrows(data,3,'descend');

for i=2:row
    
    check = true;
    [num1,num2] = size(filtered_data);

    for j=1:num1
        
        if(abs(data(i,1)-filtered_data(j,1)) < threshold)
            if(abs(data(i,2)-filtered_data(j,2)) < threshold)
                check = false;
            end
        end
        
        
    end
    
    if(check == true)
        filtered_data = [ filtered_data; data(i,:) ];
    end
   
    
end


end