attribute vec3 position; 
attribute vec4 color; 

varying vec4 colorVarying; 

uniform mat4 matrix;

attribute vec2 texcoord;
varying vec2 texcoordVarying;

void main(void) { 
    colorVarying = color; 
    vec4 pos = vec4(position, 1.0);
    gl_Position = matrix * pos;
    texcoordVarying = texcoord;
}