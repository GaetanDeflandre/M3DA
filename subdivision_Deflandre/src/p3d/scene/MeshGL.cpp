#include "MeshGL.h"
#include "GLTool.h"
#include "Tools.h"

#include "glsupport.h"
#include "Vector2.h"


#include <iostream>

using namespace std;


/*!
*
* @file
*
* @brief
* @author F. Aubert
*
*/

using namespace p3d;
using namespace std;

MeshGL::~MeshGL() {
  // keep the if !!! (when called outside opengl context... or crashed).
  if (_allAttribBuffer) glDeleteBuffers(1,&_allAttribBuffer);
}

MeshGL::MeshGL(Mesh *mesh) {
  _mesh=mesh;
  _allAttribBuffer=0;
  _vao=0;
  _nbVertex=0;
}


void MeshGL::drawLine(double scale) {
  vector<Vector3> toDraw;
  for(unsigned int i=0;i<_mesh->nbFace();++i) {
    Vector3 g(0,0,0);
    for(unsigned int j=0;j<_mesh->nbVertex(i);++j) {
      g+=_mesh->positionMesh(i,j);
    }
    g/=_mesh->nbVertex(i);
    for(unsigned int j=0;j<_mesh->nbVertex(i);++j) {
      toDraw.push_back((_mesh->positionMesh(i,j)-g)*scale+g);
      toDraw.push_back((_mesh->positionMesh(i,j+1)-g)*scale+g);
    }
  }
  p3d::drawLines(toDraw);
}

void MeshGL::draw() {
  if (_requestInitBuffer) initBuffer();
  drawBuffer();
}

void MeshGL::initBuffer() {
  glDeleteVertexArrays(1,&_vao);
  glGenVertexArrays(1,&_vao);
  _nbVertex=0;
  for(unsigned int i=0;i<_mesh->nbFace();++i) {
    for(unsigned int j=0;j<_mesh->nbVertex(i);++j) {
      _nbVertex++;
    }
  }

  float *allAttrib;
  allAttrib=new float[_nbVertex*8]; // 3 position+3normal+2texCoord

  unsigned int iV=0;
  for(unsigned int i=0;i<_mesh->nbFace();++i) {
    for(unsigned int j=0;j<_mesh->nbVertex(i);++j) {
      allAttrib[iV*8+0]=_mesh->positionMesh(i,j).x();
      allAttrib[iV*8+1]=_mesh->positionMesh(i,j).y();
      allAttrib[iV*8+2]=_mesh->positionMesh(i,j).z();

      allAttrib[iV*8+3]=_mesh->normalMesh(i,j).x();
      allAttrib[iV*8+4]=_mesh->normalMesh(i,j).y();
      allAttrib[iV*8+5]=_mesh->normalMesh(i,j).z();

      allAttrib[iV*8+6]=_mesh->texCoordMesh(i,j).x();
      allAttrib[iV*8+7]=_mesh->texCoordMesh(i,j).y();
      ++iV;
    }
  }

  glDeleteBuffers(1,&_allAttribBuffer);
  glBindVertexArray(_vao);
  glEnableVertexAttribArray(0); // should be position in shader
  glEnableVertexAttribArray(1); // should be normal in shader
  glEnableVertexAttribArray(2); // should be texCoord in shader

  glGenBuffers(1,&_allAttribBuffer);
  glBindBuffer(GL_ARRAY_BUFFER,_allAttribBuffer);
  glBufferData(GL_ARRAY_BUFFER,_nbVertex*sizeof(float)*8,allAttrib,GL_STATIC_DRAW);

  glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,8*sizeof(float),0); // 0 = position
  glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,8*sizeof(float),(const GLvoid *)(3*sizeof(float))); // 1 = normal
  glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,8*sizeof(float),(const GLvoid *)(6*sizeof(float))); // 2 = texCoord

  glBindVertexArray(0);
  delete[] allAttrib;
  _requestInitBuffer=false;
}


void MeshGL::drawBuffer() {
  glBindVertexArray(_vao);

  glDrawArrays(GL_TRIANGLES,0,_nbVertex);

  glBindVertexArray(0);
}

void MeshGL::drawNormal(double kLength) {
    vector<Vector3> pts;
    for(unsigned int i=0;i<_mesh->nbFace();++i) {
        for(unsigned int j=0;j<_mesh->nbVertex(i);++j) {
            pts.push_back(_mesh->positionMesh(i,j));
            pts.push_back(_mesh->positionMesh(i,j)+kLength*_mesh->normalMesh(i,j));
        }
    }
    p3d::ambientColor=Vector4(1,0,0,1);
    p3d::shaderVertexAmbient();
    p3d::drawLines(pts);
}


