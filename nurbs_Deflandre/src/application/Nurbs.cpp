#include "Nurbs.h"
#include <cmath>
#include <iostream>

#include "Vector3.h"
#include "Matrix4.h"

using namespace std;
using namespace p3d;

Nurbs::~Nurbs() {
}

Nurbs::Nurbs() {
    _control.clear();
    _nbControl[D_U]=0;
    _nbControl[D_V]=0;
    _knot[D_U].clear();
    _knot[D_V].clear();
    _degree[D_U]=0;
    _degree[D_V]=0;

}

double Nurbs::startInterval(EDirection direction) {
    return _knot[direction][_degree[direction]];
}

double Nurbs::endInterval(EDirection direction) {
    return _knot[direction][_nbControl[direction]]-0.00001;
}


bool Nurbs::inInterval(EDirection direction, double u) {
    return (u>=startInterval(direction) && u<=endInterval(direction));
}


void Nurbs::knotUniform(EDirection direction,int nb) {
    _knot[direction].resize(nb);
    /* TODO : set uniform knots
    * _knot[direction][i] is the knot u_i for the given direction
    */

    for (int i=0; i<nb; i++) {
        _knot[direction][i] = (double)i/(double)(nb-1);
    }

}


/** Eval the basis function Nkp(t) for the knot vector knot **/
double Nurbs::evalNkp(int k,int p,double u,std::vector<double> &knot) {
    double result=0.0;
    /* TODO : compute Nkp(u)
    * - knot[i] : the knot i
    * - p : degree
    * - k : indice of the basis function.
    */

    if(p == 0){

        if(u>=knot[k] && u<knot[k+1]){
            result = 1.0;
        } else {
            result = 0.0;
        }

    } else {

        double fraq1 = ((u-knot[k])/(knot[k+p]-knot[k]));
        double fraq2 = ((knot[p+k+1]-u)/(knot[k+p+1]-knot[k+1]));

        result = fraq1 * evalNkp(k,p-1,u,knot) + fraq2 * evalNkp(k+1,p-1,u,knot);
    }

    return result;
}


double Nurbs::evalNkp(EDirection direction,int k,int p,double t) {
    return evalNkp(k,p,t,_knot[direction]);
}


void Nurbs::clearControl() {
    _nbControl[D_U]=0;
    _nbControl[D_V]=0;
    _control.clear();
}

void Nurbs::initControlGrid() {
    _nbControl[D_U]=5;
    _nbControl[D_V]=4;
    _control.clear();
    double u=-1;
    double v=-1;
    double stepU=2.0/(_nbControl[D_U]-1);
    double stepV=2.0/(_nbControl[D_V]-1);
    for(int i=0;i<_nbControl[D_V];++i) {
        u=-1;
        for(int j=0;j<_nbControl[D_U];++j) {
            _control.push_back(Vector4(u,v,double(rand())/RAND_MAX-0.5,1));
            u+=stepU;
        }
        v+=stepV;
    }
    knotRemap(D_U);
    knotRemap(D_V);
}


void Nurbs::addControlU(const Vector4 &p) {
    _control.push_back(p);
    _nbControl[D_U]++;
    knotRemap(D_U);
}


Vector3 Nurbs::pointCurve(double u) {
    Vector4 result(0,0,0,0);
    /* TODO :
    * - compute P(t) in result. Use the direction D_U only (curve)
    * - control(i) : control points
    * - nbControl(D_U) : number of control points
    * - evalNkp(D_U,k,p,u) to eval basis function
    */

    unsigned len = nbControl(D_U);

    for (unsigned i=0; i<=len; i++){
        result += evalNkp(D_U, i, degree(D_U), u) * control(i);
    }

    return Vector3(result.x(),result.y(),result.z()) / result.w();
}


