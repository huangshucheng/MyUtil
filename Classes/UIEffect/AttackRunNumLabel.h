#pragma once
#include "cocos2d.h"

USING_NS_CC;

/*
使用
runNumber_1 = AttackRunNumLabel::create("00",1.0f,32,TextHAlignment::LEFT);
runNumber_1->setAnchorPoint(Vec2(0, 0.5));
runNumber_1->setPosition(CommonFunction::getVisibleAchor(0, 1, Vec2(390, -85)));
addChild(runNumber_1);
-------
static int index = 0;
index += 10;
runNumber_1->setString(Value(index).asString());
*/

class AttackRunNumLabel : public Node
{
public:
	static AttackRunNumLabel* create(const std::string& str, float runTime = 1, float fontSize = 0, TextHAlignment alignment = TextHAlignment::LEFT, TextVAlignment vAlignment = TextVAlignment::CENTER, const Size& dimensions = Size::ZERO);
	
	bool initLabel(const std::string& str, float fontSize, TextHAlignment alignment, TextVAlignment vAlignment, const Size& dimensions);

	void setString(const std::string& newString);
	std::string getString();

	void setAnchorPoint(Vec2 anchor);
	void setColor(Color3B color);
protected:
private:
	void updateNum(float dt);

private:
	float m_runTime;
	Label* m_bmfort;
	std::string m_curText;
	std::string m_lastText;
	std::string m_origText;

	int m_lastNum;

	float m_deltaUpdate;
	float m_updateValue;
};