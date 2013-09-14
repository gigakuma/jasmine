attribute vec2 position;
attribute vec2 texcoord;

uniform mat4 matrix;
varying lowp vec2 texcoordVarying;

void main()
{
//    gl_TexCoord[0].st = texcoord;
    texcoordVarying = texcoord;
    gl_Position = matrix * vec4(position, 0.0, 1.0);
}