#version 150

// 유틸 함수 정의 파일 임포트
#moj_import <utils/spheya_utils.glsl>

struct TextData {
    vec3 pos;
    vec2 scrSize;
    vec4 color;
    vec4 topColor;
    vec4 backColor;
    vec2 position;
    vec2 characterPosition;
    vec2 localPosition;
    vec2 uv;
    vec2 uvMin;
    vec2 uvMax;
    vec2 uvCenter;
    bool isShadow;
    bool doTextureLookup;
    bool shouldScale;
    bool isMoved;
};

TextData textData;
int color_r;
int color_g;
int color_b;

bool uvBoundsCheck(vec2 uv, vec2 uvMin, vec2 uvMax) {
    if(isnan(uv.x) || isnan(uv.y)) return true;
    const float error = 0.0001;
    return uv.x < textData.uvMin.x + error || uv.y < textData.uvMin.y + error || uv.x > textData.uvMax.x - error || uv.y > textData.uvMax.y - error;
}

vec3 textSdf() {
    vec3 value = vec3(0.0, 0.0, 1.0);

    vec2 texelSize = 1.0 / vec2(256.0);
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            vec2 uv = textData.uv + vec2(x, y) * texelSize;
            if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;

            vec4 s = texture(Sampler0, uv);
            if(s.a >= 0.1) {
                vec3 v = vec3(fract(uv * 256.0), 0.0);

                if(x == 0) v.x = 0.0;
                if(y == 0) v.y = 0.0;
                if(x > 0) v.x = 1.0-v.x;
                if(y > 0) v.y = 1.0-v.y;

                v.z = length(v.xy);

                if(v.z < value.z) value = v;
            }
        }
    }
    return value;
}

// 그림자 
void remove_text_shadow() { // 그림자 지우기
    if(textData.isShadow) textData.color.a = 0.0;
}

void apply_vertical_shadow() { // 수직 그림자
    if(textData.isShadow) {
        textData.uv.x += 1.0 / 256.0;
        textData.shouldScale = true;
    }
}

void apply_horizontal_shadow() { // 수평 그림자
    if(textData.isShadow) {
        textData.uv.y += 1.0 / 256.0;
        textData.shouldScale = true;
    }
}

void apply_shadow_by_sub_type() { // 그림자 최종 적용
    switch(color_b % 4) {
    case 0: // 기본
        break;
    case 1: // 수평
        apply_vertical_shadow();
        break;
    case 2: // 수직
        apply_horizontal_shadow();
        break;
    case 3: // 제거
        remove_text_shadow();
        break;
    }
}

void draw_shadow() {
    //textData.shouldScale = true;
    vec2 offset = vec2(0.5, 0.5) / 128;

    vec2 uv = textData.uv - offset;
    vec4 s1 = texture(Sampler0, uv);
    s1.rgb *= s1.a;
    if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) s1 = vec4(0.0);

    textData.backColor = (s1 * vec4(0.0, 0.75, 1.0, 1.0));
    textData.backColor.rgb *= textData.color.rgb;
}

// 효과

