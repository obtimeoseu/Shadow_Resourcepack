#version 150

#moj_import <utils.glsl>

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;

flat out vec2 flatCorner;
out vec4 Coords;
out vec2 position;
out vec2 Pos1;
out vec2 Pos2;
flat out int type;

void main() {
    int id = gl_VertexID % 4;

    Coords = vec4(-1);
    position, Pos1, Pos2, flatCorner = vec2(-1);
    vec3 Pos = vec3(-1);
    vec2 ScrSize = 2 / vec2(ProjMat[0][0], -ProjMat[1][1]);
    const vec2[4] corners = vec2[4](vec2(0), vec2(0, 1), vec2(1, 1), vec2(1, 0));
    type = 0;

    vertexColor = Color;

    // gui 하이라이트
    if( compareColor( Color, vec4(255, 255, 255, 128) / 255.0) ) {
        // 일반 인벤토리 하이라이트
        if( Position.z == 0 ) {
            /*
            Pos = Position + vec3(corners[id] * 2 - 1, 0);

            Pos1 = Pos2 = vec2(0);
            if (id == 0) Pos1 = Pos.xy;
            if (id == 2) Pos2 = Pos.xy;

            Coords.xy = ScrSize;
            Coords.zw = flatCorner = corners[id];
            position = Pos.xy;
            */
            type = 1;
            gl_Position = ProjMat * ModelViewMat * vec4(Pos, 1.0);
        } else
        // 번들 하이라이트
        if ( Position.z == 400 ) {
            vertexColor = vec4(0.0);
        }
        gl_Position = ProjMat * ModelViewMat * vec4(Pos, 1.0);
    } else

    // 쿨다운
    if( compareColor( Color, vec4(255, 255, 255, 127) / 255.0) ) {
        if(
            Position.z == 0 || // 핫바 한개
            Position.z == 200  // 핫바 여러개
        ) {
            vertexColor.a = 0.0; // 핫바상에 보이는 쿨타임 제거
        } else
        if(
            Position.z == 100 || // 인벤토리 한개
            Position.z == 300 || // 인벤토리 여러개
            Position.z == 400 || // 번들 한개
            Position.z == 600 || // 번들 여러개
            Position.z == 232 || // 마우스 커서 한개
            Position.z == 432    // 마우스 커서 여러개
        ) {
            vertexColor.a = 0.0; // 인벤상에 보이는 쿨타임 제거
        }
    } else
    if ( ProjMat[3][0] == -1 && Color.a == 1.0 && ( Position.z == 0 || Position.z == 100 || Position.z == 400 || Position.z == 232 ) ) {
        // 내구도 검정색 바, 옵션 
        if( compareColor( Color, vec4(0, 0, 0, 255) / 255.0) ) {
            //vertexColor.a = 0.0;
        } else
        // 번들 파란색 바
        if( compareColor( Color, vec4(102, 102, 255, 255) / 255.0) ) {
            //vertexColor.a = 0.0;
        }
        // 실제 내구도
        else {
            if(Color.r != Color.g || Color.r != Color.b || Color.g != Color.b) {
                /*
                Pos = Position;
                Pos.y += 2;
                Pos.x -= 2;
                if (id == 1 || id == 2) Pos.y -= 15;
                if (id == 1 || id == 0) Pos.x += 1;

                Pos1 = Pos2 = vec2(0);
                if (id == 0) Pos1 = Pos.xy;
                if (id == 2) Pos2 = Pos.xy;

                Coords.xy = ScrSize;
                Coords.zw = flatCorner = corners[id];
                position = Pos.xy;

                type = 3;
                gl_Position = ProjMat * ModelViewMat * vec4(Pos, 1.0);
                */
            }
        }
    }
    
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

}
