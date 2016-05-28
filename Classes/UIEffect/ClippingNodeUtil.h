#pragma once
#include "cocos2d.h"
#include "ui\CocosGUI.h"
#include "Marquee.h"
USING_NS_CC;
using namespace ui;

//ClippingNode测试专用
class ClippingNodeTest :public LayerColor
{
public:
	CREATE_FUNC(ClippingNodeTest);
	virtual bool init();
public:

	void test();
	void myUpdate(float dt);
	void update(float dt);

	void setup();
private:
	Sprite* spark;
	Size clipSize;
	Marquee* m;

private:
	ClippingNode* _outerClipper;
	Node* _holes;
	Node* _holesStencil;
	void pokeHoleAtPoint(Vec2 point);
};
