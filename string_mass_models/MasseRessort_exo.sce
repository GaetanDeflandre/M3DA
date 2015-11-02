getd();

// MAILLAGE //
[ noeuds , elements ] = MSHLoader('rectangle1.msh');
numElements = size(elements,2);
numNoeuds = size(noeuds,2);     



[segments] = findSegments(elements)
numSegments = size(segments,2);


// parametres physiques
k=10000;
m=1;
g=9.81;

// parametres temps
dt = 0.005;
T =  0.1;



// image de sortie
S = [];
S(1) = 'BMP\anim';
t=50;
S(2) = string(t);
S(3) = '.bmp';
k_t=0;


// vecteur des positions:
X_t = zeros(2*numNoeuds,1);

for i=1:numNoeuds
     X_t([2*i-1 2*i]) = [noeuds(1,i) ; noeuds(2,i)];
end



for time=0:dt:T,

    

    // mouvement de translation uniforme
    for i=1:numNoeuds
        X_t([2*i]) = X_t([2*i]) +0.2;
    end
    
    
        
    // déplacement du maillage
    noeuds_deplaces = noeuds;
    for i=1:numNoeuds,
      // deplacement selon x
      noeuds_deplaces(1,i) = X_t(2*i-1);
      // deplacement selon y
      noeuds_deplaces(2,i) = X_t(2*i);  
    end      
    
    clf;
    scf(0);
    draw_mesh( noeuds_deplaces, elements)
    a=get("current_axes");//get the handle of the newly created axes
    a.data_bounds=[-1,-1;10,10];
        
        
    k_t=k_t+1;    
    S(2) = string(k_t+99);
    xs2bmp(0,strcat(S));

    
    xpause(100000);


end

  
  
  
  

  




