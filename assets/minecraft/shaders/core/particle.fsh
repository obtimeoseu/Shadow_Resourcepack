#version 150

#moj_import <fog.glsl>
#moj_import <utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;

in float vertexDistance;
in vec2 texCoord0;
in vec4 vertexColor;
in vec4 screenPos;

out vec4 fragColor;

void main() {
    vec4 color = showRedAndGray(texture(Sampler0, texCoord0), FogColor, 0) * showRedAndGray(vertexColor, FogColor, 0) * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }


    vec2 screenSize = gl_FragCoord.xy / (screenPos.xy/screenPos.w*0.5+0.5);
    if(compareColor(texture(Sampler0, texCoord0).rgb, vec3(92, 0, 0) / 255.0)) {

		color.a = 1.0;
		color.rgb = vec3(0, 0, 0);
		for (int i = 6; i < 16; i++) {
			vec4 proj = vec4(gl_FragCoord.xy/screenSize, 0, 1) * end_portal_layer(float(i + 1), GameTime);
			float pixel = hash12(floor(fract(proj.xy/proj.w)*256.0));
			color.rgb += (step(0.95, pixel)* 0.2 + step(0.99, pixel) * 0.8) * (EP_COLORS[i]);
		}

    }

    float fogStart = FogStart;
    float fogEnd = FogEnd;

    if(FogColor.g == 0 && FogColor.b == 0) {
        if(FogColor.r * 255 < 1) {
            fogStart = 0.0;
            fogEnd = 20.0;
        } else
        if(FogColor.r * 255 < 2) {
            fogStart = 0.0;
            fogEnd = 50.0;
        } else
        if(FogColor.r * 255 < 3) {
            fogStart = 30.0;
            fogEnd = 80.0;
        }
    }

    fragColor = linear_fog(color, vertexDistance, fogStart, fogEnd, FogColor);
}
