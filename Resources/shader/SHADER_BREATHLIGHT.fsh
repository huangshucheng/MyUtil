#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;

	void main()
{																float iGlobalTime	=	CC_Time[2]*1.;											vec4 irgb = texture2D(u_texture,v_texCoord)*v_fragmentColor;																				irgb.rgb	*=	((1.-sin(iGlobalTime))*.1+.6);										gl_FragColor = irgb;													}

