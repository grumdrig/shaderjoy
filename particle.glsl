// Define this magic value to set the number of points that get rendered
#define iNumPoints 100

void mainParticle(out vec2 pointPosition, out float pointSize, in int pointIndex) {
	float a = 0.2 * float(pointIndex) + iTime;
	pointPosition = vec2(cos(a), sin(a * 1.618));
	// pointPosition.x *= iResolution.y / iResolution.x;
	pointPosition *= 0.8;
	pointSize = 25.0;// * float(pointIndex) / float(iNumPoints);
}

void mainImage(out vec4 fragColor, in vec2 pointCoord, in int pointIndex) {
	pointCoord = pointCoord * 2.0 - 1.0;
	pointCoord *= 1.1; // point coordinates don't cover the whole range (in firefox at least)
	float d = length(pointCoord);
	//d = 0.0;
	float t = float(pointIndex)/float(iNumPoints);
	fragColor = vec4(2.0 - abs(mod(6.0 * t + 4.0, 6.0) - 3.0),
					 2.0 - abs(mod(6.0 * t + 0.0, 6.0) - 3.0),
					 2.0 - abs(mod(6.0 * t + 2.0, 6.0) - 3.0),
	                 d < 1.0 ? 0.8 : 0.0);
}
