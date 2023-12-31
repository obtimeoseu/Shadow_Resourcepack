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
in vec4 tintColor;

out vec4 fragColor;

/*
Slimes,
Players (except for the lower layer of the arm in first person),
Player heads,
Markings on horses,
Shulker bullets,
Elder guardian particle effect.
*/
void main() {
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    vec4 color = showRedAndGray(texture(Sampler0, texCoord0), FogColor, isGui);
    color *= showRedAndGray(vertexColor, FogColor, isGui) * ColorModulator;
    color = apply_emissive_perspective_for_item(color, lightMapColor, tintColor, vertexDistance, zPos, isGui, FogStart, FogEnd, alpha);
    if (color.a < 0.1) {
        discard;
    }
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
