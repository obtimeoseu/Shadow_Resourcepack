#version 150

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    
    if(textureSize(Sampler0, 0) == ivec2(16, 16) && gl_FragCoord.z != 0.5) {
        //color.r = 0.1;
        //color.g = 0.1;
        //color.b = 0.1;
        //color.a = 1;
        color *= vec4(1.0, 0.0, 0.0, 1.0);
    } else  {
        color *= ColorModulator;
    }
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color;
}
