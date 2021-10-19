#define iNumPoints 50

void mainParticle(out vec2 pointPosition, out float pointSize, in int pointIndex) {
	float a = 2.0 * 3.141 * float(pointIndex) / float(iNumPoints) + iTime;
	pointPosition = vec2(cos(a), sin(a));
	pointPosition.x *= iResolution.y / iResolution.x;
	pointPosition *= 0.8;
	pointSize = 25.0;// * float(pointIndex) / float(iNumPoints);
}

void mainImage(out vec4 fragColor, in vec2 pointCoord, in int pointIndex) {
	pointCoord = pointCoord * 2.0 - 1.0;
	pointCoord *= 1.1; // point coordinates don't cover the whole range (in firefox at least)
	float d = length(pointCoord);
	//d = 0.0;
	fragColor = vec4(float(pointIndex)/float(iNumPoints), 0, 0, d < 1.0 ? 1.0 : 0.0);
}
