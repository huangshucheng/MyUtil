#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;		void main()
{
    																	gl_FragColor = texture2D(u_texture, v_texCoord) * v_fragmentColor;										gl_FragColor = gl_FragColor*vec4(.7,1.,1.2,1.)+vec4(.0,.0,.3,.0)*gl_FragColor.a;							}