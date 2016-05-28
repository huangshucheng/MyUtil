#include "TimeCounter.h"

TimeCounter::TimeCounter()
{

}

TimeCounter::~TimeCounter()
{

}

bool TimeCounter::init(){
	if (!Node::init())
	{
		return false;
	}

	m_isCounting = false;
	this->scheduleUpdate();

	return true;
}

void TimeCounter::update(float dt){
	if (m_isCounting == false)
	{
		return;
	}

	m_fTime += dt;

	if (m_fTime>= m_fCBTime)
	{
		m_func();
		m_isCounting = false;
	}
}
/*开始计时，指定回调时间和回调函数*/
void TimeCounter::start(float fCBTime, std::function<void()>func)
{
	m_fCBTime = fCBTime;
	m_fTime = 0;
	m_func = func;
	m_isCounting = true;
}