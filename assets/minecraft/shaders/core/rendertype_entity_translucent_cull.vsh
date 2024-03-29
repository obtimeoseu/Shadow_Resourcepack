#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;

out float zPos;
flat out int isGui;
out vec4 tintColor;
out vec4 screenPos;

void main() {
    zPos = Position.z;
    isGui = 0;
    if(abs(ProjMat[3][3] - 1.0) < 0.01) {
        if(zPos > 125.0) {
            isGui = 1; // 일반 gui
        } else {
            isGui = 2; // gui doll
        }
    }
    tintColor = Color;
    
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    screenPos = gl_Position;

    //if(tintColor.rgb == vec3(255, 255, 254) / 255.0) {
        //gl_Position.z = 0 + gl_Position.z * 0.001;
    //}
    
    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    lightMapColor = getDarkerLight(texelFetch(Sampler2, UV2 / 16, 0), isGui);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
