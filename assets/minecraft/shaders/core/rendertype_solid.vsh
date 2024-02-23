#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
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
    
    vec3 pos = Position + ChunkOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
    screenPos = gl_Position;

    //if(tintColor.rgb == vec3(255, 255, 254) / 255.0) {
        //gl_Position.z = 0 + gl_Position.z * 0.001;
    //}

    vertexDistance = fog_distance(ModelViewMat, pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
