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
    
    dV = dV .* blocked;
    
    // reecrire les equations de newton en implicite
    F_t = m* dV /dt - m*G - Fk(_MYDATA_.X_t + (_MYDATA_.V_t + dV) * dt);
    
    F_t = F_t .* blocked;
    
    value = F_t;
    
endfunction


function [value] = Fk(position)
    
    // mise à zero des forces
    Fk_t = zeros(2*numNoeuds,1);
    
    L=[];
    for s=1:numSegments,
        i1= segments(1,s);
        i2= segments(2,s);
        // longueur actuelle
        L(s) = norm(position([2*i1-1 2*i1]) - position([2*i2-1 2*i2]) )
        // normale actuelle
        n = (position([2*i1-1 2*i1]) - position([2*i2-1 2*i2]))*(1.0/L(s));
        // vitesse relative actuelle
        // V = n' * (V_t([2*i1-1 2*i1]) - V_t([2*i2-1 2*i2]))
        // force du ressort
        F = n*(k*(L(s) - _MYDATA_.L0(s)))// + d*V)
        
        // ajout de la force dans le vecteur
        Fk_t([2*i1-1 2*i1]) = Fk_t([2*i1-1 2*i1])  - F;
        Fk_t([2*i2-1 2*i2]) = Fk_t([2*i2-1 2*i2])  + F;
        
    end
    
    value = Fk_t;
    
endfunction



// MAILLAGE //
[ noeuds , elements ] = MSHLoader('rectangle1.msh');


// parametres physiques
k=5000;
m=1;
g=9.81;
// parametres temps
dt = 0.1;
T =  2.0;


numElements = size(elements,2);
numNoeuds = size(noeuds,2);     


segments = findSegments(elements)
numSegments = size(segments,2);


// etat courant
// historique
F_t = zeros(2*numNoeuds,1);
V_t = zeros(2*numNoeuds,1);
X_t = zeros(2*numNoeuds,1);


for i=1:numNoeuds
     X_t([2*i-1 2*i]) = [noeuds(1,i) ; noeuds(2,i)];
end
_MYDATA_.V_t = V_t;
_MYDATA_.X_t = X_t;


G = zeros(2*numNoeuds,1);
for i=1:numNoeuds,
    G(i*2) = -g;
end


// longueurs au repos
L0=[];
for s=1:numSegments,
    i1= segments(1,s);
    i2= segments(2,s);
    L0(s) = norm( X_t([2*i1-1 2*i1]) - X_t([2*i2-1 2*i2]) )
end

_MYDATA_.L0 = L0;


// les points bloquer
blocked = ones(2*numNoeuds,1);
for i=1:numNoeuds
    if i<6 then
        blocked(2*i - 1) = 0;
        blocked(2*i) = 0;
    end
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
    xs2gif(0,strcat(S));
    xpause(100);


end

  
  
  
  

  




