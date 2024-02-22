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