#version 150

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;

out vec4 Coords;
out vec2 position;

flat out vec2 flatCorner;
out vec2 Pos1;
out vec2 Pos2;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexColor = Color;
    
    Coords = vec4(-1);
    position, Pos1, Pos2, flatCorner = vec2(-1);

    // Tooltip 수정
    if (Color.r != 0 && Color.g == 0 && Color.b != 0 && ProjMat[3][0] == -1)
    {
        int id = gl_VertexID / 4;
        int vertID = (gl_VertexID) % 4;
        const vec2[4] corners = vec2[4](vec2(0), vec2(0, 1), vec2(1, 1), vec2(1, 0));
        vec2 ScrSize = 2 / vec2(ProjMat[0][0], -ProjMat[1][1]);
        vec3 Pos = Position; // + vec3(corners[vertID] * -10 + 5, 0);
        
        if(vertID == 0 || vertID == 1) { Pos.x += 5; } // 오른쪽 늘리기
        if(vertID == 2 || vertID == 3) { Pos.x -= 5; } // 왼쪽 늘리기
        if(vertID == 1 || vertID == 2) { Pos.y -= 3; } // 위로 늘리기
        if(vertID == 0 || vertID == 3) { Pos.y += 3; } // 아래로 늘리기
        
        Pos1 = Pos2 = vec2(0);
        if (vertID == 0) Pos1 = Pos.xy;
        if (vertID == 2) Pos2 = Pos.xy;

        Coords.xy = ScrSize;
        Coords.zw = flatCorner = corners[vertID];
        position = Pos.xy;

        if (id != 2)
            Pos.xy = vec2(0);        
    
        gl_Position = ProjMat * ModelViewMat * vec4(Pos, 1.0);
    }
}
