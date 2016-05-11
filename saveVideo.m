function saveVideo(BB, C, objLabels, s)

	% videoWriter = VideoWriter('result.avi');
	% videoWriter.FrameRate = 30;
	% open(videoWriter);

	W = vision.VideoFileWriter('./result.avi', 'FrameRate', 30);
    
    n = length(s);
    
    moveDistance = cell(n, 1);
    angle = cell(n,1);
    box = cell(n,1);
  

	nobj = size(objLabels, 2); % number of objects

	lastObjPosition = zeros(nobj,2);

	function H = getTextInserter(text, pos)
		H = vision.TextInserter(text);
		H.Location = pos;
		H.FontSize = 20;
		H.Color = [1.0, 1.0, 1.0];
	end	

	for i = 1:n
		% i
		newimg = im2double(s(i).cdata);

	 	% Write the frame of the video
		for j = 1:2

			objIndex = objLabels(i, j);

			if objIndex ~= 0
                try
                    bb = cell2mat(BB(i,objIndex));	
                catch
                    i
                    objIndex
                end
                
				% draw boxes
				minx = bb(1);
				maxx = minx + bb(3);
				miny = bb(2);
				maxy = miny + bb(4);
                
                box{i,j}=[minx, maxx, miny, maxy];

				for dem = 1:3
				for x = minx:maxx
				newimg(miny,x,dem) = 255;
				newimg(maxy,x,dem) = 255;
				end

				for y = miny:maxy
				newimg(y,minx,dem) = 255;
				newimg(y,maxx,dem) = 255;
				end
				end

				% sign movements
				sign_loc = [minx, miny];
				sign_text = '';
                
                try
                    obj_y = C(i, 2*objIndex - 1);
                    obj_x = C(i, 2*objIndex);
                catch

                end

				if lastObjPosition(j,:) == [0,0]
					sign_text = 'appeared'; 
				else
					last_y = lastObjPosition(j,1);
					last_x = lastObjPosition(j,2);
                    
                    moveDistance{i,j} = sqrt((obj_x - last_x)^2 + (obj_y - last_y)^2);
                    angle{i,j} = atan((obj_y - last_y)/(obj_x - last_x));
                    

					if obj_x > last_x
						sign_text = [sign_text 'right'];
					else
						sign_text = [sign_text 'left'];
					end

					if obj_y > last_y
						% mark 'down'
						sign_text = [sign_text ' down'];
					else
						% mark 'up'
						sign_text = [sign_text ' up'];
					end

					if (obj_x - last_x)^2 + (obj_y - last_y)^2 < 16
						sign_text = 'still';
					end
					% mark
				end

				% sign_text
				lastObjPosition(j,:) = [obj_y, obj_x];
				H = getTextInserter(sign_text, sign_loc);
				newimg = step(H, newimg);

			else
				lastObjPosition(j,:) = [0,0];
			end
		end
		% newimg = im2double(newimg);

		% writeVideo(videoWriter, newimg);
        step(W, newimg);
	end
	release(W);
    
    save('moveDistance', 'moveDistance');
    save('angle', 'angle');
    save('box', 'box');
   

end