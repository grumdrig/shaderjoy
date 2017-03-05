// https://twitter.com/_baku89/status/835059135552991232?refsrc=email&s=11

const float PI = 3.1415926536;

float random(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 gradient(float t) {
    vec3 off = vec3(.0, .1, .2) * 10.464;
    return cos(t * 3. + off) / 2. + .5;
}

vec3 gradient(vec2 p) {
    return ( gradient(p.x) + gradient(p.y) ) / 2.;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv.x *= iResolution.x / iResolution.y;
    float r = length(uv - 0.5);

    // spheric uv
    vec2 suv = uv - .5;
    suv *= (pow(length(suv) * 4., 2.) + 1.);
    suv += .5;
    float blend = 1. - smoothstep(.34, .38, r);
    uv = mix(uv, suv, blend);
    //uv += random(uv) * .04 * floor(mod(iGlobalTime,2.));

    vec3 color = gradient(uv + vec2(iGlobalTime * .4, iGlobalTime * .5));
   	color = abs(uv.y - color);
    fragColor = vec4(color,1.0);
}
