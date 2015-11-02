TP1: Cylindre Généralisé
========================

## Auteur

- DEFLANDRE Gaëtan


## Détails

- ce que vous n'avez pas fait (et pourquoi).
  - la partie sur les normales ne fonctionne pas.
- difficultés rencontrées.
  - calcul de la normale

Lors de mon calcul de la normale, les extrusions restent noires et
rouges à l'intérieur, quelque soit les valeurs de _sectionNormal.

### Calcul de la normale:

Soit segment définit par P1(x1,y1) et P2(x2,y2).

Alors, la direction:
dx = x2-x1
dy = y2-y1

Et la normale:
n1 = (-dy, dx)
n2 = (dy, -dx)

En moyennant n1 et n2, s'il ne sont pas null.

