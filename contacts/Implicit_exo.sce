getd();


global noeuds;
global noeudsDeplaces;
global g ;
global m ;
global k;
global dt;
global segments;
global L0;
global _MYDATA_;

function [value] = cost(dV)
    

    numNoeuds = size(noeuds,2);  
    
    F_t = zeros(2*numNoeuds,1);
    

    
    // force inertielle + gravité
    for i=1:numNoeuds
        F_t([2*i-1 2*i]) = F_t([2*i-1 2*i]) + m*dV([2*i-1 2*i])/dt  + m*[0; g];
    end
    
    // fixation de certain noeuds;
    for i=1:numNoeuds
        P = noeuds(:,i);
        if (P(1)==5),
            dV([2*i-1]) = 0;
            dV([2*i]) =0;
        end
        
        
    end
    
    // integration
    V_t = _MYDATA_.V_t + dV;  
    X_t = _MYDATA_.X_t + V_t*dt;
   
    numSegments = size(segments,2);
    L=[];
    for s=1:numSegments,
        i1= segments(1,s);
        i2= segments(2,s);
        // longueur actuelle
        L(s) = norm( X_t([2*i1-1 2*i1]) - X_t([2*i2-1 2*i2]) )
        // normale actuelle
        n = (X_t([2*i1-1 2*i1]) - X_t([2*i2-1 2*i2]))*(1.0/L(s));
        // vitesse relative actuelle
//        V = n' * (V_t([2*i1-1 2*i1]) - V_t([2*i2-1 2*i2]))
        // force du ressort
        F = n*(k*(L(s)-L0(s)))// + d*V)
        
        // ajout de la force dans le vecteur
        F_t([2*i1-1 2*i1]) = F_t([2*i1-1 2*i1])  + F;
        F_t([2*i2-1 2*i2]) = F_t([2*i2-1 2*i2])  - F;
        
    end
    
   
    
    
    // fixation de certain noeuds;
    for i=1:numNoeuds
        P = noeuds(:,i);
        if (P(1)==5),
            F_t([2*i-1]) = 0;
            F_t([2*i]) =0;
        end
        
        
    end
    
    
    
    value = F_t;
    
    
endfunction




// MAILLAGE //
[ noeuds , elements ] = MSHLoader('rectangle1.msh');
noeudsDeplaces = noeuds;

// parametres physiques

k=1000;
m=1;
g=9.81;
// parametres temps
dt = 0.01;
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

    // Euler
    V_t = V_t + dV;    
    X_t = X_t + V_t*dt;
    _MYDATA_.V_t = V_t;
    _MYDATA_.X_t = X_t;
  

    
    [dV,F, info] = fsolve(dV, cost) 
    
        

    // déplacement du maillage
    noeudsDeplaces = noeuds;
    for i=1:numNoeuds,
      // deplacement selon x
      noeudsDeplaces(1,i) = X_t(2*i-1);
      // deplacement selon y
      noeudsDeplaces(2,i) = X_t(2*i);  
    end      
    
    clf;
    scf(0);
    draw_mesh( noeudsDeplaces, elements)
    
    // draw obstacle
    x=[-1:3:5]
    y=ones(1,3)*-1
    plot(x,y)

    k_t=k_t+1;
    
    S(2) = string(k_t+99);
    xs2bmp(0,strcat(S));
    xpause(100);


end

  
  
  
  

  




