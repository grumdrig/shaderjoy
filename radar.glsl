void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 uv = (fragCoord - iResolution.xy/2.0) / iResolution.y;
	float r = mod(iTime * 0.25, 1.5);
	r = pow(r, 0.5);
	float d = r - length(uv);
	if (d < 0.0) d = 99999.9;
	float dd = min(abs(uv.x), abs(uv.y)) * 10.0;
	d = min(d, dd);
	fragColor = vec4(0,pow(1.0-d * 5.0, 3.0),0,1);
}