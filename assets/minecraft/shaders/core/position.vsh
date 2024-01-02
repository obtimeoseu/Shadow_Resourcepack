#version 150

#moj_import <fog.glsl>

in vec3 Position;

uniform vec4 ColorModulator;
uniform mat4 ProjMat;
uniform mat4 ModelViewMat;
uniform int FogShape;

out float vertexDistance;
out vec4 color;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(ModelViewMat, Position, FogShape);
    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);

    color = ColorModulator;
    color.g = 0.0;
    //b *= vec3(1.0, 0.0, 1.0);

    if(vertexDistance >= 100 && vertexDistance <= 100.5)
        color = vec4(0.25, 0.0, 0.0, 1.0);
}
