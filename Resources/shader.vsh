attribute vec4 a_color;  
attribute vec4 a_position;  
varying vec4 v_color;  
 
void main()  
{  
    v_color = a_color;  
    gl_Position = CC_MVPMatrix * a_position;  
}