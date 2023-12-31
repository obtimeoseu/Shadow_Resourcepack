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
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

in float zPos;
flat in int isGui;
in vec4 tintColor;

out vec4 fragColor;

// 반투명 아이템, 반투명 엔티티
void main() {
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    vec4 color = showRedAndGray(texture(Sampler0, texCoord0), FogColor, isGui) * showRedAndGray(vertexColor, FogColor, isGui) * ColorModulator;
    color = apply_emissive_perspective_for_item(color, vec4(1.0), tintColor, vertexDistance, zPos, isGui, FogStart, FogEnd, alpha);
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
