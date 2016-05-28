#pragma once

#include <iostream>

using namespace std;
#include "cocos2d.h"

//文字状态机
using namespace cocos2d;

class Marquee :public Node 
{
public:
	enum class State
	{
		idle,
		playing
	};

public:
	CREATE_FUNC(Marquee);
	bool init();
	void addMessage(const std::string& text);

public:
	const std::string& getFont() const { return _font; }
	void setFont(std::string& font) { _font = font; }
	float getFontSize() const { return _fontSize; }
	void setFontSize(float fontSize) { _fontSize = fontSize; }

public:
	const Rect& getShowRect() const { return _showRect; }
	void setShowRect(Rect& showRect) { _showRect = showRect; }

public:
	const State& getState() const { return _state; }

protected:
	Marquee() :      //默认构造函数 初始化列表
		_font(""),
		_fontSize(24),
		_showRect(Rect(0, 0, 500, 30)),
		_state(State::idle)
	{};
	~Marquee() {};
	void show(const std::string& text);

private:
	State _state;

private:
	std::string _font;
	float _fontSize;
	Rect _showRect;

private:
	Label * _label;

private:
	std::queue<std::string> _texts;
};


