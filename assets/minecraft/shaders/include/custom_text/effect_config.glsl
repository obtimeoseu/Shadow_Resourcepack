// G 그린 값을 매개변수로 사용
// 단위는 4부터 시작해서 4씩 늘려가며 타입 설정 필요
// 0과 252은 미사용 추천

// B 블루 값 특정 조건일 때에만 아래 케이스들 동작
// 10~13 일반 그림자
// 14~17 아래 그림자
// 18~1b 우측 그림자
// 1c~1f 그림자 없음


TEXT_EFFECT_CASE(0) {
}
TEXT_EFFECT_CASE(4) {
    apply_shaking_movement();
    //apply_glowing();
    //draw_shadow();
    //apply_shimmer();
    override_text_color(rgb(255, 82, 82));
    override_shadow_color(rgb(100, 20, 80));
    apply_shadow_by_sub_type();
}
/*
TEXT_EFFECT(240, 240, 0) {
    apply_shaking_movement();
    override_text_color(rgb(255, 82, 82));
    override_shadow_color(rgb(100, 20, 80));
}

TEXT_EFFECT(240, 240, 4) {
    apply_waving_movement();
    override_text_color(rgb(255, 235, 60));
    override_shadow_color(rgb(150, 60, 30));
}

TEXT_EFFECT(240, 240, 8) {
    apply_iterating_movement();
    override_text_color(rgb(86, 235, 86));
    override_shadow_color(rgb(20, 80, 90));
}

TEXT_EFFECT(240, 240, 12) {
    apply_flipping_movement();
    override_text_color(rgb(74, 222, 209));
    override_shadow_color(rgb(37, 71, 150));
}

TEXT_EFFECT(240, 240, 16) {
    apply_skewing_movement();
    override_text_color(rgb(122, 80, 251));
    override_shadow_color(rgb(40, 40, 140));
}

TEXT_EFFECT(240, 240, 20) {
    override_text_color(rgb(255, 82, 82));
    apply_outline(rgb(100, 20, 80));
}

TEXT_EFFECT(240, 240, 24) {
    apply_gradient(rgb(255, 235, 120), rgb(255, 82, 82));
}

TEXT_EFFECT(240, 240, 28) {
    apply_rainbow();
}

TEXT_EFFECT(240, 240, 32) {
    override_text_color(rgb(86, 235, 86));
    override_shadow_color(rgb(20, 80, 90));
    apply_shimmer();
}

TEXT_EFFECT(240, 240, 36) {
    override_text_color(rgb(255, 255, 255));
    apply_chromatic_abberation();
    remove_text_shadow();
}

TEXT_EFFECT(240, 240, 40) {
    apply_metalic(rgb(160, 160, 200));
}

TEXT_EFFECT(240, 240, 44) {
    override_text_color(rgb(255, 20, 20));
    apply_fire();
}

TEXT_EFFECT(240, 240, 48) {
    apply_growing_movement();
    override_text_color(rgb(255, 82, 82));
    override_shadow_color(rgb(100, 20, 80));
}

TEXT_EFFECT(240, 240, 52) {
    override_text_color(rgb(255, 235, 60));
    override_shadow_color(rgb(150, 60, 30));
    apply_fade(rgb(86, 235, 86));
}

TEXT_EFFECT(240, 240, 56) {
    override_text_color(rgb(86, 235, 86));
    override_shadow_color(rgb(20, 80, 90));
    apply_blinking();
}

TEXT_EFFECT(240, 240, 60) {
    override_text_color(rgb(74, 222, 209));
    override_shadow_color(rgb(37, 71, 150));
    apply_glowing();
}

TEXT_EFFECT(94, 171, 136) {
    apply_waving_movement(1.0, 1.5);
    apply_gradient(rgb(189, 221, 100), rgb(50, 117, 132));
    override_shadow_color(rgb(70, 70, 100));
}

TEXT_EFFECT(255, 255, 248) {
    apply_vertical_shadow();
    apply_metalic(rgb(255, 255, 255), rgb(150, 163, 177) * 0.95);
    override_shadow_color(rgb(70, 70, 100));
}
*/