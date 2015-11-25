// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OBJLoader function

function [ vertices , faces ] = MSHLoader(MSHfile)
//%%%%%%%%%%%%%%%%%%%%%%%%%%%% load the vertices %%%%%%%%%%%%%%%%
fid=mopen(MSHfile,'r');
a = mfscanf(fid,'%s');

while (a~='Coordinates'),
    a = mfscanf(fid,'%s');
end
numVertices=0;
a = mfscanf(fid,'%s');

while (a~='end')
  numVertices=numVertices+1;
  for j=1:3,
    vertices(j,numVertices) = mfscanf(fid,'%f');
  end
  a = mfscanf(fid,'%s');
end
mclose(fid);
//printf('numVertices = %d', numVertices);

//%%%%%%%%%%%%%%%%%%%%%%%%%%% load the faces %%%%%%%%%%%%%%%%
fid=mopen(MSHfile,'r');
a = mfscanf(fid,'%s');

while (a~='Elements'),
    a = mfscanf(fid,'%s');
end
numFaces=0;
a = mfscanf(fid,'%s');

while (a~='end')
  numFaces =numFaces+1;
  for j=1:3,
    a = mfscanf(fid,'%d')
    faces (j, numFaces ) = a;
  end
  a = mfscanf(fid,'%s');
end

//buf = faces(:,2);
//faces(:,2) = faces(:,3);
//faces(:,3) = buf;
mclose(fid);
//printf(' numFaces  = %d', numFaces );
endfunction

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% draw_mesh function
function [segments] = findSegments(faces)
numElements = size(faces,2);    
// trouve la liste de segments...
segments = [];
numSegments=0;
for i=1:numElements,
    numSegments=numSegments+1;
    
    if faces(1,i)<faces(2,i) then
        segments(1,numSegments)=faces(1,i);
        segments(2,numSegments)=faces(2,i);
    else
        segments(1,numSegments)=faces(2,i);
        segments(2,numSegments)=faces(1,i);
    end    
    
    numSegments=numSegments+1;    
    if faces(2,i)<faces(3,i) then    
        segments(1,numSegments)=faces(2,i);
        segments(2,numSegments)=faces(3,i);
    else
        segments(1,numSegments)=faces(3,i);
        segments(2,numSegments)=faces(2,i);
    end
    
     
    numSegments=numSegments+1;
    if faces(3,i)<faces(1,i) then
        segments(1,numSegments)=faces(3,i);
        segments(2,numSegments)=faces(1,i);
    else
        segments(1,numSegments)=faces(1,i);
        segments(2,numSegments)=faces(3,i);
    end        
end

doublons=[];
numDoublons=0;
pasDoublon=[];
numS=0

for s1=1:numSegments
    
    test=1;
    for s2=(s1+1):numSegments,
        
        if norm(segments(:,s1)-segments(:,s2))==0 then
            numDoublons = numDoublons+1;
            doublons(:,numDoublons) = [s2];
            test=0;
        end
    end 
    if (test==1) then
        numS = numS+1;
        pasDoublon(:,numS) = s1;
    end
    
end

segments = segments(:,pasDoublon);
buf=numSegments
numSegments = numS



endfunction


