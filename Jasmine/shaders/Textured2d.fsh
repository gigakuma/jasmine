varying lowp vec4 colorVarying;

varying lowp vec2 texcoordVarying;
uniform sampler2D texture;

void main(void) {
    gl_FragColor = colorVarying * texture2D(texture, texcoordVarying);
}