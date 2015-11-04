getd();


global noeuds;
global g ;
global m ;
global k;
global dt;
global segments;
global L0;
global _MYDATA_;

function [value] = Fnl(dV)
    

    numNoeuds = size(noeuds,2);  
    
    F_t = zeros(2*numNoeuds,1);
    
    // reecrire les equations de newton en implicite

    
    value = F_t;
    
    
endfunction




// MAILLAGE //
[ noeuds , elements ] = MSHLoader('rectangle1.msh');


// parametres physiques
k=1000;
m=1;
g=9.81;
// parametres temps
dt = 0.1;
T =  1.0;



numElements = size(elements,2);
numNoeuds = size(noeuds,2);     




segments = findSegments(elements)
numSegments = size(segments,2);




// etat courant
// historique
F_t = zeros(2*numNoeuds,1);
A = zeros(2*numNoeuds,1);
V_t = zeros(2*numNoeuds,1);
X_t = zeros(2*numNoeuds,1);



for i=1:numNoeuds
     X_t([2*i-1 2*i]) = [noeuds(1,i) ; noeuds(2,i)];
end
_MYDATA_.V_t = V_t;
_MYDATA_.X_t = X_t;

// longueurs au repos
L0=[];
for s=1:numSegments,
    i1= segments(1,s);
    i2= segments(2,s);
    L0(s) = norm( X_t([2*i1-1 2*i1]) - X_t([2*i2-1 2*i2]) )
end


// gif de sortie
S = [];
S(1) = 'GIF\anim';
t=100;
S(2) = string(t);
S(3) = '.gif';
k_t=0;

dV = zeros(2*numNoeuds,1);
for time=0:dt:T,

    // Euler implicite 
    V_t = V_t + dV;    
    X_t = X_t + V_t*dt;
    _MYDATA_.V_t = V_t;
    _MYDATA_.X_t = X_t;
  

    // appel a la fonction de resolution de systeme non-lineaire sous scilab...
    [dV,F, info] = fsolve(dV, Fnl) 
    
        

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

    k_t=k_t+1;
    
    S(2) = string(k_t+99);
    xs2bmp(0,strcat(S));
    xpause(100);


end

  
  
  
  

  