function  draw_mesh ( vertices, faces )
numFaces = size(faces,2);
for f=1:numFaces,
  xf(:,f) = vertices(1,faces(:,f)')';
  yf(:,f) = vertices(2,faces(:,f)')';
  zf(:,f) = vertices(3,faces(:,f)')';  
  //colors(:,f)= [0.0 ; 0.005*f*90; 0.0];
end
//f=gcf();
//num_colors = 256;
//f.color_map = jetcolormap( num_colors ); 
//x_min = min(vertices(1,:));
//x_max = max(vertices(1,:));
//x_min = x_min - 0.1*(x_max-x_min);
//x_max = x_max + 0.1*(x_max-x_min);
//colors = ( xf  - x_min ) * num_colors / (x_max - x_min);
//plot3d( xf, yf, list(zf, colors ),  alpha = 180, theta = 90);//, leg ='X@Y@Z'  , flag = [2, 3, 4] , ebox = [-20 20 -20 20 -20 20] );
plot3d( xf, yf, zf,  alpha = 180, theta = 90);
mtlb_axis([min(vertices(1,:))-1.0, max(vertices(1,:))+1.0, min(vertices(2,:))-1.0, max(vertices(2,:))+1.0,min(vertices(3,:))-1.0, max(vertices(3,:))+1.0]);
mtlb_axis('equal');

endfunction



function [colors] = draw_mesh2 ( vertices, faces , Vdata)
numFaces = size(faces,2);
for f=1:numFaces,
  xf(:,f) = vertices(1,faces(:,f)')';
  yf(:,f) = vertices(2,faces(:,f)')';
  zf(:,f) = vertices(3,faces(:,f)')';
  DA(:,f) = Vdata(1,faces(:,f)')';
  //colors(:,f)= [0.0 ; 0.005*f*90; 0.0];
end
//DA=xf;
f=gcf();
//printf('taille xf : %d taille DA : %d',size(xf,1), size(DA,1));
num_colors = 128;
f.color_map = jetcolormap( num_colors ); 
data_min = min(DA);
data_max = max(DA);
data_min = data_min - 0.1 * (data_max - data_min);
data_max = data_max + 0.1 * (data_max - data_min);
colors = ( DA  - data_min  ) * num_colors / (data_max - data_min);
plot3d( xf, yf, list(zf, colors ),  alpha = 180, theta = 90);//, leg ='X@Y@Z'  , flag = [2, 3, 4] , ebox = [-20 20 -20 20 -20 20] );
//plot3d( xf, yf, zf,  alpha = 180, theta = 90);
mtlb_axis([min(vertices(1,:))-1.0, max(vertices(1,:))+1.0, min(vertices(2,:))-1.0, max(vertices(2,:))+1.0,min(vertices(3,:))-1.0, max(vertices(3,:))+1.0]);
mtlb_axis('equal');

endfunction


function [colors] = draw_mesh3 ( vertices, faces , Fdata)
numFaces = size(faces,2);
for f=1:numFaces,
  xf(:,f) = vertices(1,faces(:,f)')';
  yf(:,f) = vertices(2,faces(:,f)')';
  zf(:,f) = vertices(3,faces(:,f)')';
end
DA=Fdata;
f=gcf();
//printf('taille xf : %d taille DA : %d',size(xf,1), size(DA,1));
num_colors = 128;
f.color_map = jetcolormap( num_colors ); 
data_min = min(DA);
data_max = max(DA);
data_min = data_min - 0.1 * (data_max - data_min);
data_max = data_max + 0.1 * (data_max - data_min);
colors = ( DA  - data_min  ) * num_colors / (data_max - data_min);
plot3d( xf, yf, list(zf, colors ),  alpha = 180, theta = 90);//, leg ='X@Y@Z'  , flag = [2, 3, 4] , ebox = [-20 20 -20 20 -20 20] );
//plot3d( xf, yf, zf,  alpha = 180, theta = 90);
mtlb_axis([min(vertices(1,:))-1.0, max(vertices(1,:))+1.0, min(vertices(2,:))-1.0, max(vertices(2,:))+1.0,min(vertices(3,:))-1.0, max(vertices(3,:))+1.0]);
mtlb_axis('equal');

endfunction


function [colors] = draw_mesh4 ( vertices, faces , Fdata, max_data)
numFaces = size(faces,2);
for f=1:numFaces,
  xf(:,f) = vertices(1,faces(:,f)')';
  yf(:,f) = vertices(2,faces(:,f)')';
  zf(:,f) = vertices(3,faces(:,f)')';
end
DA=Fdata;
f=gcf();
//printf('taille xf : %d taille DA : %d',size(xf,1), size(DA,1));
num_colors = 128;
f.color_map = jetcolormap( num_colors ); 
data_min = min(DA);
data_max = max_data;
data_min = data_min - 0.1 * (data_max - data_min);
data_max = data_max + 0.1 * (data_max - data_min);
colors = ( DA  - data_min  ) * num_colors / (data_max - data_min);
plot3d( xf, yf, list(zf, colors ),  alpha = 180, theta = 90);//, leg ='X@Y@Z'  , flag = [2, 3, 4] , ebox = [-20 20 -20 20 -20 20] );
//plot3d( xf, yf, zf,  alpha = 180, theta = 90);
mtlb_axis([min(vertices(1,:))-1.0, max(vertices(1,:))+1.0, min(vertices(2,:))-1.0, max(vertices(2,:))+1.0,min(vertices(3,:))-1.0, max(vertices(3,:))+1.0]);
mtlb_axis('equal');

endfunction


////%%%%%%%%%%%%%%%%%% corrections %%%%%%%%%%%%%%%%%%%%%
//MAXvertices = max(faces);
//MaxV = max (MAXvertices);
//if (MaxV>numVertices),
//    for i=numVertices:MaxV+1,
//        vertices(i,:) = vertices(numVertices,:);
//    end
//    numVertices = MaxV+1;
//end
//
//




