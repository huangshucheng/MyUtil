#ifdef GL_ES
precision mediump float;
#endif

varying 												vec4 v_fragmentColor;												
			varying vec2 v_texCoord;															
uniform sampler2D u_texture;															uniform vec2 resolution;												

			uniform vec4 Ewfez_o;													

			void main()
{
 																		vec2 uv = v_texCoord;																vec4 FinalColor = v_fragmentColor*texture2D(u_texture,v_texCoord);										gl_FragColor = FinalColor*(smoothstep(Ewfez_o.z,Ewfez_o.w,uv.y)+(1. - smoothstep(Ewfez_o.x,Ewfez_o.y,uv.y)));
			}
