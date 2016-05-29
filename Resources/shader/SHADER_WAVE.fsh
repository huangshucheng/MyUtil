#ifdef GL_ES
precision mediump float;
#endif

									varying vec4 v_fragmentColor;											
varying vec2 v_texCoord;											uniform sampler2D u_texture;											

void main()
{														vec3 waveParams = vec3(10., .8, .1);										vec2 tmp	= vec2(1., .5);											vec2 uv			=	v_texCoord;									float distance = distance(uv, tmp);										float time = mod(CC_Time[2], 1.2);										float diff = (distance - (time));										float powDiff = 1.0 - pow(abs(diff*waveParams.x), waveParams.y);						float diffTime = diff  * powDiff;										vec2 diffUV = normalize(uv - tmp);										diffUV	*=	diffTime;											diffUV	*=	smoothstep((time ) + waveParams.z, (time ) + waveParams.z-.01, distance);			diffUV	*=	smoothstep((time ) - waveParams.z, (time ) - waveParams.z+.01, distance);			vec2 texCoord = uv + diffUV;											vec4 original = texture2D(u_texture, texCoord);									gl_FragColor = original; 										}

