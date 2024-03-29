#version 150

#define MINECRAFT_LIGHT_POWER   (0.6)
#define MINECRAFT_AMBIENT_LIGHT (0.4)

vec4 getDarkerLight(vec4 color) {
    float grayScaleLight = (color.r + color.g + color.b) / 3;

    color.r = pow(grayScaleLight, 1.0) - 0.05;
    color.g = pow(grayScaleLight, 1.1) - 0.125;
    color.b = pow(grayScaleLight, 1.1) - 0.125;
    return color;
}

vec4 getDarkerLight(vec4 color, int isGui) {
    float grayScaleLight = (color.r + color.g + color.b) / 3;
    if(isGui == 0) {
        color.r = pow(grayScaleLight, 1.0) - 0.05;
        color.g = pow(grayScaleLight, 1.1) - 0.125;
        color.b = pow(grayScaleLight, 1.1) - 0.125;
    }
    return color;
}

vec4 minecraft_mix_light(vec3 lightDir0, vec3 lightDir1, vec3 normal, vec4 color) {
    lightDir0 = normalize(lightDir0);
    lightDir1 = normalize(lightDir1);
    float light0 = max(0.0, dot(lightDir0, normal));
    float light1 = max(0.0, dot(lightDir1, normal));
    float lightAccum = min(1.0, (light0 + light1) * MINECRAFT_LIGHT_POWER + MINECRAFT_AMBIENT_LIGHT);
    return vec4(color.rgb * lightAccum, color.a);
}

vec4 minecraft_sample_lightmap(sampler2D lightMap, ivec2 uv) {
    return getDarkerLight(texture(lightMap, clamp(uv / 256.0, vec2(0.5 / 16.0), vec2(15.5 / 16.0))));
}
