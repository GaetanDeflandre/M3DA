#include "SubdivCurve.h"
#include <cmath>
#include <iostream>

#include "Vector3.h"
#include "Matrix4.h"

using namespace std;
using namespace p3d;

SubdivCurve::~SubdivCurve() {
}

SubdivCurve::SubdivCurve() {
    _nbIteration=1;
    _source.clear();
    _result.clear();

}


void SubdivCurve::addPoint(const p3d::Vector3 &p) {
    _source.push_back(p);
}

void SubdivCurve::point(int i,const p3d::Vector3 &p) {
    _source[i]=p;
}


void SubdivCurve::chaikinIter(const vector<Vector3> &p) {
    /* TODO : one iteration of Chaikin : input = p, output = you must set the vector _result (vector of Vector3)
   */
    _result.clear();


    unsigned len = p.size();

    if(isClosed()){
        _result.resize(len*2);
    } else {
        _result.resize(len*2 - 2);
    }

    unsigned i;
    for(i=0; i<len-1; i++){
        _result[i*2] = (3*p[i])/4.0 + p[i+1]/4.0;
        _result[i*2 + 1] = p[i]/4.0 + (3*p[i+1])/4.0    ;
    }

    if(isClosed()){
        _result[i*2] = (3*p[i])/4.0 + p[0]/4.0;
        _result[i*2 + 1] = p[i]/4.0 + (3*p[0])/4.0;
    }

}

void SubdivCurve::dynLevinIter(const vector<Vector3> &p) {
    /* TODO : one iteration of DynLevin : input = p, output = you must set the vector _result (vector of Vector3)
   */
    _result.clear();

    unsigned len = p.size();
    _result.resize(len*2);

    unsigned i;
    for(i=0; i<len; i++){
        _result[2*i] = p[i];
        _result[2*i + 1] = ((-1.0/16.0) * (p[(i+2)%len] + p[(len + i-1)%len])) + ((9.0/16.0) * (p[(i+1)%len] + p[i]));
    }

}


void SubdivCurve::chaikin() {
    if (_source.size()<2) return;
    vector<Vector3> current;
    _result=_source;
    for(int i=0;i<_nbIteration;++i) {
        current=_result;
        chaikinIter(current);
    }
}

void SubdivCurve::dynLevin() {
    if (_source.size()<2) return;
    if (!isClosed()) return;
    vector<Vector3> current;
    _result=_source;
    for(int i=0;i<_nbIteration;++i) {
        current=_result;
        dynLevinIter(current);
    }
}


