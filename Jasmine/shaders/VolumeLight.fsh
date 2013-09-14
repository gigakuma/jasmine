uniform lowp float exposure;
uniform lowp float decay;
uniform lowp float density;
uniform lowp float weight;
uniform lowp vec2 lightPositionOnScreen;

uniform sampler2D texture;
//const int NUM_SAMPLES = 10;

varying lowp vec2 texcoordVarying;

void main()
{
    //gl_TexCoord[0].st
//    lowp vec2 deltaTextCoord = vec2(texcoordVarying - lightPositionOnScreen.xy);
//    lowp vec2 textCoord = texcoordVarying;
//    deltaTextCoord *= 1.0 /  float(NUM_SAMPLES) * density;
//    lowp float illuminationDecay = 1.0;
//    gl_FragColor = vec4(0);
//
//    for (int i = 0; i < NUM_SAMPLES; i++)
//    {
//        textCoord -= deltaTextCoord;
//        lowp vec4 sample = texture2D(texture, textCoord);
//
//        sample *= illuminationDecay * weight;
//
//        gl_FragColor += sample;
//
//        illuminationDecay *= decay;
//    }
//
//    gl_FragColor *= exposure;
    
    lowp vec4 color = texture2D(texture, texcoordVarying);
//    color.r = pow(2.0, color.r) - 1.0;
//    color.g = pow(2.0, color.g) - 1.0;
//    color.b = pow(2.0, color.b) - 1.0;
    
    gl_FragColor = color;
}