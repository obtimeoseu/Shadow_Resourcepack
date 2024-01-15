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
in vec4 normal;

in float zPos;
flat in int isGui;
in vec4 tintColor;

out vec4 fragColor;

void main() {
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    vec4 color = showRedAndGray(texture(Sampler0, texCoord0), FogColor, isGui) * showRedAndGray(vertexColor, FogColor, isGui) * ColorModulator;
    color = apply_emissive_perspective_for_item(color, vec4(1.0), tintColor, vertexDistance, zPos, isGui, FogStart, FogEnd, alpha);

    float fogStart = FogStart;
    float fogEnd = FogEnd;

    if(isGui == 0) {
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
    }
    fragColor = linear_fog(color, vertexDistance, fogStart, fogEnd, FogColor);
}
