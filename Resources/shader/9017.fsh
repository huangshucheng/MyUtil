#ifdef GL_ES
precision mediump float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
float iGlobalTime = CC_Time[1]*2.5;
float distToLineSquare(vec2 p)
{
	p -= vec2(0.05,0.51);
	vec2 lineVector = vec2(-0.76,-0.475);
	float dx = 0.0;
	if(p.x<0.0)
		dx = abs(p.x);
	else if(p.x>length(lineVector))
		dx = abs(p.x) - length(lineVector);		
	return 0.01/(dx+abs(p.y));
}
void main()
{
	vec2 p = v_texCoord;	
	float dist = distToLineSquare(p);	
	dist = pow(dist,3.);	
	vec3 finalColor = vec3(2.5, 0.1, 2.5)*(sin(iGlobalTime)+1.);
	gl_FragColor = vec4(dist*finalColor,0.0);
}