void override_text_color(vec4 color) {
    textData.color = color;
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void override_text_color(vec3 color) {
    textData.color.rgb = color;
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void override_shadow_color(vec4 color) {
    if(textData.isShadow) {
        textData.color = color;
        textData.topColor.rgb = color.rgb;
        textData.topColor.a *= color.a;
        textData.backColor.rgb = color.rgb;
        textData.backColor.a *= color.a;
    }
}

void override_shadow_color(vec3 color) {
    override_shadow_color(vec4(color, 1.0));
}

void apply_waving_movement(float speed, float frequency) {
    textData.uv.y += sin(textData.characterPosition.x * 0.1 * frequency - GameTime * 7500.0 * speed) / 128.0;
    textData.shouldScale = true;
}

void apply_waving_movement(float speed) {
    apply_waving_movement(speed, 1.0);
}

void apply_waving_movement() {
    apply_waving_movement(1.0, 1.0);
}

void apply_shaking_movement() {
    float noiseX = noise(textData.characterPosition.x + textData.characterPosition.y + GameTime * 32000.0) - 0.5;
    float noiseY = noise(textData.characterPosition.x - textData.characterPosition.y + GameTime * 32000.0) - 0.5;
    textData.shouldScale = true;

    textData.uv += vec2(noiseX, noiseY) / 128.0;
}

void apply_iterating_movement(float speed, float space) {
    float x = mod(textData.characterPosition.x * 0.4 - GameTime * 18000.0 * speed, (5.0 * space) * TAU);
    if(x > TAU) x = TAU;
    textData.uv.y += (-cos(x) * 0.5 + 0.5) / 128.0;
    textData.shouldScale = true;
}

void apply_iterating_movement() {
    apply_iterating_movement(1.0, 1.0);
}

void apply_flipping_movement(float speed, float space) {
    float t = mod((textData.characterPosition.x * 0.4 - GameTime  * 18000.0 * speed) / TAU, 5.0 * space);
    textData.uv.x = textData.uvCenter.x + (textData.uv.x - textData.uvCenter.x) / (cos(TAU * min(t, 1.0)));
    textData.uv.y = textData.uvCenter.y + (textData.uv.y - textData.uvCenter.y) / (1.0 + 0.1 * sin(TAU * min(t, 1.0)));
    textData.shouldScale = true;
}

void apply_flipping_movement() {
    apply_flipping_movement(1.0, 1.0);
}

void apply_skewing_movement(float speed) {
    float t = GameTime * 1600.0 * speed;

    textData.uv.x = mix(textData.uv.x, textData.uv.x + sin(TAU * t * 0.5) / 256.0, 1.0 - textData.localPosition.y);
    textData.uv.y = mix(textData.uv.y, textData.uvMax.y, -(0.3 + 0.5 * cos(TAU * t)));
    textData.shouldScale = true;
}

void apply_skewing_movement() { 
    apply_skewing_movement(1.0);
}

void apply_growing_movement(float speed) {
    vec2 offset = vec2(0.0, 5.0 / 256.0);
    textData.uv = (textData.uv - textData.uvCenter - offset) * (sin(GameTime * 12800.0 * speed) * 0.15 + 0.85) + textData.uvCenter + offset;
    textData.shouldScale = true;
}

void apply_growing_movement() {
    apply_growing_movement(1.0);
}

void apply_outline(vec3 color) {
    textData.shouldScale = true;

    if(textData.isShadow) {
        color *= 0.25;
        textData.color.rgb = color;
    } 

    vec2 texelSize = 1.0 / vec2(256.0);
    bool outline = false;

    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;

            vec2 uv = textData.uv + vec2(x, y) * texelSize;
            if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;

            vec4 s = texture(Sampler0, uv);
            if(s.a >= 0.1) { textData.backColor = vec4(color, 1.0); return; }
        }
    }
}

void apply_thin_outline(vec3 color) {
    textData.shouldScale = true;

    if(textData.isShadow) {
        color *= 0.25;
        textData.color.rgb = color;
    } 
    
    vec2 texelSize = 0.5 / vec2(256.0);
    bool outline = false;

    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;

            vec2 uv = textData.uv + vec2(x, y) * texelSize;
            if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;

            vec4 s = texture(Sampler0, uv);
            if(s.a >= 0.1) { textData.backColor = vec4(color, 1.0); return; }
        }
    }
}


void apply_gradient(vec3 color1, vec3 color2) {
    textData.color.rgb = mix(color1, color2, (textData.uv.y - textData.uvMin.y) / (textData.uvMax.y - textData.uvMin.y));
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_rainbow() {
    textData.color.rgb = hsvToRgb(vec3(0.005 * (textData.position.x + textData.position.y) - GameTime * 300.0, 0.7, 1.0));
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_shimmer(float speed, float intensity) {
    if(textData.isShadow) return;
    float f = textData.localPosition.x + textData.localPosition.y - GameTime * 6400.0 * speed;
    
    if(mod(f, 5) < 0.75) textData.topColor = vec4(1.0, 1.0, 1.0, intensity);
}

void apply_shimmer(){
    apply_shimmer(1.0, 0.5);
}

void apply_chromatic_abberation() {
    textData.shouldScale = true;
    float noiseX = noise(GameTime * 12000.0) - 0.5;
    float noiseY = noise(GameTime * 12000.0 + 19732.134) - 0.5;
    vec2 offset = vec2(0.5 / 128, 0.0) + vec2(0.5, 1.0) * vec2(noiseX, noiseY) / 128;

    vec2 uv = textData.uv + offset;
    vec4 s1 = texture(Sampler0, uv);
    s1.rgb *= s1.a;
    if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) s1 = vec4(0.0);

    uv = textData.uv - offset;
    vec4 s2 = texture(Sampler0, uv);
    s2.rgb *= s2.a;
    if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) s2 = vec4(0.0);

    textData.backColor = (s1 * vec4(1.0, 0.25, 0.0, 1.0)) + (s2 * vec4(0.0, 0.75, 1.0, 1.0));
    textData.backColor.rgb *= textData.color.rgb;
}

