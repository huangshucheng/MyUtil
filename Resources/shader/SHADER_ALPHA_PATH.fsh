#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;

	void main()
{																vec4 irgb = texture2D(u_texture,v_texCoord)*v_fragmentColor;									gl_FragColor = vec4(irgb.rgb,irgb.a*sign(irgb.r+irgb.g+irgb.b-0.1));}

