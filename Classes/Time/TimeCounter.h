#pragma once

#include "cocos2d.h"
USING_NS_CC;
using namespace std;
/*
计时器
*/
class TimeCounter:public Node
{

public:
	CREATE_FUNC(TimeCounter);

	virtual bool init();

	virtual void update(float dt);

	/*开始计时，指定回调时间和回调函数*/
	void start(float fCBTime,std::function<void()>func);

public:
	TimeCounter();
	~TimeCounter();

private:
	float m_fTime;					/*用于计时*/
	float m_fCBTime;				/*回调时间*/
	bool m_isCounting;				/*标记是否正在计时*/
	std::function<void()> m_func;	/*回调函数*/

};