void apply_metalic(vec3 lightColor, vec3 darkColor) {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));
    
    if(y > 3) textData.color.rgb = darkColor;
    if(y == 3) textData.color.rgb = lightColor + 0.25;
    if(y < 3) textData.color.rgb = lightColor;

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_metalic(vec3 color) {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 128.0));
    
    if(y > 2) textData.color.rgb = color * 0.7;
    if(y == 2) textData.color.rgb = color + 0.25;
    if(y < 2) textData.color.rgb = color;

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_fire() {
    textData.shouldScale = true;
    if(textData.isShadow) return;

    float h = fract(textData.uv.y * 256.0);
    vec2 uv = textData.uv + vec2(0.0, 1.0 / 256);
    if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) return;
    vec4 s = texture(Sampler0, uv);
    if(s.a > 0.1) {
        float f = noise(textData.localPosition * 32.0 + vec2(0.0, GameTime * 6400.0)) * 0.5 + 0.5;
        f -= (1.0 - sqrt(h)) * 0.8;

        if(f > 0.5)
        textData.backColor = vec4(mix(vec3(1.0, 0.2, 0.2), vec3(1.0, 0.7, 0.3), (f - 0.5) / 0.5), 1.0);
    }
}

void apply_fade(float speed) {
    textData.color.a = mix(textData.color.a, 0.0, sin(GameTime * 1200 * speed * PI) * 0.5 + 0.5);
}

void apply_fade() {
    apply_fade(1.0);
}

void apply_fade(vec3 color, float speed) {
    if(textData.isShadow) color *= 0.25;

    textData.color.rgb = mix(textData.color.rgb, color, sin(GameTime * 1200 * speed * PI) * 0.5 + 0.5);
}

void apply_fade(vec3 color) {
    apply_fade(color, 1.0);
}

void apply_blinking(float speed){
    if(sin(GameTime * 3200 * speed * PI) < 0.0) { textData.color.a = 0.0; textData.backColor.a = 0.0; textData.topColor.a = 0.0; }
}

void apply_blinking() {
    apply_blinking(1.0);
}

void apply_glowing() {
    if(textData.isShadow) textData.color = vec4(0.0);
    vec3 d = textSdf();
    textData.backColor = vec4(1.0, 1.0, 1.0, (1.0 - d.z) * (1.0 - d.z));
}

void move_text() {
    textData.pos = vec3(100.0, 0.0, 1.0);
}

#define TEXT_POSITION_CASE(type) return true; case int(type / 4):
#define TEXT_EFFECT_CASE(type) return true; case int(type / 4):

bool applyTextPosition(inout vec3 vctfx_Pos) {
    color_r = int(round(textData.color.r * 255.0) / 4);
    color_g = int(round(textData.color.g * 255.0) / 4);
    color_b = int(round(textData.color.b * 255.0) / 4);
    if(textData.isShadow) {
        color_r = int(round(textData.color.r * 255.0));
        color_g = int(round(textData.color.g * 255.0));
        color_b = int(round(textData.color.b * 255.0));
    }

    if(color_b > 3) {
        return false;
    }
    
    if(color_g == 42) { // darkgreen
        return false;
    }
    
    switch(color_r) {
    case 64:
        // ****** 위치 커스텀 ****** //
        TEXT_POSITION_CASE(0) {
        }
        TEXT_POSITION_CASE(4) {
            textData.pos.x += 100;
            textData.isMoved = true;
        }
        // ****** 위치 커스텀 ****** //
        return true;
    default: 
        return false;
    }
    return false;
}

