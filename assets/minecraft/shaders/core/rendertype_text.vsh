#version 150
#define VSH
//#define RENDERTYPE_TEXT

#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform float GameTime;
uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 baseColor;
out vec4 lightColor;

#moj_import <custom_text/custom_text.glsl>

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    baseColor = Color;
    lightColor = texelFetch(Sampler2, UV2 / 16, 0);

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    
    // 일반 채팅 조명 색 조정
    if(lightColor.r > 0.985) lightColor.r = 1.0;
    if(lightColor.g > 0.985) lightColor.g = 1.0;
    if(lightColor.b > 0.985) lightColor.b = 1.0;
    vertexColor = baseColor * lightColor;

    texCoord0 = UV0;

    if(applyCustomText()) return;

}
