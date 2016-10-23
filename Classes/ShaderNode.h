#pragma once

#include "cocos2d.h"
USING_NS_CC;

class ShaderNode : public Node
{
public:
	ShaderNode();
	bool initWithVertex(const char *vert, const char *frag);
	void loadShaderVertex(const char *vert, const char *frag);
	virtual void update(float delta);
	virtual void setContentSize(const CCSize& var);
	virtual void setColor(ccColor4F newColor);
	virtual void draw();
	static ShaderNode* shaderNodeWithVertex(const char *vert,const char *frag);

private:
	GLuint      m_uniformResolution, m_uniformTime, m_uniformTex0;
	GLuint      m_attributeColor, m_attributePosition;
	float       m_time;
	ccVertex2F  m_resolution, m_center;
	GLuint      m_texture;
	GLfloat     color[4];
};