bool applyTextEffects() {
    color_r = int(round(textData.color.r * 255.0) / 4);
    color_g = int(round(textData.color.g * 255.0) / 4);
    color_b = int(round(textData.color.b * 255.0) / 4);
    if(textData.isShadow) {
        color_r = int(round(textData.color.r * 255.0));
        color_g = int(round(textData.color.g * 255.0));
        color_b = int(round(textData.color.b * 255.0));
    }

    if((color_b > 3 && color_b < 8) || textData.isMoved) {
        switch(color_g) {
        case 64:
            #moj_import <custom_text/effect_config.glsl>
            return true;
        default: 
            return false;
        }
        return false;
    }
}

#ifdef FSH
    in vec3 vctfx_Pos;
    in vec2 vctfx_ScrSize;

    in vec4 vctfx_screenPos;
    flat in float vctfx_applyTextEffect;
    flat in float vctfx_isShadow;
    flat in float vctfx_isMoved;
    flat in float vctfx_changedScale;

    in vec3 vctfx_ipos1;
    in vec3 vctfx_ipos2;
    in vec3 vctfx_ipos3;
    in vec3 vctfx_ipos4;

    in vec3 vctfx_uvpos1;
    in vec3 vctfx_uvpos2;
    in vec3 vctfx_uvpos3;
    in vec3 vctfx_uvpos4;

    bool applyCustomText() {
        if(vctfx_applyTextEffect < 0.5) return false;
        
        textData.pos = vctfx_Pos;
        textData.scrSize = vctfx_ScrSize;
        textData.isShadow = vctfx_isShadow > 0.5;
        textData.isMoved = vctfx_isMoved > 0.5;
        textData.backColor = vec4(0.0);
        textData.topColor = vec4(0.0);
        textData.doTextureLookup = true;
        textData.color = baseColor;
        
        vec2 ip1 = vctfx_ipos1.xy / vctfx_ipos1.z;
        vec2 ip2 = vctfx_ipos2.xy / vctfx_ipos2.z;
        vec2 ip3 = vctfx_ipos3.xy / vctfx_ipos3.z;
        vec2 ip4 = vctfx_ipos4.xy / vctfx_ipos4.z;
        vec2 innerMin = min(ip1.xy,min(ip2.xy,min(ip3.xy,ip4.xy)));
        vec2 innerMax = max(ip1.xy,max(ip2.xy,min(ip3.xy,ip4.xy)));
        vec2 innerSize = innerMax - innerMin;
        
        vec2 uvp1 = vctfx_uvpos1.xy / vctfx_uvpos1.z;
        vec2 uvp2 = vctfx_uvpos2.xy / vctfx_uvpos2.z;
        vec2 uvp3 = vctfx_uvpos3.xy / vctfx_uvpos3.z;
        vec2 uvp4 = vctfx_uvpos4.xy / vctfx_uvpos4.z;
        vec2 uvMin = min(uvp1.xy,min(uvp2.xy,min(uvp3.xy, uvp4.xy)));
        vec2 uvMax = max(uvp1.xy,max(uvp2.xy,max(uvp3.xy, uvp4.xy)));
        vec2 uvSize = uvMax - uvMin;
        textData.uvMin = uvMin;
        textData.uvMax = uvMax;
        textData.uvCenter = uvMin + 0.25 * uvSize;
        textData.localPosition = ((vctfx_screenPos.xy - innerMin) / innerSize);
        textData.localPosition.y = 1.0 - textData.localPosition.y;
        textData.uv = textData.localPosition * uvSize + uvMin;
        if(vctfx_changedScale < 0.5) {
            textData.uv = texCoord0;
        }
        textData.position = vctfx_screenPos.xy * uvSize * 256.0 / innerSize;
        textData.characterPosition = 0.5 * (innerMin + innerMax) * uvSize * 256.0 / innerSize;
        if(textData.isShadow) { 
            textData.characterPosition += vec2(-1.0, 1.0);
            textData.position += vec2(-1.0, 1.0);
        }
        applyTextEffects();
        if(uvBoundsCheck(textData.uv, uvMin, uvMax)) textData.doTextureLookup = false;
        
        vec4 textureSample = texture(Sampler0, textData.uv);

        //#ifdef RENDERTYPE_TEXT_INTENSITY
        //    textureSample = textureSample.rrrr;
        //    textureSample = vec4(0.0);
        //#endif

        if(!textData.doTextureLookup) textureSample = vec4(0.0);
        textData.topColor.a *= textureSample.a;

        fragColor = mix(vec4(textData.backColor.rgb, textData.backColor.a * textData.color.a), textureSample * textData.color, textureSample.a);
        fragColor.rgb = mix(fragColor.rgb, textData.topColor.rgb, textData.topColor.a);
        fragColor *= lightColor * ColorModulator;

        if (fragColor.a < 0.1) {
            discard;
        }

        fragColor = linear_fog(fragColor, vertexDistance, FogStart, FogEnd, FogColor);
        return true;
    }
