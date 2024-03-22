#version 330 core

#import <sodium:include/fog.glsl>

in vec4 v_Vertcolor;
in vec4 v_Lightcolor;

in vec2 v_TexCoord; // The interpolated block texture coordinates
in float v_FragDistance; // The fragment's distance from the camera

in float v_MaterialMipBias;
in float v_MaterialAlphaCutoff;

uniform sampler2D u_BlockTex; // The block texture

uniform vec4 u_FogColor; // The color of the shader fog
uniform float u_FogStart; // The starting position of the shader fog
uniform float u_FogEnd; // The ending position of the shader fog

out vec4 fragColor; // The output fragment for the color framebuffer

bool adjacentCheck(float valueA, float valueB) {
	float compareLess = valueB - 0.01;
	float compareMore = valueB + 0.01;
	return (valueA > compareLess && valueA < compareMore);
}

vec4 showRedAndGray(vec4 color, inout vec4 fogColor) {
    float gray = (color.r + color.g + color.b) / 3;
    if(fogColor.g == 0 && fogColor.b == 0) {
        
        if(fogColor.r * 255 < 1) {
            //color.rgb = vec3(gray);
            //return color;
        } else
        if(fogColor.r * 255 < 2) {
            //color.rgb = vec3(gray);
            //return color;
        } else
        if(fogColor.r * 255 < 3) {
            //color.rgb = vec3(gray);
            //return color;
        } else
        if(fogColor.r * 255 < 4) {
            //color.rgb = vec3(gray);
            //return color;
        } else {
            return color;
        }
    } else {
        return color;
    }

    if(
        (color.g < 0.275 && color.b < 0.425 && color.r > 0.28) ||
        (color.g < 0.15 && color.b < 0.15 && color.r > 0.15)
    ) {
        return color;
    }
    
    color.rgb = vec3(gray);
    return color;
}

const vec3[] EP_COLORS = vec3[](
    vec3(0.110818 * 3, 0.098399 / 3, 0.022087),
    vec3(0.089485 * 3, 0.095924 / 3, 0.011892),
    vec3(0.100326 * 3, 0.101689 / 3, 0.027636),
    vec3(0.114838 * 3, 0.109883 / 3, 0.046564),
    vec3(0.097189 * 3, 0.117696 / 3, 0.064901),
    vec3(0.123646 * 3, 0.086895 / 3, 0.063761),
    vec3(0.166380 * 3, 0.111994 / 3, 0.084817),
    vec3(0.091064 * 3, 0.154120 / 3, 0.097489),
    vec3(0.195191 * 3, 0.131144 / 3, 0.106152),
    vec3(0.187229 * 3, 0.110188 / 3, 0.097721),
    vec3(0.148582 * 3, 0.138278 / 3, 0.133516),
    vec3(0.235792 * 3, 0.243332 / 3, 0.070006),
    vec3(0.214696 * 3, 0.142899 / 3, 0.196766),
    vec3(0.321970 * 3, 0.315338 / 3, 0.047281),
    vec3(0.302066 * 3, 0.390010 / 3, 0.204675),
    vec3(0.661491 * 3, 0.314821 / 3, 0.080955)
);

const mat4 EP_SCALE_TRANSLATE = mat4(
    0.6, 0.0, 0.0, 0.25,
    0.0, 0.6, 0.0, 0.25,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
);

mat2 mat2_rotate_z(float radians) {
    return mat2(
        cos(radians), -sin(radians),
        sin(radians), cos(radians)
    );
}

mat4 end_portal_layer(float layer, float gameTime) {
    mat4 translate = mat4(
        1.0, 0.0, 0.0, 17.0 / layer,
        0.0, 1.0, 0.0, (2.0 + layer / 1.5) * (gameTime * 1.5),
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    );

    mat2 rotate = mat2_rotate_z(radians((layer * layer * 4321.0 + layer * 9.0) * 2.0));

    mat2 scale = mat2((4.5 - layer / 4.0) * 2.0);

    return mat4(scale * rotate) * translate * EP_SCALE_TRANSLATE;
}

void main() {
    vec4 fogColor = u_FogColor;
    float fogStart = u_FogStart;
    float fogEnd = u_FogEnd; 

    vec4 diffuseColor = showRedAndGray(texture(u_BlockTex, v_TexCoord, v_MaterialMipBias), fogColor);
    vec4 tintColor = showRedAndGray(v_Vertcolor, fogColor);

#ifdef USE_FRAGMENT_DISCARD
    if (diffuseColor.a < v_MaterialAlphaCutoff) {
        discard;
    }
#endif

    // Apply per-vertex color
    //showRedAndGray 여기에 적용되서 한번만 작동되게 바꾸고 안개색, 안개 거리 조절도 함수 내에서 건들도록 바꾸기?
    diffuseColor.rgb *= tintColor.rgb * v_Lightcolor.rgb;

    // Apply ambient occlusion "shade" 부드러운 조명
    diffuseColor.rgb *= tintColor.a;

    if(fogColor.g == 0 && fogColor.b == 0) {
        if(fogColor.r * 255 < 1) {
            fogStart = 0.0;
            fogEnd = 20.0;
        } else
        if(fogColor.r * 255 < 2) {
            fogStart = 0.0;
            fogEnd = 50.0;
        } else
        if(fogColor.r * 255 < 3) {
            fogStart = 30.0;
            fogEnd = 80.0;
        }
        if(fogColor.r * 255 < 4) {

        }
    }

    fragColor = _linearFog(diffuseColor, v_FragDistance, fogColor, fogStart, fogEnd);
}