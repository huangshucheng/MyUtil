﻿#include "AttackRunNumLabel.h"

AttackRunNumLabel* AttackRunNumLabel::create(const std::string& str, float runTime, float fontSize, TextHAlignment alignment, TextVAlignment vAlignment, const Size& dimensions)
{
	AttackRunNumLabel* pReturn = new AttackRunNumLabel();
	if (pReturn && pReturn->initLabel(str, fontSize, alignment, vAlignment, dimensions))
	{
		pReturn->m_runTime = runTime;
		pReturn->autorelease();

		return pReturn;
	}
	CC_SAFE_DELETE(pReturn);
	return nullptr;
}

bool AttackRunNumLabel::initLabel(const std::string& str, float fontSize, TextHAlignment alignment, TextVAlignment vAlignment, const Size& dimensions)
{
	//m_bmfort = Label::create(str, "Microsoft Yahei", fontSize, dimensions, alignment, vAlignment);
	m_bmfort = Label::createWithTTF(str, "fonts/Squareo.ttf", fontSize, dimensions, alignment, vAlignment);
	this->addChild(m_bmfort);

	m_lastText = str.c_str();
	m_lastNum = atoi(m_lastText.c_str());

	schedule(schedule_selector(AttackRunNumLabel::updateNum));

	return true;
}

void AttackRunNumLabel::setAnchorPoint(Vec2 anchor)
{
	m_bmfort->setAnchorPoint(anchor);
}

void AttackRunNumLabel::setColor(Color3B color)
{
	m_bmfort->setColor(color);
}

std::string AttackRunNumLabel::getString()
{
	return m_lastText;
}

void AttackRunNumLabel::setString(const std::string& newString)
{
	m_lastText = newString;
	m_lastNum = atoi(m_lastText.c_str());
	m_origText = m_bmfort->getString();
	//m_deltaUpdate = m_runTime / ;
	m_updateValue = 0;
	
}

void AttackRunNumLabel::updateNum(float dt)
{
	m_curText = m_bmfort->getString();
	int curNum = atoi(m_curText.c_str());

	if (m_lastNum > curNum)
	{
		m_updateValue += dt / m_runTime * (float)(atoi(m_lastText.c_str()) - atoi(m_origText.c_str()));

		if (m_updateValue >= 1)
		{
			curNum += (int)m_updateValue;
			m_updateValue -= (int)m_updateValue;
		}
		
		char _num[20];
		sprintf(_num, "%d", curNum);
		m_bmfort->setString(std::string(_num));
	}
	else if (m_lastNum == curNum)
	{
		//this->unscheduleAllSelectors();
		return;
	}
	else
	{
		char _num[20];
		sprintf(_num, "%d", m_lastNum);
		m_bmfort->setString(std::string(_num));
	}
}

 