#version 150

#moj_import <fog.glsl>
#moj_import <utils.glsl>

uniform sampler2D Sampler0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;
in float part;

in float zPos;
flat in int isGui;
in vec4 tintColor;
in vec4 screenPos;

out vec4 fragColor;

void main() {
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    alpha = 255; // 말 같은 엔티티 투명도 조건 안따지도록 

    vec2 screenSize = gl_FragCoord.xy / (screenPos.xy/screenPos.w*0.5+0.5);
    vec4 screenFragCoord = gl_FragCoord;
    
    vec4 color = showRedAndGray(texture(Sampler0, texCoord0), FogColor, isGui);
    if (color.a < 0.1 || abs(mod(part + 0.5, 1.0) - 0.5) > 0.001) {
        discard;
    }
    if (color.a < 1.0 && part > 0.5) {
        vec4 color2 = texture(Sampler0, texCoord1);
        if (color.a < 0.75 && int(gl_FragCoord.x + gl_FragCoord.y) % 2 == 0) {
            discard;
        }
        else {
            color.rgb = mix(color2.rgb, color.rgb, min(1.0, color.a * 2));
            color.a = 1.0;
        }
    }
    if(!adjacentCheck(alpha, 241.0) && !adjacentCheck(alpha, 242.0) ) {
        color *= showRedAndGray(vertexColor, FogColor, isGui) * ColorModulator;
    }

    color = apply_emissive_perspective_for_item(color, lightMapColor, tintColor, vertexColor, vertexDistance, zPos, isGui, FogStart, FogEnd, alpha, screenSize, screenFragCoord, GameTime);
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

    // 가까이 있을때 가리기
    if(isGui == 0) {
        if(adjacentCheck(alpha, 241.0)) {
            float dis = 0.8;
            float blur = 0.2;
            if(screenPos.z < dis) {
                discard;
            }
            if(screenPos.z < dis + blur) {
                fragColor.a *= (screenPos.z - dis) / blur;
            }
        }
        if(adjacentCheck(alpha, 240.0)) {
            float dis = 0.8;
            float blur = 0.2;
            if(screenPos.z < dis) {
                discard;
            }
            if(screenPos.z < dis + blur) {
                fragColor.a *= (screenPos.z - dis) / blur;
            }
        }
        if(adjacentCheck(alpha, 239.0)) {
            float dis = 0.8;
            float blur = 0.2;
            if(screenPos.z < dis) {
                discard;
            }
            if(screenPos.z < dis + blur) {
                fragColor.a *= (screenPos.z - dis) / blur;
            }
        }
    }
}
