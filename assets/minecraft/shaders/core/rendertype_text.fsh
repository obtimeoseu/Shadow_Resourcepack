#version 150
#define FSH

#moj_import <fog.glsl>
#moj_import <utils.glsl>
#moj_import <utils/spheya_utils.glsl>

uniform sampler2D Sampler0;

#define BACKGROUND_COLOR vec4(20, 20, 28, 255) / 255

#define SPIKES_SPEED 2000
#define SPIKES_RADIUS 0.07
#define SPIKES_COUNT 50
#define SPIKES_BLUR 50 //Bigger value -> less blur
#define SPIKES_BLUR_BIAS 0 //Addition to transparrency in blur

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;
uniform vec2 ScreenSize;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
flat in vec4 baseColor;
flat in vec4 lightColor;
flat in ivec3 conditionColor;

in vec2 scrSize;
in vec3 position;
in vec4 screenPosition;

flat in float applyTextEffect;
flat in float isShadow;
flat in float isMoved;
flat in float changedScale;

in vec3 ipos1;
in vec3 ipos2;
in vec3 ipos3;
in vec3 ipos4;

in vec3 uvpos1;
in vec3 uvpos2;
in vec3 uvpos3;
in vec3 uvpos4;

in vec2 p1;
in vec2 p2;
in vec2 coord;
flat in int vert;
flat in int p;

out vec4 fragColor;

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

const float tentacleIntensity = 0.275;
const float tentacleCount = 16.;
const float tentacleWiggle = 0.5;
const float tentacleInOutA = 1.0;
const float tentacleInOutF = 1.5;
const float tentacleLimit = 0.4;

const float tentacleFade = 0.5;

TextData textData;

#moj_import <custom_text/custom_text.glsl>

int rand3(vec3 uv, int seed) {
	return int(4769.*fract(cos(floor(uv.y-5234.)*755.)*245.* sin(floor(uv.x-534.)*531.)*643.)*sin(floor(uv.z-53345.)*765.)*139.);
}

float fade(float t) {
	return t * t * t * (t * (t * 6. - 15.) + 10.);
}

float lerp(float a, float b, float t) {
	return a + fade(t) * (b - a);
}

vec3 randVec3(vec3 uv, int seed) {
	int a = rand3(uv, seed)*5237;
    int p1 = (a & 1) * 2 - 1;
    int p2 = (a & 2) - 1;
    int p3 = (a & 4) / 2 - 1;
    return vec3(p1, p2, p3);
}

float perlin3D(vec3 uv, int seed) {
	vec3 fuv = fract(uv);
    float c1 = dot(fuv - vec3(0, 0, 0), randVec3(floor(uv) + vec3(0, 0, 0), seed));
    float c2 = dot(fuv - vec3(0, 0, 1), randVec3(floor(uv) + vec3(0, 0, 1), seed));
    float c3 = dot(fuv - vec3(0, 1, 0), randVec3(floor(uv) + vec3(0, 1, 0), seed));
    float c4 = dot(fuv - vec3(0, 1, 1), randVec3(floor(uv) + vec3(0, 1, 1), seed));
    float c5 = dot(fuv - vec3(1, 0, 0), randVec3(floor(uv) + vec3(1, 0, 0), seed));
    float c6 = dot(fuv - vec3(1, 0, 1), randVec3(floor(uv) + vec3(1, 0, 1), seed));
    float c7 = dot(fuv - vec3(1, 1, 0), randVec3(floor(uv) + vec3(1, 1, 0), seed));
    float c8 = dot(fuv - vec3(1, 1, 1), randVec3(floor(uv) + vec3(1, 1, 1), seed));
    return (
            lerp(
        		lerp(
            		lerp(c1, c2, fuv.z), 
                    lerp(c3, c4, fuv.z), 
                    fuv.y), 
                lerp(
                    lerp(c5, c6, fuv.z), 
                    lerp(c7, c8, fuv.z), 
                    fuv.y), 
                fuv.x)
           );
}

float layeredPerlin3D(vec3 uv, int layerNumber, float fade, float frequencyShift, int seed) {
    float weight = 1.;
    float frequency = 1.;
    float result = 0.;
    int layer_seed = seed;
    float final_range = 0.;
    for (int i = 0; i < layerNumber; i++) {
        result += perlin3D(uv/frequency, layer_seed) * fade;
        final_range += fade;
        weight *= fade;
        frequency *= frequencyShift;
    	layer_seed = rand3(uv, layer_seed);
    }
    return result/final_range;
}

