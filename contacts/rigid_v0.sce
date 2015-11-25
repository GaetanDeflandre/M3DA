function [A]=ComputeSurface(P1,P2,P3)

// matrice pour créer les fonctions d'interpolation
Matrice = [ 1  1  1;
            P1(1) P2(1) P3(1);
            P1(2) P2(2) P3(2)];

// matrice des fonctions d'interpolation linéaire
A= abs(det(Matrice))/2;
endfunction


getd();
clear all;
// MAILLAGE //
[ noeuds , elements ] = MSHLoader('circle.msh');
numElements = size(elements,2);
numNoeuds = size(noeuds,2);     



// calcul de la masse (et du centre de gravité...)
G=[0;0];
TotalSurf=0;
M=zeros(numNoeuds,1);
mass_vol= 0.027; // alu (kg/cm^3)
epaisseur=0.5;
rayon=5;

/// faire ici un calcul pour obtenir une valeur correcte sur mG (masse du centre de Gravité) ///

volume = %pi * rayon * rayon * epaisseur;
mG = volume* mass_vol;

//acceleration (2D) / vitesse (2D) / position  du centre de gravité
aG=[0;0];
vG=[0;0];
pG=[-5;5];


dt = 0.002;
T =  0.2;

// paramètres pour la pénalité
k=10000;
b=20;

// gif de sortie
S = [];
S(1) = 'GIF3\rigidanim';
t=100;
S(2) = string(t);
S(3) = '.gif';

// calcul des forces de contact rapporté au centre de gravité
FC=[0;0];

k_t=0
for time=0:dt:T,
  
  
    // calcul de la dynamique d'un corps rigide  (intégration explicite)
    aG = ([0;-981]*mG + FC) / mG;   
    vG = vG + aG*dt;
    pG = pG + vG*dt;
    
    // calcul des forces de contact rapporté au centre de gravité
    FC=[0;0];
    
    // calculer le déplacement du maillage en fonction du déplacement du centre de gravité
    noeuds_deplaces = noeuds;

    for i=1:numNoeuds,
      // deplacement selon x
      noeuds_deplaces(1,i) = pG(1) + noeuds_deplaces(1,i);
      // deplacement selon y
      noeuds_deplaces(2,i) = pG(2) + noeuds_deplaces(2,i);
      
      distance = noeuds_deplaces(2,i) + 2;
      
      if distance <= 0 then
          FC(2) = FC(2) - k * distance;// - b * vG(2);
      end;
    end;


    clf;
    
    a = scf(0);
    //a=get("current_axes");//get the handle of the newly created axes

    draw_mesh( noeuds_deplaces, elements);
    // draw obstacle    
    x=[-10:10:10];
    y=ones(1,3)*-2;
    plot(x,y);
    
    plot(pG(1),pG(2),'x');

    //a.children.data_bounds=[-10,-10;10,10];
    
    k_t=k_t+1;
    S(2) = string(k_t+99);
    xs2gif(0,strcat(S));
    
    xpause(1000);

end



