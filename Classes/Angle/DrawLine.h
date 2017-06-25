#pragma once
#include "cocos2d.h"
USING_NS_CC;

class DrawLine : public Node{

public:
	DrawLine();
	~DrawLine();

	bool init(Vec2 &from, Vec2 &to, const std::string &img);
	static DrawLine* create(Vec2 &from, Vec2 &to, const std::string &img);
	void addLine(Vec2 &from, Vec2 &to, const std::string &img);
	float getAngle(const Vec2& beginPoint, const Vec2& endPoint);
	void cleanLine();
private:
	DrawNode* m_drawNode;
	Vector <Sprite*> m_LineVec;
};