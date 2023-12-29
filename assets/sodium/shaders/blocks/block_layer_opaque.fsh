#version 330 core

#import <sodium:include/fog.glsl>

in vec3 v_ColorModulator; // The interpolated vertex color
in vec3 v_Vertcolor;
in vec3 v_Lightcolor;
in vec2 v_TexCoord; // The interpolated block texture coordinates

in float v_FragDistance; // The fragment's distance from the camera

in float v_MaterialMipBias;
in float v_MaterialAlphaCutoff;

uniform sampler2D u_BlockTex; // The block atlas texture

uniform vec4 u_FogColor; // The color of the shader fog
uniform float u_FogStart; // The starting position of the shader fog
uniform float u_FogEnd; // The ending position of the shader fog

out vec4 out_FragColor; // The output fragment for the color framebuffer

vec4 showRedAndGray(vec4 color) {
    if(
        (color.g < 0.275 && color.b < 0.425 && color.r > 0.28) || // 밝은 빨강 (조건 여유)
        (color.g < 0.15 && color.b < 0.15 && color.r > 0.15) //어두운 빨강 (조건 빡셈)
    ) {
        return color;
    } else {
        float gray = (color.r + color.g + color.b) / 3;
        color.rgb = vec3(gray);
        return color;
    }
}
vec3 showRedAndGray(vec3 color) {
    if(color.g < 0.275 && color.b < 0.275 && color.r > 0.35) {
        return color;
    } else {
        float gray = (color.r + color.g + color.b) / 3;
        color.rgb = vec3(gray);
        return color;
    }
}

void main() {
    vec4 diffuseColor = showRedAndGray(texture(u_BlockTex, v_TexCoord, v_MaterialMipBias));
    vec3 tintColor = showRedAndGray(v_Vertcolor);


#ifdef USE_FRAGMENT_DISCARD
    if (diffuseColor.a < v_MaterialAlphaCutoff) {
        discard;
    }
#endif

    // Modulate the color (used by ambient occlusion and per-vertex colouring)
    diffuseColor.rgb *= tintColor * v_Lightcolor;

    out_FragColor = _linearFog(diffuseColor, v_FragDistance, u_FogColor, u_FogStart, u_FogEnd);
}