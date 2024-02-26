#version 150

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    if(textureSize(Sampler0, 0) == ivec2(16, 16)) {
        color.a = 1;
        //color.r = 1;
        //color.g = 1;
        //color.b = 1;
    } else  {
        color *= ColorModulator;
    }
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color;
}
