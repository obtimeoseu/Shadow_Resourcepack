// 4 단위로 끊으며 조건 추가할것,
// 252 이상 값, 64이하의 값 사용 불가능
// 168, 84 사용 비추천 (바닐라 색코드에서 주로 사용하는 값)

// 사용 가능 범위: 248 ~ 68

TEXT_POSITION_CASE(248) {
}

TEXT_POSITION_CASE(244) {
    textData.position.x -= floor(textData.scrSize.x / 2);
    textData.position.y += floor(textData.scrSize.y / 2);
    
    textData.position.x -= 96;
    textData.position.y += 28;
}

TEXT_POSITION_CASE(240) {
    textData.position.x -= floor(textData.scrSize.x / 2);
    textData.position.y += floor(textData.scrSize.y / 2);
    
    textData.position.x -= 96;
    textData.position.y += 30;
}

TEXT_POSITION_CASE(236) {
    textData.position.x -= floor(textData.scrSize.x / 2);
    textData.position.y += floor(textData.scrSize.y / 2);
    
    textData.position.x -= 96;
    textData.position.y += 32;
}

TEXT_POSITION_CASE(232) {
    textData.position.x -= floor(textData.scrSize.x / 2);
    textData.position.y += floor(textData.scrSize.y / 2);
    
    textData.position.x -= 96;
    textData.position.y += 34;
}
TEXT_POSITION_CASE(228) { // CPR
    textData.position.x -= floor(textData.scrSize.x / 2);
    textData.position.y += floor(textData.scrSize.y / 2);
    
    textData.position.x -= 66;
    textData.position.y -= 100;
}
TEXT_POSITION_CASE(224) { // 워키토키
    //textData.position.x -= floor(textData.scrSize.x / 2);
    //textData.position.y += floor(textData.scrSize.y / 2);
    
    //textData.position.x -= 96;
    //textData.position.y -= 80;
}

TEXT_POSITION_CASE(220) {
    textData.position.y += 10;
}

TEXT_POSITION_CASE(200) {
    textData.position.y -= 18;
}
TEXT_POSITION_CASE(180) {
    //textData.position.z = 0;
    textData.position.x -= textData.scrSize.x;
    textData.position.y -= floor(textData.scrSize.y / 2);
}