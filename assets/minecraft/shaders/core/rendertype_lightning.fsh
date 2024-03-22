#version 150

#moj_import <fog.glsl>

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;

in float vertexDistance;
in vec4 vertexColor;

out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    if(color.r > color.g) {
        color.r = color.g;
        color.b /= 2;
        color.r /= 2;
    } else if(color.r == color.g) {
        color.rgb = vec3(2 * pow(color.a, 1.5), 0.0, 0.0);
    }
    color *= ColorModulator * linear_fog_fade(vertexDistance, FogStart, FogEnd);
    fragColor = color;
}
