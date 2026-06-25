// SMPTE color bars test card
// This was Claude's work

void mainImage(out vec4 o, in vec2 fc) {
    vec2 uv = fc / iResolution.xy;
    vec3 c;

    // Top 2/3: main color bars
    // White, Yellow, Cyan, Green, Magenta, Red, Blue
    vec3 bars[7] = vec3[7](
        vec3(.75), vec3(.75,.75,0), vec3(0,.75,.75), vec3(0,.75,0),
        vec3(.75,0,.75), vec3(.75,0,0), vec3(0,0,.75)
    );
    int col = int(uv.x * 7.0);

    if (uv.y > 0.33) {
        // Top 2/3
        c = bars[col];
    } else if (uv.y > 0.25) {
        // Thin reverse bar strip
        vec3 rev[7] = vec3[7](
            vec3(0,0,.75), vec3(0,0,0), vec3(.75,0,.75), vec3(0,0,0),
            vec3(0,.75,.75), vec3(0,0,0), vec3(.75)
        );
        c = rev[col];
    } else {
        // Bottom PLUGE area
        float x = uv.x;
        if (x < 1.0/6.0) {
            c = vec3(-7.0/60.0, 0.15, 0.35);  // -I (dark blue-purple)
            c = vec3(0.0, 0.07, 0.21);
        } else if (x < 2.0/6.0) {
            c = vec3(.75);  // white
        } else if (x < 3.0/6.0) {
            c = vec3(0.27, 0.0, 0.40);  // +Q (purple)
        } else if (x < 4.0/6.0) {
            c = vec3(0);  // black
        } else {
            // PLUGE: sub-black, black, super-black
            float px = (x - 4.0/6.0) * 6.0;  // 0-2 range
            if (px < 0.5) c = vec3(0.035);       // 3.5% slightly below black
            else if (px < 1.0) c = vec3(0.074);  // 7.5% reference black
            else if (px < 1.5) c = vec3(0.035);  // 3.5%
            else c = vec3(0);                     // true black
        }
    }

    o = vec4(c, 1.0);
}
