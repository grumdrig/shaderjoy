void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 d1 = fragCoord - iMouse.xy;
	vec2 d2 = fragCoord - iMouse.zw;
	d1 *= d1;
	d2 *= d2;
	fragColor = vec4(1. / min(d1.x, d1.y), 1. / min(d2.x, d2.y), 0, 1.);
}
