#pragma once

#include "cocos2d.h"
USING_NS_CC;

class BaseLayer : public Node
{
public:
	virtual bool init();
	virtual void onEnter();
	virtual void close();
	virtual void onEnterTransitionDidFinish();

public:
	virtual void createBg();

protected:
	virtual void onKeyReleased(EventKeyboard::KeyCode keycode, Event* event);
	virtual bool onTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual	void onTouchMoved(Touch *pTouch, Event  *pEvent);
	virtual void onTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	Node* m_popNode;
};