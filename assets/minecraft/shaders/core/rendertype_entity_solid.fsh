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
The base (not flag) of banners,
Shulker heads,
Books on lecterns/enchantment tables,
Shields,
Beds,
The bell part of bells,
Capes,
Shells of conduits,
Paintings,
Tridents,
The ears on the Deadmau5 skin,
The bottom skin layer of the first-person hand,
The conduit item in the inventory.
*/
void main() {
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    vec4 color = showRedAndGray(texture(Sampler0, texCoord0), FogColor, isGui) * showRedAndGray(vertexColor, FogColor, isGui) * ColorModulator;
    color = apply_emissive_perspective_for_item(color, lightMapColor, tintColor, vertexDistance, zPos, isGui, FogStart, FogEnd, alpha);
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);

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