float pNoise(vec2 uv, float f, float time) {
	vec3 tuv = vec3(uv, (time + 20.0) * f);
    return layeredPerlin3D(tuv, 8, 2., 2., 4);
}

float tentacles(vec2 uv, float baseIntensity, float count) {
    
    if (baseIntensity < .5)
        return 0.0;

    vec2 polar = vec2(
        length(uv),
        atan(uv.x, uv.y)
    );
    
    // Remap angle to [0, 1]
    polar.y = .5 + .5 * polar.y/PI;
    
    // Repeat tentacleCount times
    float id;
    polar.y = modf(polar.y * count, id);
    
    polar.y = (polar.y + tentacleWiggle * pNoise(vec2(polar.x * 20.0, -id), 0.9, GameTime * 1000));
    // Introduce symmetry
    polar.y = 2. * abs(polar.y - .5);
    
    float tentacleStart = tentacleInOutA*pNoise(vec2(id, 20.0), tentacleInOutF, GameTime * 1000) + 1.0 / (tentacleIntensity * baseIntensity);
    
    tentacleStart = max(tentacleStart + tentacleLimit*.7, tentacleLimit);

    // b describes the tentacle color intensity, but I named it that b cuz I like that letter more
    float b = 1. - polar.y - 0.2*tentacleStart / polar.x;
    
    b = clamp(b, 0.0, 1.0);
    
    b = pow(b, 10.0);
    
    return step(.5, smoothstep(.005, 0.01, b));
}

vec4 sampleStain(vec4 inColor, vec4 col, vec2 stp, vec2 pos) {
    vec2 lUV = gl_FragCoord.xy / ScreenSize;
    vec2 inst = vec2(sin(col.a * 1.1 + 0.5 + lUV.y * 20) + 0.8 * cos(col.a * 1.3 + 0.2 + lUV.x * 15),
                0.5 * sin(col.a * 1.8 + 0.5 + lUV.x * 16) + 0.3 * cos(col.a * 1.5 + 0.2 + lUV.y * 13)) * 0.005;
    float Ratio = ScreenSize.y / ScreenSize.x;
    vec2 uv = (lUV - 0.5 - pos - inst + vec2(0, (1 - col.a) * 0.03)) * vec2(1, -1) / vec2(Ratio, 1) * 1.4 + 0.5;
    
    if (uv != clamp(uv, 0, 1)) return inColor;

    vec4 color = texelFetch(Sampler0, ivec2(stp + uv * vec2(165, 177)), 0) * col;

    return vec4(mix(inColor.rgb, color.rgb, color.a), min(color.a + inColor.a, 1));
}

