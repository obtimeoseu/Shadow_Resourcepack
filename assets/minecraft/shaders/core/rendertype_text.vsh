#version 150

#moj_import <fog.glsl>
#moj_import <utils.glsl>

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
flat out vec4 baseColor;
flat out vec4 lightColor;
flat out ivec3 conditionColor;

out vec2 scrSize;
out vec3 position;
out vec4 screenPosition;

flat out float applyTextEffect;
flat out float isShadow;
flat out float isMoved;
flat out float changedScale;

struct TextData {
    vec2 characterPosition;
    vec2 localPosition;
    vec3 position;
    vec2 position_2;
    vec2 scrSize;

    vec2 uv;
    vec2 uvMin;
    vec2 uvMax;
    vec2 uvCenter;

    vec4 backColor;
    vec4 topColor;
    vec4 color;

    bool applyTextEffect;
    bool isShadow;
    bool doTextureLookup;
    bool shouldScale;
    bool isMoved;
};

TextData textData;

out vec3 ipos1;
out vec3 ipos2;
out vec3 ipos3;
out vec3 ipos4;

out vec3 uvpos1;
out vec3 uvpos2;
out vec3 uvpos3;
out vec3 uvpos4;

out vec2 p1;
out vec2 p2;
out vec2 coord;
flat out int vert;
flat out int p;

#moj_import <custom_text/custom_text.glsl>

#define TEXT_POSITION_CASE(type) break; case int(type / 4): isMoved = 1.0; textData.isMoved = true;
#define TEXT_EFFECT_CASE(type) break; case int(type / 4):;

