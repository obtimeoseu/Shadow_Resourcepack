#version 150

in vec4 vertexColor;

flat in vec2 flatCorner;
in vec2 Pos1;
in vec2 Pos2;
in vec4 Coords;
in vec2 position;

uniform vec4 ColorModulator;

out vec4 fragColor;

vec4 colors[] = vec4[](
    vec4(0),
    vec4(0, 0, 0, 255) / 255,      // black
    vec4(107, 107, 107, 255) / 255, // corner light
    vec4(83, 83, 83, 255) / 255,  // plane
    vec4(51, 51, 51, 255) / 255  // corner dark
);

int bitmapLU[] = int[](
    0, 0, 1, 1,
    0, 1, 2, 2,
    1, 2, 2, 2,
    1, 2, 2, 2
);
int bitmapRU[] = int[](
    1, 0, 0, 0,
    2, 1, 0, 0,
    2, 3, 1, 0,
    3, 4, 4, 1
);
int bitmapLD[] = int[](
    1, 2, 2, 3,
    0, 1, 3, 4,
    0, 0, 1, 4,
    0, 0, 0, 1
);
int bitmapRD[] = int[](
    4, 4, 4, 1,
    4, 4, 4, 1,
    4, 4, 1, 0,
    1, 1, 0, 0
);

void main() {
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;

    if (flatCorner != vec2(-1))
    {
        //Actual Pos
        vec2 APos1 = Pos1;
        vec2 APos2 = Pos2;
        APos1 = round(APos1 / (flatCorner.x == 0 ? 1 - Coords.z : 1 - Coords.w)); //Right-up corner
        APos2 = round(APos2 / (flatCorner.x == 0 ? Coords.w : Coords.z)); //Left-down corner

        ivec2 res = ivec2(abs(APos1 - APos2)) - 1; //Resolution of frame
        ivec2 stp = ivec2(min(APos1, APos2)); //Left-Up corner
        ivec2 pos = ivec2(floor(position)) - stp; //Position in frame

        vec4 col = colors[3];

        ivec2 corner = min(pos, res - pos);

        if (pos.x < 4 && pos.y < 4) {
            int bit = bitmapLU[(pos.y * 4) + pos.x];
            if (bit == 0) {
                discard;
            } else {
                col = colors[bit];
            }
        } else if(pos.x > res.x - 4 && pos.y < 4) {
            int bit = bitmapRU[(pos.y * 4) + pos.x - res.x + 3];
            if (bit == 0) {
                discard;
            } else {
                col = colors[bit];
            }
        } else if(pos.x < 4 && pos.y > res.y - 4) {
            int bit = bitmapLD[(pos.y - res.y + 3) * 4 + pos.x];
            if (bit == 0) {
                discard;
            } else {
                col = colors[bit];
            }
        } else if(pos.x > res.x - 4 && pos.y > res.y - 4) {
            int bit = bitmapRD[(pos.y - res.y + 3) * 4  + pos.x - res.x + 3];
            if (bit == 0) {
                discard;
            } else {
                col = colors[bit];
            }
        } else {
            if(corner.x == 0 || corner.y == 0) {
                col = colors[1];
            } else {
                if(pos.x < 3 || pos.y < 3) {
                    col = colors[2];
                } else if(pos.x > res.x - 3 || pos.y >  res.y - 3) {
                    col = colors[4];
                }
            }
        }
        
        if(res.x < 19 && res.y < 32) {
            col = colors[0];
        }

        fragColor = col;
    }
}
