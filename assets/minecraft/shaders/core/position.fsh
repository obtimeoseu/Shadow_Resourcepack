#version 150

#moj_import <fog.glsl>

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 color;

out vec4 fragColor;

void main() {
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    //fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
