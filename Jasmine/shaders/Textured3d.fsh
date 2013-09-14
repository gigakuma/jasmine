varying lowp vec4 colorVarying;

varying lowp vec2 texcoordVarying;
uniform sampler2D texture;

void main(void) {
    lowp vec4 color = colorVarying * texture2D(texture, texcoordVarying);
    color = color + color;
    gl_FragColor = color;
}