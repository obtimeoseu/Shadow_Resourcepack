#version 150

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
vec4 apply_emissive_perspective_for_item(vec4 inputColor, vec4 lightColor, vec4 tintColor, float vertexDistance, float zPos, int isGui, float FogStart, float FogEnd, float inputAlpha) {
	vec4 remappingColor = inputColor * lightColor;

	// 염색 색에 따라 데미지 입는 색 설정
	//if(compareColor(tintColor.rgb, vec3(254, 254, 254) / 255.0)) {
		//remappingColor.rgb = mix(inputColor.rgb, vec3(1.0, 1.0, 1.0), 0.2) * lightColor.rgb;    // 일반
		//remappingColor.rgb = mix(inputColor.rgb, vec3(1.0, 1.0, 0.65), 0.25) * lightColor.rgb;   // 전기
		//remappingColor.rgb = mix(inputColor.rgb, vec3(0.5, 0.7, 1.0), 0.25) * lightColor.rgb;    // 얼음
		//remappingColor.rgb = mix(inputColor.rgb, vec3(0.5, 0.1, 0.6), 0.25) * lightColor.rgb;    // 독
		//remappingColor.rgb = mix(inputColor.rgb, vec3(1.0, 0.5, 0.3), 0.25) * lightColor.rgb;    // 불
		//remappingColor.rgb = mix(inputColor.rgb, vec3(1.0, 0.25, 0.25), 0.4) * lightColor.rgb;   // 크리티컬
	//}

	if(adjacentCheck(inputAlpha, 255.0)) {        // GUI O | FirstPerson O | ThirdPerson O | Emssive X
		// Default
	} else
	if(adjacentCheck(inputAlpha, 254.0)) { // GUI O | FirstPerson O | ThirdPerson O | Emssive O
		if(isGui == 1) {
			remappingColor = inputColor;
			remappingColor.a = 1.0;
		} else {
			remappingColor = inputColor;
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
					remappingColor = inputColor;
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
					remappingColor = inputColor;
				}
			} else {
				remappingColor = inputColor;
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
			remappingColor = inputColor;
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
					remappingColor = inputColor;
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
					remappingColor = inputColor;
				}
			} else {
				remappingColor = inputColor;
				remappingColor.a = 1.0;
			}
		}
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
			remappingColor = inputColor;
		} else {
			remappingColor.a = 0.0;
		}
	} else
	if(adjacentCheck(inputAlpha, 243.0)) { // GUI O | FirstPerson X | ThirdPerson X | Emssive - (only GUI don't need Emssive setting)
		float grayScaleLight = (lightColor.r + lightColor.g + lightColor.b) / 3;

		remappingColor.a = 0.0;
		if(grayScaleLight > 0.5) {
			remappingColor.a = (grayScaleLight - 0.5) * 2;
		}
	}// else if(adjacentCheck(inputAlpha, 242.0)) { // 야광
	//	if(isGui == 1) {
	//		remappingColor.a = 1.0;
	//	} else {
	//		vec4 emssiveColor = (vec4(0, 255, 255, 63) / 255);
	//		remappingColor.a = 1.0;
	//	}
	//}
	return remappingColor;
}

vec4 showRedAndGray(vec4 color, vec4 fogColor, int isGui) {
		if(isGui > 0) {
			return color;
		}

    if(fogColor.r != fogColor.g || fogColor.r != fogColor.b) {
			return color;
    }

    if(
			(color.g < 0.275 && color.b < 0.425 && color.r > 0.28) ||
			(color.g < 0.15 && color.b < 0.15 && color.r > 0.15)
    ) {
			return color;
    }

    float gray = (color.r + color.g + color.b) / 3;
    color.rgb = vec3(gray);
    return color;
}

vec3 showRedAndGray(vec3 color, vec4 fogColor, int isGui) {
		if(isGui > 0) {
			return color;
		}

    if(fogColor.r != fogColor.g || fogColor.r != fogColor.b) {
			return color;
    }

    if(
			(color.g < 0.275 && color.b < 0.425 && color.r > 0.28) ||
			(color.g < 0.15 && color.b < 0.15 && color.r > 0.15)
    ) {
			return color;
    }

    float gray = (color.r + color.g + color.b) / 3;
    color.rgb = vec3(gray);
    return color;
}