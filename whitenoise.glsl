// Full color white noise
vec3 rand(vec3 v) { return
	fract(sin(vec3(dot(v ,vec3(12.9898,78.233,42.9512)),
				   dot(v ,vec3(93.3923,23.443,37.3922)),
	               dot(v ,vec3(38.4982,98.985,63.9832))))
			* vec3(43758.5453, 57324.0923, 26598.9834));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	fragColor = vec4(rand(vec3(fragCoord, iTime)),1.0);
}


