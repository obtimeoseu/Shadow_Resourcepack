#version 150

#moj_import <fog.glsl>

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 color;

out vec4 fragColor;
// The colour of the sky. Also affects text highlighting.
void main() {
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
    //fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
