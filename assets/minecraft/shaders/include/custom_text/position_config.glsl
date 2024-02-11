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
    textData.position.y += 10;
}

TEXT_POSITION_CASE(240) {
    textData.position.x -= floor(textData.scrSize.x / 2);
    textData.position.y += floor(textData.scrSize.y / 2);
    
    textData.position.x -= 95;
    textData.position.y += 11;
}

TEXT_POSITION_CASE(220) {
    textData.position.y += 10;
}

TEXT_POSITION_CASE(200) {
    textData.position.y -= 18;
}