#define TEXT_EFFECT_CASE(type) break; case int(type / 4):;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;

    vec2 P1 = round(p1 / (vert == 0 ? 1 - coord.x : 1 - coord.y)); //Right-up corner
    vec2 P2 = round(p2 / (vert == 0 ? coord.y : coord.x)); //Left-down corner

    ivec2 res = ivec2(abs(P1 - P2)); //Resolution of frame
    ivec2 stp = ivec2(min(P1, P2)); //Left-Up corner

    vec4 test = texture(Sampler0, stp / 256.0) * 255;

    if (test.a == 3) { // 애니메이션 텍스트 적용
        ivec2 frames = ivec2(res / test.gb);
        vec2 uv = (texCoord0 * 256 - stp) / frames.x;

        if (uv.x > test.y || uv.y > test.z)
            discard;

        int time = int(GameTime * 1000 * test.x) % int(frames.x * frames.y);

        uv = stp + mod(uv, test.yz) + vec2(time % frames.x, time / frames.x % frames.y) * test.yz;
        color = texture(Sampler0, uv / 256.0) * vertexColor * ColorModulator;
        
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
        if (color.a < 0.1) {
            discard;
        }
    } else

    if (p != 0) { // 스크린 이펙트 적용
        vec2 centerUV = gl_FragCoord.xy / ScreenSize - 0.5;
        float Ratio = ScreenSize.y / ScreenSize.x;
        switch (p)
        {
            case 1:
            {
                vec2 uv = mat2_rotate_z(vertexColor.a*4) * (centerUV / vec2(Ratio, 1)) / (1.0001 - vertexColor.a) * 0.2 + 0.5;

                if (clamp(uv, vec2(0), vec2(1)) == uv)
                    color = texture(Sampler0, texCoord0 + uv * 56 / 256);
                else
                    color = BACKGROUND_COLOR;
            }
            break;
            case 2:
            {
                color = vec4(0, 0, 0, clamp(length(centerUV * vec2(0.8, 0.5 / (1 - vertexColor.a))) - 0.6, 0, 1));
            }
            break;
            case 3:
            {
                color = vec4(0);
                
                float angle = (atan(centerUV.y, centerUV.x) / PI / 2 + 0.5) * SPIKES_COUNT;
                float Time = GameTime * SPIKES_SPEED + hash(int(angle)) % 100 * 64.2343;
                int noise = hash(int(angle) + int(Time) * 1000) % 128;
                float s = (abs(fract(angle) - 0.5) * 20 / SPIKES_COUNT - 0.2) * length(centerUV) + SPIKES_RADIUS + (1 - vertexColor.a) * 0.05 + abs(fract(Time) - 0.5) * 0.25;
                if (s < 0)
                {
                    color = vec4(1, 1, 1, clamp(-s * SPIKES_BLUR + SPIKES_BLUR_BIAS, 0, 1));
                    break;
                }
            }
            break;
            case 4:
            {
                vec2 grid = (ivec2(gl_FragCoord.xy / 32) * 32);
                vec2 inGrid = gl_FragCoord.xy - grid - 16;
                float size;

                switch (int(vertexColor.b * 255))
                {
                    case 0:
                        size = grid.x / ScreenSize.x;
                        break;
                    case 1:
                        size = 1 - grid.x / ScreenSize.x;
                        break;
                    case 2:
                        size = grid.y / ScreenSize.y;
                        break;
                    default:
                        size = 1 - grid.y / ScreenSize.y;
                        break;
                }

                size = (size - vertexColor.a * 2 + 1) * 32;

                color = (abs(inGrid.x) + abs(inGrid.y) > size) ? vec4(0, 0, 0, 1) : vec4(0);
            }
            break;
            case 5:
            {
                ivec2 grid = ivec2(gl_FragCoord.xy / 32) * 32;

                color = abs(hash(grid.x ^ hash(grid.y)) % 0x100) + 10 < int(vertexColor.a * (length(grid / ScreenSize.xy - 0.5) * 2 + 1) * 0x100) ? vec4(vertexColor.rgb, 1) : vec4(0);
            }
            case 6:
            {
                float Time = cos(vertexColor.a * PI / 2);
                color = vec4(vertexColor.rgb, (length((gl_FragCoord.xy / ScreenSize - 0.5) / vec2(ScreenSize.y / ScreenSize.x, 1)) + 0.1 - Time) * (1 - Time) * 100);
            }
            break;
            case 7:
            {
                color = vec4(0);
                vec2 uv = gl_FragCoord.xy / ScreenSize -0.5;

                float baseIntensity = vertexColor.b - 0.25;
                baseIntensity *= 1.2;
                if(baseIntensity < 0) { baseIntensity = 0; }
                //baseIntensity = sin(fract(GameTime * 300) * PI);
                float tentacleIntensity = (((baseIntensity + sin(fract(GameTime * 200) * PI) / 3) * 0.8) + 0.2) * 7.5; // 요기 수치 조정

                if(color.a > 1) { color.a = 1; }
                color.a = 1;
                //color.rgb = vec3(1.0);

                color.rgb += vec3(tentacles(uv, pow(tentacleIntensity, 0.975) * 0.8, 5));

                color.rgb += vec3(tentacles(uv, pow(tentacleIntensity, 0.975) * 1.1, 7));
                
                color.rgb += vec3(tentacles(uv, pow(tentacleIntensity, 0.975) * 1.3, 9));
                color *= clamp(length(gl_FragCoord.xy / ScreenSize - 0.5) / (1 - tentacleIntensity / 15), 0.0, 1.0);
                
                float sideAplha = clamp(length(gl_FragCoord.xy / ScreenSize - 0.5) / (1 - tentacleIntensity / 20), 0.0, 1.0); // 30 줄이면 구석 덜 어두워짐
                float baseAlpha = baseIntensity * 3;
                if(baseAlpha > 1) { baseAlpha = 1.0; }

                color.a = pow(sideAplha, 1) * 1.05;// * sideAplha;
                color.a *= baseAlpha;

                if(color.r > 0.2) {
                    color.a *= 1.25;
                    color.r = 0;
                    color.g = 0;
                    color.b = 0;
                }
                
            }
            break;
            case 8:
            {
                color = vec4(0);
                float alpha = 1 - ((gl_FragCoord.y * (12 - vertexColor.a * 6.5)) / ScreenSize.y ) + vertexColor.a;
                if(alpha < 0.02) {alpha = 0.02;}
                color = vec4(0, 0, 0, alpha);
            }
            break;
            case 32:
            {
                color = vec4(0);
                color = sampleStain(color, vertexColor, stp, vec2(-0.1, -0.2));
                color = sampleStain(color, vertexColor, stp, vec2(-0.05, 0.2));
                color = sampleStain(color, vertexColor, stp, vec2(0.2, -0.1));
            }
            break;
        }
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
        if (color.a < 0.01) {
            discard;
        }
    } else {
        textData.position = position;
        textData.scrSize = scrSize;
        
        textData.applyTextEffect =  applyTextEffect > 0.5;
        textData.doTextureLookup = true;
        textData.isShadow = isShadow > 0.5;
        textData.isMoved = isMoved > 0.5;

        textData.backColor = vec4(0.0);
        textData.topColor = vec4(0.0);
        textData.color = baseColor;

        vec2 ip1 = ipos1.xy / ipos1.z;
        vec2 ip2 = ipos2.xy / ipos2.z;
        vec2 ip3 = ipos3.xy / ipos3.z;
        vec2 ip4 = ipos4.xy / ipos4.z;
        vec2 innerMin = min(ip1.xy,min(ip2.xy,min(ip3.xy,ip4.xy)));
        vec2 innerMax = max(ip1.xy,max(ip2.xy,min(ip3.xy,ip4.xy)));
        vec2 innerSize = innerMax - innerMin;

        vec2 uvp1 = uvpos1.xy / uvpos1.z;
        vec2 uvp2 = uvpos2.xy / uvpos2.z;
        vec2 uvp3 = uvpos3.xy / uvpos3.z;
        vec2 uvp4 = uvpos4.xy / uvpos4.z;
        vec2 uvMin = min(uvp1.xy,min(uvp2.xy,min(uvp3.xy, uvp4.xy)));
        vec2 uvMax = max(uvp1.xy,max(uvp2.xy,max(uvp3.xy, uvp4.xy)));
        vec2 uvSize = uvMax - uvMin;
        textData.uvMin = uvMin;
        textData.uvMax = uvMax;
        textData.uvCenter = uvMin + 0.25 * uvSize;
        textData.localPosition = ((screenPosition.xy - innerMin) / innerSize);
        textData.localPosition.y = 1.0 - textData.localPosition.y;
        textData.uv = textData.localPosition * uvSize + uvMin;
        if(changedScale < 0.5) {
            textData.uv = texCoord0;
        }
        textData.position_2 = screenPosition.xy * uvSize * 256.0 / innerSize;
        textData.characterPosition = 0.5 * (innerMin + innerMax) * uvSize * 256.0 / innerSize;
        if(textData.isShadow) { 
            textData.characterPosition += vec2(-1.0, 1.0);
            textData.position_2 += vec2(-1.0, 1.0);
        }

        if(textData.applyTextEffect) { // 기본 색코드, gui 타이틀 아닐 경우 커스텀 이펙트 적용
            if(textData.isMoved) {
                override_text_color(vec3(255, 255, 255) / 255.0);
            }
            switch(conditionColor.g) {
            case 63:
                #moj_import <custom_text/effect_config.glsl>
                break;
            default: 
                break;
            }
        }

        if(uvBoundsCheck(textData.uv, uvMin, uvMax)) textData.doTextureLookup = false;

        vec4 textureSample = texture(Sampler0, textData.uv);

        if(!textData.doTextureLookup) textureSample = vec4(0.0);
        textData.topColor.a *= textureSample.a;

        fragColor = mix(vec4(textData.backColor.rgb, textData.backColor.a * textData.color.a), textureSample * textData.color, textureSample.a);
        fragColor.rgb = mix(fragColor.rgb, textData.topColor.rgb, textData.topColor.a);
        fragColor *= lightColor * ColorModulator;
        
        if (fragColor.a < 0.1) {
            discard;
        }
    }
}
