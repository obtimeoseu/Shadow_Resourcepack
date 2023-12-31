#version 150

#moj_import <fog.glsl>
#moj_import <utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 normal;

in float zPos;
flat in int isGui;

out vec4 fragColor;

void main() {
    vec4 color = showRedAndGray(texture(Sampler0, texCoord0), FogColor, isGui);
    if (color.a < 0.1) {
        discard;
    }
    color *= showRedAndGray(vertexColor, FogColor, isGui) * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    color *= lightMapColor;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