void main() {
    // 커스텀 가능한 위치
    position = Position;
    textData.position_2 = vec2(0);
    textData.position = position;

    // 화면 크기
    scrSize = 2 / vec2(ProjMat[0][0], -ProjMat[1][1]);
    textData.scrSize = scrSize;

    // 염색 색
    baseColor = Color;
    textData.color = baseColor;
    textData.backColor = vec4(0.0);
    textData.topColor = vec4(0.0);

    // 조명 색
    lightColor = texelFetch(Sampler2, UV2 / 16, 0);
    // 일반 채팅 조명 색 조정
    if(lightColor.r > 0.985) lightColor.r = 1.0;
    if(lightColor.g > 0.985) lightColor.g = 1.0;
    if(lightColor.b > 0.985) lightColor.b = 1.0;

    // 기본 gl_Position 세팅 (스크린 이펙트용 특수 gl_Position 세팅 코드 내장)
    if (Color.xyz == vec3(251, 255, 255) / 255) {
        gl_Position = ProjMat * ModelViewMat * vec4(position, 1.0);
        baseColor = vec4(1.0);
        lightColor = vec4(1.0);
    } else
    if (Color.xyz == vec3(62, 63, 63) / 255) {
        gl_Position = vec4(0);
        return;
    } else
    if (Color.xyz == vec3(255., 254., 253.) / 255.) {
        position.xy += 1;
        gl_Position = ProjMat * ModelViewMat * vec4(position, 1.0);
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(position, 1.0);
    }
    
    // fsh로 넘길 색
    vertexColor = baseColor;

    // 텍스트 속성
    applyTextEffect = 1.0;
    textData.applyTextEffect = true;
    isShadow = 0.0;
    textData.isShadow = false;
    changedScale = 0.0;
    textData.shouldScale = false;
    isMoved = 0.0;
    textData.isMoved = false;

    // 그림자 판정
    // 일부 위치 1.20.5에서 바뀔 수 있음
    if(position.z == 0.0) { // 세팅 | 보스바 | 액션바 | 타이틀 텍스트 그림자, 스코어보드, gui, F3, 레벨
        if( // 스코어보드 스코어 제거
            gl_Position.x >= 0.95 && gl_Position.y >= -0.38 && gl_VertexID <= 15 &&
            compareColor(baseColor, vec4(255.0, 85.0, 85.0, 255) / 255.0)
        ) {
            applyTextEffect = 0.0;
            vertexColor.a = 0.0;
            baseColor.a = 0.0;
        }

        isShadow = 1.0;
        if( // 색 밝을 경우 그림자 아닌것으로 판정
            baseColor.r > 63 / 255.0 &&
            baseColor.g > 63 / 255.0 &&
            baseColor.b > 63 / 255.0
        ) {
            isShadow = 0.0;
        }
    } else
    if(position.z == 0.03) { // 세팅 | 보스바 | 액션바 | 타이틀 텍스트, 보스바 텍스트
        isShadow = 0.0;
    } else
    if(position.z == 100.0) { // 일반 채팅 그림자
        isShadow = 1.0;
    } else
    if(position.z == 100.03) { // 일반 채팅
        isShadow = 0.0;
    } else
    if(position.z == 200.0) { // 발전과제 텍스트 그림자, 발전과제 설명
        isShadow = 1.0;
        if( // 색 밝을 경우 그림자 아닌것으로 판정
            baseColor.r > 63 / 255.0 &&
            baseColor.g > 63 / 255.0 &&
            baseColor.b > 63 / 255.0
        ) {
            isShadow = 0.0;
        }
    } else
    if(position.z == 200.03) { // 발전과제 텍스트
        isShadow = 0.0;
    } else
    if(position.z == 300.0) { // gui 내부 아이템 갯수 텍스트 그림자
        isShadow = 1.0;
    } else
    if(position.z == 300.03) { // gui 내부 아이템 갯수 텍스트
        isShadow = 0.0;
    } else
    if(position.z == 400.0) { // 아이템 툴팁 텍스트 그림자
        isShadow = 1.0;
    } else
    if(position.z == 400.03) { // 아이템 툴팁 텍스트
        isShadow = 0.0;
    } else
    if(position.z == 800.0) { // 레시피, 발전과제 텍스트
        isShadow = 0.0;
    } else
    if(position.z < 0) { // 텍스트 디스플레이, 표지판, 지도
        isShadow = 0.0;
        applyTextEffect = 0.0;
        textData.applyTextEffect = false;
        //if( // 색 어두울 경우 그림자로 판정
        //    baseColor.r < 64 / 255.0 &&
        //    baseColor.g < 64 / 255.0 &&
        //    baseColor.b < 64 / 255.0
        //) {
        //    isShadow = 1.0;
        //}
    }

    conditionColor = ivec3(
        int(round(baseColor.r * 255.0) / 4),
        int(round(baseColor.g * 255.0) / 4),
        int(round(baseColor.b * 255.0) / 4)
    );
    if(isShadow == 1.0) {
        conditionColor = ivec3(
            int(round(baseColor.r * 255.0)),
            int(round(baseColor.g * 255.0)),
            int(round(baseColor.b * 255.0))
        );
        textData.isShadow = true;
    }
    
    if(applyTextEffect == 1.0) {
        if( // 기본 바닐라 색코드일 경우
            compareColor(conditionColor.rgb, vec3(00, 00, 00)) || // §0 black
            compareColor(conditionColor.rgb, vec3(00, 00, 42)) || // §1 dark_blue
            compareColor(conditionColor.rgb, vec3(00, 42, 00)) || // §2 dark_green
            compareColor(conditionColor.rgb, vec3(00, 42, 42)) || // §3 dark_aqua
            compareColor(conditionColor.rgb, vec3(42, 00, 00)) || // §4 dark_red
            compareColor(conditionColor.rgb, vec3(42, 00, 42)) || // §5 dark_purple
            compareColor(conditionColor.rgb, vec3(63, 42, 00)) || // §6 gold
            compareColor(conditionColor.rgb, vec3(42, 42, 42)) || // §7 gray
            compareColor(conditionColor.rgb, vec3(21, 21, 21)) || // §8 dark_gray 
            compareColor(conditionColor.rgb, vec3(21, 21, 63)) || // §9 blue
            compareColor(conditionColor.rgb, vec3(21, 63, 21)) || // §a green
            compareColor(conditionColor.rgb, vec3(21, 63, 63)) || // §b aqua
            compareColor(conditionColor.rgb, vec3(63, 21, 21)) || // §c red
            compareColor(conditionColor.rgb, vec3(63, 21, 63)) || // §d light_purple 
            compareColor(conditionColor.rgb, vec3(63, 63, 21)) || // §e yellow
            compareColor(conditionColor.rgb, vec3(63, 63, 63))    // §f white
        )
        {
            applyTextEffect = 0.0;
            textData.applyTextEffect = false;
        } else
        if( // gui 타이틀일 경우
            compareColor(conditionColor.rgb, vec3(16, 16, 16))
        ) {
            vertexColor = vec4(255.0, 255.0, 255.0, 255.0) / 255.0; // gui 타이틀 색상 변경
            baseColor = vec4(255.0, 255.0, 255.0, 255.0) / 255.0;
            conditionColor = ivec3(
                int(round(baseColor.r * 255.0) / 4),
                int(round(baseColor.g * 255.0) / 4),
                int(round(baseColor.b * 255.0) / 4)
            );

            applyTextEffect = 0.0;
            textData.applyTextEffect = false;
        } else { // 기본 색코드, gui 타이틀 아닐 경우
            switch(conditionColor.r) {
            case 63:
                #moj_import <custom_text/position_config.glsl>
                break;
            default: 
                break;
            }

            switch(conditionColor.g) {
            case 63:
                #moj_import <custom_text/effect_config.glsl>
                break;
            default: 
                break;
            }
        }
    }

    vert = gl_VertexID % 4;
    vec2 corner = vec2[](vec2(-1.0, +1.0), vec2(-1.0, -1.0), vec2(+1.0, -1.0), vec2(+1.0, +1.0))[vert];
    coord  = vec2[](vec2(0), vec2(0, 1), vec2(1), vec2(1, 0))[vert];
    
    uvpos1 = uvpos2 = uvpos3 = uvpos4 = ipos1 = ipos2 = ipos3 = ipos4 = vec3(0.0);

    // 스크린 이펙트 기본 변수 설정
    p1 = p2 = vec2(0);
    p = 0;

    texCoord0 = UV0;
    vertexDistance = length((ModelViewMat * vec4(position, 1.0)).xyz);
    vertexColor *= lightColor;

    if(textureSize(Sampler0, 0) == ivec2(256, 256)) { // 지도 제외
        position = textData.position;
        gl_Position = ProjMat * ModelViewMat * vec4(position, 1.0);

        if(position.z == 0.0 && isShadow != 1.0) { // 스코어보드 우선순위 변경
            if(applyTextEffect == 1.0) {
                gl_Position.zw = vec2(-1, 1);
            }
        }
        if(position.z == 100.0 || position.z == 100.03) { // 채팅 우선순위 변경
            gl_Position.zw = vec2(-0.95, 1);
        }

        uvpos1 = uvpos2 = uvpos3 = uvpos4 = ipos1 = ipos2 = ipos3 = ipos4 = vec3(0.0);
        switch (vert) {
            case 0: ipos1 = vec3(gl_Position.xy, 1.0); uvpos1 = vec3(UV0.xy, 1.0); break;
            case 1: ipos2 = vec3(gl_Position.xy, 1.0); uvpos2 = vec3(UV0.xy, 1.0); break;
            case 2: ipos3 = vec3(gl_Position.xy, 1.0); uvpos3 = vec3(UV0.xy, 1.0); break;
            case 3: ipos4 = vec3(gl_Position.xy, 1.0); uvpos4 = vec3(UV0.xy, 1.0); break;
        }
        if(applyTextEffect == 1.0 && textData.shouldScale) {
            gl_Position.xy += corner * 0.2; // 맵 상에 존재하는 텍스트는 다른 수식으로 크기 늘려야 함
            changedScale = 1.0;
        }
        
        screenPosition = gl_Position;

        // 스크린 이펙트
        // 타이틀, 그림자 제외 조건 달기?
        if (vert == 0) p1 = UV0 * 256;
        if (vert == 2) p2 = UV0 * 256;

        float alpha = round(texture(Sampler0, UV0).a * 255);
        if (alpha == 252)
            p = 1;
        else if (alpha == 251)
            p = int(round(texture(Sampler0, UV0).b * 255));
        else if (alpha == 5)
            p = 32;

        if (p != 0 && Position.z > 0)
        {   
            texCoord0 = vec2(UV0 - coord * 56 / 256);

            gl_Position.xy = vec2(coord * 2 - 1) * vec2(1, -1);
            gl_Position.zw = vec2(-1, 1); // 우선순위 
            vertexColor = Color;
        }
    }
}