Vector3 Nurbs::pointSurface(double u,double v) {
    Vector4 result(0,0,0,0);
    /* TODO :
    * - compute P(u,v) in result. Use direction D_U and D_V (surface)
    * - control(i,j) : control points (i= indice in direction U, j=indice in direction V)
    * - nbControl(D_U), nbControl(D_V) to know the number of control points in each direction.
    * - degree(D_U), degree(D_V) to get the degree in each direction.
    * - evalNkp(D_U or D_V,k,p,t) to eval basis function in each direction
    */

    unsigned ulen = nbControl(D_U);
    unsigned vlen = nbControl(D_V);

    for(unsigned l=0; l<vlen; l++) {

        Vector4 pu = Vector4(0,0,0,0);

        for(unsigned k=0; k<ulen; k++) {
            pu += evalNkp(D_U, k, degree(D_U), u) * control(k,l);
        }

        result += evalNkp(D_V, l, degree(D_V), v) * pu;
    }

    return result.project(); // divide by w
}



void Nurbs::knotRemap(EDirection direction) {
    while (!checkNbKnot(direction)) {
        int nb=nbKnot(direction);
        _knot[direction].push_back(_knot[direction][nbKnot(direction)-1]);
        for(unsigned int i=nb-1;i>0;--i) {
            _knot[direction][i]=_knot[direction][i+1]-(_knot[direction][i]-_knot[direction][i-1])*(nb-1)/nb;
        }
    }
}


bool Nurbs::checkNbKnot(EDirection direction) {
    return (nbKnot(direction)>=nbControl(direction)+degree(direction)+1);
}


void Nurbs::knotOpenUniform(EDirection direction) {
    _knot[direction].resize(nbControl(direction)+degree(direction)+1);

    /* TODO : the first and the last knots have a multiplicity of degree */

    double ulen = _knot[direction].size();
    double k = degree(direction);

    //cout << "UNIFORM" << endl;

    for(int i=0; i<ulen; i++) {
        if(i<=k){
            _knot[direction][i] = 0.0;
        } else if (i >= ulen-k-1){
            _knot[direction][i] = 1.0;
        } else {
            int i2 = i-k;
            int len2 = ulen - ((k+1)*2);
            _knot[direction][i] = (double)i2/((double)(len2)+1);
        }
        //cout << "u_" << i << " = " << _knot[direction][i] << endl;
    }

}


void Nurbs::knotBezier(EDirection direction) {

    /* TODO : define a bezier curve : degree = nbControl-1, */

    degree(direction, nbControl(direction)-1);
    knotOpenUniform(direction);

}

void Nurbs::setCircle() {
    /* Have to set : _control, _degree[D_U], _knot[D_U], _nbControl[D_U]
   *
   */
    _control.clear();

    _degree[D_U] = 2;
    _nbControl[D_U] = 7;
    _knot[D_U] = {0.0, 0.0, 0.0, 1.0/3.0, 1.0/3.0, 2.0/3.0, 2.0/3.0, 1.0, 1.0, 1.0};

    double cos60 = cos(60 * (M_PI/180.0));

    _control.push_back(Vector4(0, 0, 0, 1)); //P0
    _control.push_back(Vector4(-0.5, 0, 0, 1) * cos60); //P1
    _control.push_back(Vector4(-0.25, 0.5*sqrt(3.0)/2.0, 0, 1)); //P2
    _control.push_back(Vector4(0, sqrt(3.0)/2.0, 0, 1) * cos60); //P3
    _control.push_back(Vector4(0.25, 0.5*sqrt(3.0)/2.0, 0, 1)); //P4
    _control.push_back(Vector4(0.5, 0, 0, 1) * cos60); //P5
    _control.push_back(Vector4(0, 0, 0, 1)); //P6

}


void Nurbs::setRevolution(int nbV) {
    if (nbV<2) return;
    _nbControl[D_V]=nbV;
    _degree[D_V]=_degree[D_U];
    _control.resize(_nbControl[D_U]*_nbControl[D_V]);
    knotRemap(D_V);
    knotOpenUniform(D_V);

    double stepTheta=360.0/(nbV-1);
    double theta=stepTheta;
    Matrix4 rotate;
    for(int slice=nbControl(D_U);slice<nbControl(D_U)*nbControl(D_V);slice+=nbControl(D_U)) {
        rotate.setRotation(theta,0,1,0);
        for(int istack=0;istack<nbControl(D_U);++istack) {
            _control[slice+istack]=rotate*_control[istack];
        }
        theta+=stepTheta;
    }
}



