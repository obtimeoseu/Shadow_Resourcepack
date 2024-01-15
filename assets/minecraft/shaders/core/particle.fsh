#version 150

#moj_import <fog.glsl>
#moj_import <utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec2 texCoord0;
in vec4 vertexColor;

out vec4 fragColor;

void main() {
    vec4 color = showRedAndGray(texture(Sampler0, texCoord0), FogColor, 0) * showRedAndGray(vertexColor, FogColor, 0) * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }

    float fogStart = FogStart;
    float fogEnd = FogEnd;

    if(FogColor.g == 0 && FogColor.b == 0) {
        if(FogColor.r * 255 < 1) {
            fogStart = 0.0;
            fogEnd = 20.0;
        } else
        if(FogColor.r * 255 < 2) {
            fogStart = 0.0;
            fogEnd = 50.0;
        } else
        if(FogColor.r * 255 < 3) {
            fogStart = 30.0;
            fogEnd = 80.0;
        }
    }

    fragColor = linear_fog(color, vertexDistance, fogStart, fogEnd, FogColor);
}