#endif

#ifdef VSH
    out vec3 vctfx_Pos;
    out vec2 vctfx_ScrSize;

    out vec4 vctfx_screenPos;
    flat out float vctfx_applyTextEffect;
    flat out float vctfx_isShadow;
    flat out float vctfx_isMoved;
    flat out float vctfx_changedScale;

    out vec3 vctfx_ipos1;
    out vec3 vctfx_ipos2;
    out vec3 vctfx_ipos3;
    out vec3 vctfx_ipos4;

    out vec3 vctfx_uvpos1;
    out vec3 vctfx_uvpos2;
    out vec3 vctfx_uvpos3;
    out vec3 vctfx_uvpos4;

    bool applyCustomText() {

        vctfx_Pos = Position;
        vctfx_ScrSize = 2 / vec2(ProjMat[0][0], -ProjMat[1][1]);

        vctfx_isShadow = fract(vctfx_Pos.z) < 0.01 ? 1.0 : 0.0;
        vctfx_applyTextEffect = 1.0;
        vctfx_changedScale = 0.0;
        vctfx_isMoved = 0;
        
        textData.pos = vctfx_Pos;
        textData.scrSize = vctfx_ScrSize;
        textData.isShadow = vctfx_isShadow > 0.5;
        textData.isMoved = vctfx_isMoved > 0.5;
        textData.color = Color;
        textData.shouldScale = false;

        // 위치 커스텀
        if(applyTextPosition(vctfx_Pos)) vctfx_isMoved = 1;
        vctfx_Pos = textData.pos;

        gl_Position = ProjMat * ModelViewMat * vec4(textData.pos, 1.0);
        
        // 효과 커스텀
        if(!applyTextEffects()) {
            vctfx_isShadow = 0.0;
            if(vctfx_Pos.z == 0.0 && textData.isShadow) {
                textData.isShadow = false;
                if(applyTextEffects()) {
                    vctfx_isShadow = 0.0;
                }else {
                    vctfx_applyTextEffect = 0.0;
                    return false;
                }
            }else{
                vctfx_applyTextEffect = 0.0;
                return false;
            }
        }

        vec2 corner = vec2[](vec2(-1.0, +1.0), vec2(-1.0, -1.0), vec2(+1.0, -1.0), vec2(+1.0, +1.0))[gl_VertexID % 4];

        if(textureSize(Sampler0, 0) != ivec2(256, 256)) {
            vctfx_applyTextEffect = 0.0;
            return false;
        }

        vctfx_uvpos1 = vctfx_uvpos2 = vctfx_uvpos3 = vctfx_uvpos4 = vctfx_ipos1 = vctfx_ipos2 = vctfx_ipos3 = vctfx_ipos4 = vec3(0.0);
        switch (gl_VertexID % 4) {
            case 0: vctfx_ipos1 = vec3(gl_Position.xy, 1.0); vctfx_uvpos1 = vec3(UV0.xy, 1.0); break;
            case 1: vctfx_ipos2 = vec3(gl_Position.xy, 1.0); vctfx_uvpos2 = vec3(UV0.xy, 1.0); break;
            case 2: vctfx_ipos3 = vec3(gl_Position.xy, 1.0); vctfx_uvpos3 = vec3(UV0.xy, 1.0); break;
            case 3: vctfx_ipos4 = vec3(gl_Position.xy, 1.0); vctfx_uvpos4 = vec3(UV0.xy, 1.0); break;
        } 
        if(textData.shouldScale) {
            gl_Position.xy += corner * 0.2;
            vctfx_changedScale = 1.0;
        }

        vctfx_screenPos = gl_Position;
        vertexDistance = length((ModelViewMat * vec4(vctfx_Pos, 1.0)).xyz);
        vertexColor = baseColor * lightColor;
        texCoord0 = UV0;
        return true;
    }
#endif