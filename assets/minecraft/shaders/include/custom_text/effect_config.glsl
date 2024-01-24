// 4 단위로 끊으며 조건 추가할것,
// 252 이상 값, 64이하의 값 사용 불가능
// 168, 84 사용 비추천 (바닐라 색코드에서 주로 사용하는 값)

// 사용 가능 범위: 248 ~ 68

TEXT_EFFECT_CASE(248) { // 그림자 제거
    if(textData.isShadow) {
        override_text_color(vec4(255, 255, 255, 0) / 255.0);
    }
}

TEXT_EFFECT_CASE(244) { // 흰색
    override_text_color(vec3(255, 255, 255) / 255.0);
    draw_shadow();
}

TEXT_EFFECT_CASE(240) { // 회색
    override_text_color(vec3(255, 255, 255) / 255.0 * 0.75);
    draw_shadow();
}

TEXT_EFFECT_CASE(236) {
    override_text_color(vec3(255, 255, 255) / 255.0);
    //apply_waving_movement(0.4);
    apply_shaking_movement();
    make_bigger_25();
    draw_shadow();
}

TEXT_EFFECT_CASE(220) { // 보스바용 흰색 , 기존 그림자 존재
    override_text_color(vec3(255, 255, 255) / 255.0);
    if(textData.isShadow) {
        override_text_color(vec4(255, 255, 255, 0) / 255.0);
    }
    apply_outline(rgb(0, 0, 0));
}
TEXT_EFFECT_CASE(216) { // 보스바용 하늘색 , 기존 그림자 존재
    override_text_color(vec3(84, 255, 255) / 255.0);
    if(textData.isShadow) {
        override_text_color(vec4(255, 255, 255, 0) / 255.0);
    }
    apply_outline(rgb(0, 0, 0));
}

TEXT_EFFECT_CASE(200) { // 빨강
    override_text_color(vec3(168, 0, 0) / 255.0);
    //apply_shaking_movement();
    draw_shadow();
}

TEXT_EFFECT_CASE(196) { // 빨강 + 흔들림
    override_text_color(vec3(168, 0, 0) / 255.0);
    apply_shaking_movement();
    draw_shadow();
}

TEXT_EFFECT_CASE(194) { // 빨강 + 거대 텍스트 + 흔들림
    override_text_color(vec3(168, 0, 0) / 255.0);
    make_bigger_25();
    apply_shaking_movement();
    draw_shadow();
}
/*
TEXT_EFFECT_CASE(244) {
    apply_shaking_movement();
    override_text_color(rgb(255, 82, 82));
    override_shadow_color(rgb(100, 20, 80));
}

TEXT_EFFECT_CASE(244) {
    apply_waving_movement();
    override_text_color(rgb(255, 235, 60));
    override_shadow_color(rgb(150, 60, 30));
}

TEXT_EFFECT_CASE(244) {
    apply_iterating_movement();
    override_text_color(rgb(86, 235, 86));
    override_shadow_color(rgb(20, 80, 90));
}

TEXT_EFFECT_CASE(244) {
    apply_flipping_movement();
    override_text_color(rgb(74, 222, 209));
    override_shadow_color(rgb(37, 71, 150));
}

TEXT_EFFECT_CASE(244) {
    apply_skewing_movement();
    override_text_color(rgb(122, 80, 251));
    override_shadow_color(rgb(40, 40, 140));
}

TEXT_EFFECT_CASE(244) {
    override_text_color(rgb(255, 82, 82));
    apply_outline(rgb(100, 20, 80));
}

TEXT_EFFECT_CASE(244) {
    apply_gradient(rgb(255, 235, 120), rgb(255, 82, 82));
}

TEXT_EFFECT_CASE(244) {
    apply_rainbow();
}

TEXT_EFFECT_CASE(244) {
    override_text_color(rgb(86, 235, 86));
    override_shadow_color(rgb(20, 80, 90));
    apply_shimmer();
}

TEXT_EFFECT_CASE(244) {
    override_text_color(rgb(255, 255, 255));
    apply_chromatic_abberation();
    remove_text_shadow();
}

TEXT_EFFECT_CASE(244) {
    apply_metalic(rgb(160, 160, 200));
}

TEXT_EFFECT_CASE(244) {
    override_text_color(rgb(255, 20, 20));
    apply_fire();
}

TEXT_EFFECT_CASE(244) {
    apply_growing_movement();
    override_text_color(rgb(255, 82, 82));
    override_shadow_color(rgb(100, 20, 80));
}

TEXT_EFFECT_CASE(244) {
    override_text_color(rgb(255, 235, 60));
    override_shadow_color(rgb(150, 60, 30));
    apply_fade(rgb(86, 235, 86));
}

TEXT_EFFECT_CASE(244) {
    override_text_color(rgb(86, 235, 86));
    override_shadow_color(rgb(20, 80, 90));
    apply_blinking();
}

TEXT_EFFECT_CASE(244) {
    override_text_color(rgb(74, 222, 209));
    override_shadow_color(rgb(37, 71, 150));
    apply_glowing();
}

TEXT_EFFECT_CASE(244) {
    apply_waving_movement(1.0, 1.5);
    apply_gradient(rgb(189, 221, 100), rgb(50, 117, 132));
    override_shadow_color(rgb(70, 70, 100));
}

TEXT_EFFECT_CASE(244) {
    apply_vertical_shadow();
    apply_metalic(rgb(255, 255, 255), rgb(150, 163, 177) * 0.95);
    override_shadow_color(rgb(70, 70, 100));
}
*/