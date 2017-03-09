// Sky from http://www.gamasutra.com/blogs/ConorDickinson/20130925/200990/
// However, earth-like parameters are baked in rather than calculated.
// You can look left & right using the mouse.
//
// Starfield is based on https://www.shadertoy.com/view/MtB3zW

const float DAY = 30.; // seconds per day
const float PI = 3.1415926585;

vec3 calcExtinction(float dist) {
	return exp(dist * vec3(-4.522079564139858e-7, -9.250694574802765e-7, -0.0000018804023511620471));
}

vec3 calcScattering(float cos_theta) {
	float r_phase = (cos_theta * cos_theta + 1.) * 0.1790493130683899;
	float m_phase = 0.000232047910685651 * pow(-1.8919999599456787 * cos_theta + 1.89491605758667, -1.5);
	return vec3(0.6477129459381104, 0.7398291826248169, 0.8121863603591919) * r_phase +
	       vec3(0.3522870540618896, 0.2601708173751831, 0.1878136247396469) * m_phase;
}

float baseOpticalDepth(in vec3 ray) {
	float a1 = 6371000.0 * ray.y;
	return sqrt(a1 * a1 + 1284199940096.0) - a1;
}

float opticalDepth(in vec3 pos, in vec3 ray) {
	pos.y += 6371000.0;
	float a0 = 41873842372608.0 - dot(pos, pos);
	float a1 = dot(pos, ray);
	return sqrt(a1 * a1 + a0) - a1;
}

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 rand2(vec2 p) {
    p = vec2(dot(p, vec2(12.9898,78.233)),
    	     dot(p, vec2(26.65125, 83.054543)));
    return fract(sin(p) * 43758.5453);
}

float stars(in vec2 x, float numCells, float size, float br) {
    vec2 n = x * numCells;
    vec2 f = floor(n);

	float d = 1.0e10;
    for (int i = -1; i <= 1; ++i) {
        for (int j = -1; j <= 1; ++j) {
            vec2 g = f + vec2(float(i), float(j));
			g = n - g - rand2(mod(g, numCells)) + rand(g);
            // Control size
            g *= 1. / (numCells * size);
			d = min(d, dot(g, g));
        }
    }

    return br * (smoothstep(.95, 1., (1. - sqrt(d))));
}

vec3 skyColor(in vec3 rd) {
    float t = (sin(iGlobalTime)) * PI / 2.;
    vec3 sunDirection =vec3(0, sin(t), cos(t));

	float cos_theta = dot(rd, sunDirection);

	// optical depth along view ray
	float ray_dist = baseOpticalDepth(rd);

	// extinction of light along view ray
	vec3 extinction = calcExtinction(ray_dist);

	// optical depth for incoming light hitting the view ray
	vec3 light_ray_pos = rd * (ray_dist * (0.15 + 0.75 * sunDirection.y));
	float light_ray_dist = opticalDepth(light_ray_pos, sunDirection);

	// optical depth for edge of atmosphere:
	// this handles the case where the sun is low in the sky and
	// the view is facing away from the sun; in this case the distance
	// the light needs to travel is much greater
	float light_ray_dist_full = opticalDepth(rd * ray_dist, sunDirection);

	light_ray_dist = max(light_ray_dist, light_ray_dist_full);

	// cast a ray towards the sun and calculate the incoming extincted light
	vec3 incoming_light = calcExtinction(light_ray_dist);

	// calculate the in-scattering
	vec3 scattering = calcScattering(cos_theta);
	scattering *= 1.0 - extinction;

	// combine
	vec3 in_scatter = incoming_light * scattering;

	// sun disk
	float sun_strength = clamp(cos_theta * 666.6619873046875 - 665.6619873046875, 0.0, 1.0);
	sun_strength *= sun_strength;
	vec3 sun_disk = extinction * sun_strength;

	vec3 result = vec3(5.839504241943359) * (0.5 * sun_disk + in_scatter);

	return result;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 p = (2.*fragCoord - iResolution.xy) / iResolution.y;
    p.y += 0.7;  // Show just a bit of the horizon

    vec2 coord = 2. * fragCoord.xy / iResolution.xy - 1.;  // on [-1, 1];
    float up = PI * coord.y / 2.;
    vec3 fisheye = vec3(cos(up) * sin(coord.x * PI), sin(up), cos(up) * cos(coord.x * PI));
    vec3 rd = normalize(coord.x < 0. ? vec3(coord, 1.) : fisheye);

/*
    // Adjust view with mouse
    float mouse = 0.;
    // Mouse look commented out because the default mouse value can be somewhere weird
    // mouse = (2.*iMouse.x  - iResolution.x) / iResolution.y;
	mouse -= .3;  // Angle towards the sunrise
	float cm = cos(mouse), sm = sin(mouse);
    rd = vec3(cm * rd.x - sm * rd.z, rd.y, sm * rd.x + cm * rd.z);
    */

    fragColor.rgb = skyColor(rd);
    fragColor.rgb += vec3(0,1,0) * 1./pow(p.y * 200., 2.);  // horizon line
	fragColor.a = 1.;
}