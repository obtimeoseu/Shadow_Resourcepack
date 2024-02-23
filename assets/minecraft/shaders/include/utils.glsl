#version 150
#define PI 3.1415926

mat2 mat2_rotate_z(float radians) {
    return mat2(
        cos(radians), -sin(radians),
        sin(radians), cos(radians)
    );
}

mat2 Rotate(float a)
{
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

vec3 hue(float h)
{
    float r = abs(h * 6.0 - 3.0) - 1.0;
    float g = 2.0 - abs(h * 6.0 - 2.0);
    float b = 2.0 - abs(h * 6.0 - 4.0);
    return clamp(vec3(r,g,b), 0.0, 1.0);
}

vec3 HSVtoRGB(vec3 hsv) {
    return ((hue(hsv.x) - 1.0) * hsv.y + 1.0) * hsv.z;
}

float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * .1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
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
const vec3[] EP2_COLORS = vec3[](
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
    vec3(0.314821 / 3, 0.080955, 0.661491 * 3)
);

const mat4 EP_SCALE_TRANSLATE = mat4(
    0.6, 0.0, 0.0, 0.25,
    0.0, 0.6, 0.0, 0.25,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
);	

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

// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.
int hash(int x) {
    x += ( x << 10 );
    x ^= ( x >>  6 );
    x += ( x <<  3 );
    x ^= ( x >> 11 );
    x += ( x << 15 );
    return x;
}

int noise(ivec2 v, int seed) {
    return hash(v.x ^ hash(v.y + seed) ^ hash(seed));
}

float lum(vec4 col)
{
    return col.r * 0.299 + col.g * 0.587 + col.b * 0.114;
}

//int vecToInt(vec3 color) {
//	return (
//		(int)((color.r * 255) * pow(256, 2)) +
//		(int)((color.g * 255) * pow(256, 1)) +
//		(int)((color.b * 255) * pow(256, 0))
//	);
//}

bool adjacentCheck(float valueA, float valueB) {
	float compareLess = valueB - 0.01;
	float compareMore = valueB + 0.01;
	return (valueA > compareLess && valueA < compareMore);
}

bool compareColor(vec4 colorA, vec4 colorB) {
	return (
		adjacentCheck(colorA.r * 255, colorB.r * 255) &&
		adjacentCheck(colorA.g * 255, colorB.g * 255) &&
		adjacentCheck(colorA.b * 255, colorB.b * 255) &&
		adjacentCheck(colorA.a * 255, colorB.a * 255)
	);
}

bool compareColor(vec3 colorA, vec3 colorB) {
	return (
		adjacentCheck(colorA.r * 255, colorB.r * 255) &&
		adjacentCheck(colorA.g * 255, colorB.g * 255) &&
		adjacentCheck(colorA.b * 255, colorB.b * 255)
	);
}

vec4 getGradientWithResolution(vec4 gradientColor, vec4 gradientResolution) {
    return abs(floor( gradientColor * gradientResolution ) / gradientResolution);
}

vec4 get_customEmssiveColor(vec4 inputColor, vec4 lightColor, vec4 emssiveColor) { // 야광
	float invertedGrayScaleLight = (1 - (lightColor.r + lightColor.g + lightColor.b) / 3);
	invertedGrayScaleLight *= invertedGrayScaleLight * invertedGrayScaleLight;
	if(lightColor.r < 0.5) { lightColor.r = (0.5 - lightColor.r) + 0.5;}
	if(lightColor.g < 0.5) { lightColor.g = (0.5 - lightColor.g) + 0.5;}
	if(lightColor.b < 0.5) { lightColor.b = (0.5 - lightColor.b) + 0.5;}

	vec4 customEmssiveColor = inputColor * lightColor;
	customEmssiveColor.r = customEmssiveColor.r + (emssiveColor.r - customEmssiveColor.r) * invertedGrayScaleLight * emssiveColor.a;
	customEmssiveColor.g = customEmssiveColor.g + (emssiveColor.g - customEmssiveColor.g) * invertedGrayScaleLight * emssiveColor.a;
	customEmssiveColor.b = customEmssiveColor.b + (emssiveColor.b - customEmssiveColor.b) * invertedGrayScaleLight * emssiveColor.a;
	return customEmssiveColor;
}

// for item
vec4 apply_emissive_perspective_for_item(vec4 inputColor, vec4 lightColor, vec4 tintColor, vec4 vertexColor, float vertexDistance, float zPos, int isGui, float FogStart, float FogEnd, float inputAlpha, vec2 screenSize, vec4 screenFragCoord, float gameTime) {
	vec4 remappingColor = inputColor * tintColor * lightColor;

	if(adjacentCheck(inputAlpha, 255.0)) {        // GUI O | FirstPerson O | ThirdPerson O | Emssive X
		// Default
	} else
	if(adjacentCheck(inputAlpha, 254.0)) { // GUI O | FirstPerson O | ThirdPerson O | Emssive O
		if(isGui == 1) {
			remappingColor = inputColor * tintColor;
			remappingColor.a = 1.0;
		} else {
			remappingColor = inputColor * tintColor;
			remappingColor.a = 1.0;
		}
	} else
	if(adjacentCheck(inputAlpha, 253.0)) { // GUI O | FirstPerson O | ThirdPerson X | Emssive X
		if(isGui == 1) {
			remappingColor.a = 1.0;
		} else {
			if(FogStart > FogEnd) {
				if(vertexDistance < 800) {
					remappingColor.a = 1.0;
				} else {
					remappingColor.a = 0.0;
				}
			} else {
				remappingColor.a = 0.0;
			}
		}
	} else
	if(adjacentCheck(inputAlpha, 252.0)) { // GUI O | FirstPerson O | ThirdPerson X | Emssive O
		if(isGui == 1) {
			remappingColor.a = 1.0;
		} else {
			if(FogStart > FogEnd) {
				if(vertexDistance < 800) {
					remappingColor = inputColor * tintColor;
					remappingColor.a = 1.0;
				} else {
					remappingColor.a = 0.0;
				}
			} else {
				remappingColor.a = 0.0;
			}
		}
	} else
	if(adjacentCheck(inputAlpha, 251.0)) { // GUI O | FirstPerson X | ThirdPerson O | Emssive X
		if(isGui == 1) {
			remappingColor.a = 1.0;
		} else {
			if(FogStart > FogEnd) {
				if(vertexDistance < 800) {
					remappingColor.a = 0.0;
				} else {
					remappingColor.a = 1.0;
				}
			} else {
				remappingColor.a = 1.0;
			}
		}
	} else
	if(adjacentCheck(inputAlpha, 250.0)) { // GUI O | FirstPerson X | ThirdPerson O | Emssive O
		if(isGui == 1) {
			remappingColor.a = 1.0;
		} else {
			if(FogStart > FogEnd) {
				if(vertexDistance < 800) {
					remappingColor.a = 0.0;
				} else {
					remappingColor.a = 1.0;
					remappingColor = inputColor * tintColor;
				}
			} else {
				remappingColor = inputColor * tintColor;
				remappingColor.a = 1.0;
			}
		}
	} else
	if(adjacentCheck(inputAlpha, 249.0)) { // GUI X | FirstPerson O | ThirdPerson O | Emssive X
		if(isGui == 1) {
			remappingColor.a = 0.0;
		} else {
			remappingColor.a = 1.0;
		}
	} else
	if(adjacentCheck(inputAlpha, 248.0)) {	// GUI X | FirstPerson O | ThirdPerson O | Emssive O
		if(isGui == 1) {
			remappingColor.a = 0.0;
		} else {
			remappingColor = inputColor * tintColor;
			remappingColor.a = 1.0;
		}
	} else
	if(adjacentCheck(inputAlpha, 247.0)) {	// GUI X | FirstPerson O | ThirdPerson X | Emssive X
		if(isGui == 1) {
			remappingColor.a = 0.0;
		} else {
			if(FogStart > FogEnd) {
				if(vertexDistance < 800) {
					remappingColor.a = 1.0;
				} else {
					remappingColor.a = 0.0;
				}
			} else {
				remappingColor.a = 0.0;
			}
		}
	} else
	if(adjacentCheck(inputAlpha, 246.0)) {	// GUI X | FirstPerson O | ThirdPerson X | Emssive O
		if(isGui == 1) {
			remappingColor.a = 0.0;
		} else {
			if(FogStart > FogEnd) {
				if(vertexDistance < 800) {
					remappingColor = inputColor * tintColor;
					remappingColor.a = 1.0;
				} else {
					remappingColor.a = 0.0;
				}
			} else {
				remappingColor.a = 0.0;
			}
		}
	} else
	if(adjacentCheck(inputAlpha, 245.0)) {	// GUI X | FirstPerson X | ThirdPerson O | Emssive X
		if(isGui == 1) {
			remappingColor.a = 0.0;
		} else {
			if(FogStart > FogEnd) {
				if(vertexDistance < 800) {
					remappingColor.a = 0.0;
				} else {
					remappingColor.a = 1.0;
				}
			} else {
				remappingColor.a = 1.0;
			}
		}
	} else
	if(adjacentCheck(inputAlpha, 244.0)) {	// GUI X | FirstPerson X | ThirdPerson O | Emssive O
		if(isGui == 1) {
			remappingColor.a = 0.0;
		} else {
			if(FogStart > FogEnd) {
				if(vertexDistance < 800) {
					remappingColor.a = 0.0;
				} else {
					remappingColor.a = 1.0;
					remappingColor = inputColor * tintColor;
				}
			} else {
				remappingColor = inputColor * tintColor;
				remappingColor.a = 1.0;
			}
		}
	} else
	if(adjacentCheck(inputAlpha, 243.0)) { // 엔드 포탈 효과 빨강
		remappingColor.a = 1.0;
		remappingColor.rgb = vec3(0, 0, 0);
		for (int i = 6; i < 16; i++) {
			vec4 proj = vec4(screenFragCoord.xy/screenSize, 0, 1) * end_portal_layer(float(i + 1), gameTime);
			float pixel = hash12(floor(fract(proj.xy/proj.w)*256.0));
			remappingColor.rgb += (step(0.95, pixel)* 0.2 + step(0.99, pixel) * 0.8) * (EP_COLORS[i]);
		}
		//remappingColor *= vertexColor * vertexColor * lightColor;
	} else
	if(adjacentCheck(inputAlpha, 242.0)) { // 그림자 제거 (fsh 에서 제거중)

	} else
	if(adjacentCheck(inputAlpha, 241.0)) { // 그림자 제거 (fsh 에서 제거중) + 발광
		if(isGui == 1) {
			remappingColor = inputColor * tintColor;
			remappingColor.a = 1.0;
		} else {
			remappingColor = inputColor * tintColor;
			remappingColor.a = 1.0;
		}
	} else
	if(adjacentCheck(inputAlpha, 240.0)) { // 텍스쳐 조명에 따른 투명도 변경
		float grayScaleLight = (lightColor.r + lightColor.g + lightColor.b) / 3;

		remappingColor.a = 0;//.275;
		if(grayScaleLight > 0.5) {
			remappingColor.a = (grayScaleLight - 0.5) * 3;// + 0.275;
			if(remappingColor.a > 1.0) remappingColor.a = 1.0;
		}
	} else
	if(adjacentCheck(inputAlpha, 239.0)) { // 텍스쳐 조명에 따른 투명도 변경
		float grayScaleLight = (lightColor.r + lightColor.g + lightColor.b) / 3;

		remappingColor.a = 0;//.275;
		if(grayScaleLight > 0.5) {
			remappingColor.a = (grayScaleLight - 0.5) * 3;// + 0.275;
			if(remappingColor.a > 1.0) remappingColor.a = 1.0;
		}
	} else
	if(adjacentCheck(inputAlpha, 238.0)) { // 텍스쳐 조명에 따른 투명도 변경
		remappingColor = inputColor * tintColor;

		float grayScaleLight = (lightColor.r + lightColor.g + lightColor.b) / 3;

		remappingColor.a = 0;//.275;
		if(grayScaleLight > 0.5) {
			remappingColor.a = (grayScaleLight - 0.5) * 3 + 0.275;
			if(remappingColor.a > 1.0) remappingColor.a = 1.0;
		}
	} else
	if(adjacentCheck(inputAlpha, 237.0)) { // 엔드 포탈 효과 빨강
		remappingColor.a = 1.0;
		remappingColor.rgb =  vec3(1, 1, 1);
		for (int i = 6; i < 16; i++) {
			vec4 proj = vec4(screenFragCoord.xy/screenSize, 0, 1) * end_portal_layer(float(i + 1), gameTime);
			float pixel = hash12(floor(fract(proj.xy/proj.w)*256.0));
			remappingColor.rgb -= (step(0.95, pixel)* 0.2 + step(0.99, pixel) * 0.8) * (EP2_COLORS[i]);
		}
		//remappingColor *= vertexColor * vertexColor * lightColor;
	} else
	if(adjacentCheck(inputAlpha, 1.0)) { // GUI O | FirstPerson X | ThirdPerson X | Emssive X
		if(isGui == 1) {
			remappingColor.a = 1.0;
		} else {
			remappingColor.a = 0.0;
		}
	} else
	if(adjacentCheck(inputAlpha, 2.0)) { // GUI O | FirstPerson X | ThirdPerson X | Emssive O
		if(isGui == 1) {
			remappingColor.a = 1.0;
			remappingColor = inputColor * tintColor;
		} else {
			remappingColor.a = 0.0;
		}
	}// else if(adjacentCheck(inputAlpha, 242.0)) { // 야광
	//	if(isGui == 1) {
	//		remappingColor.a = 1.0;
	//	} else {
	//		vec4 emssiveColor = (vec4(0, 255, 255, 63) / 255);
	//		remappingColor.a = 1.0;
	//	}
	//}

	// 발광 효과
	if(compareColor(tintColor.rgb, vec3(255, 255, 254) / 255.0)) {
		remappingColor /= tintColor;
		if(!adjacentCheck(inputAlpha, 241.0) && !adjacentCheck(inputAlpha, 237.0) && !adjacentCheck(inputAlpha, 243.0)) { // 완전 발광 적용하고 있는 텍스쳐 부분 제외
			remappingColor /= lightColor; // 조명 조정
			remappingColor.rgb *= 1.5; // 채도 조정
			if(inputColor.a > 0) {
				remappingColor.a = 1.0; // 투명도 강제 조정
			}
		}
		remappingColor.rgb = mix(remappingColor.rgb, vec3(0.8, 0.75, 0.6), 0.15); // 명도 조정
	}
	// 피격 효과
	if(compareColor(tintColor.rgb, vec3(255, 102, 102) / 255.0)) {
		remappingColor /= tintColor;
		remappingColor.rgb = mix(remappingColor.rgb, vec3(1.0, 0.25, 0.25), 0.4);   // 바닐라
		
		//remappingColor.rgb = mix(inputColor.rgb, vec3(1.0, 1.0, 1.0), 0.2) * lightColor.rgb;    // 흰색
		//remappingColor.rgb = mix(inputColor.rgb, vec3(1.0, 1.0, 0.65), 0.25) * lightColor.rgb;   // 전기
		//remappingColor.rgb = mix(inputColor.rgb, vec3(0.5, 0.7, 1.0), 0.25) * lightColor.rgb;    // 얼음
		//remappingColor.rgb = mix(inputColor.rgb, vec3(0.5, 0.1, 0.6), 0.25) * lightColor.rgb;    // 독
		//remappingColor.rgb = mix(inputColor.rgb, vec3(1.0, 0.5, 0.3), 0.25) * lightColor.rgb;    // 불
		//remappingColor.rgb = mix(inputColor.rgb, vec3(1.0, 0.25, 0.25) * lightColor.rgb;    // 바닐라
	}

	return remappingColor;
}

vec4 showRedAndGray(vec4 color, vec4 fogColor, int isGui) {
    float gray = (color.r + color.g + color.b) / 3;

		if(isGui > 0) {
			return color;
		}

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

vec3 showRedAndGray(vec3 color, vec4 fogColor, int isGui) {
    float gray = (color.r + color.g + color.b) / 3;

		if(isGui > 0) {
			return color;
		}

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