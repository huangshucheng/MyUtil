#include "BaseLayer.h"
#include "Utils/CommonFunction.h"

bool BaseLayer::init()
{
	createBg();

	m_popNode = Node::create();
	this->addChild(m_popNode, 10);

	this->setPosition(CommonFunction::getVisibleAchor(Center, Vec2::ZERO));

	return Node::init();
}

void BaseLayer::onEnter()
{
	Node::onEnter();

	// 屏蔽触摸
	auto myListener = EventListenerTouchOneByOne::create();
	myListener->setSwallowTouches(true);

	myListener->onTouchBegan = CC_CALLBACK_2(BaseLayer::onTouchBegan, this);
	myListener->onTouchMoved = CC_CALLBACK_2(BaseLayer::onTouchMoved, this);
	myListener->onTouchEnded = CC_CALLBACK_2(BaseLayer::onTouchEnded, this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(myListener, this);
	_eventDispatcher->setPriority(myListener, -128);

	auto listenerkeyPad = EventListenerKeyboard::create();
	listenerkeyPad->onKeyReleased = CC_CALLBACK_2(BaseLayer::onKeyReleased, this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(listenerkeyPad, this);
}

void BaseLayer::onEnterTransitionDidFinish()
{

}

void BaseLayer::createBg()
{
	auto layercolor = LayerColor::create(Color4B::BLACK);
	layercolor->setOpacity(150);
	layercolor->ignoreAnchorPointForPosition(false);
	layercolor->setAnchorPoint(Vec2(0.5, 0.5));
	addChild(layercolor);
}

bool BaseLayer::onTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	return true;
}

void BaseLayer::onTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{

}

void BaseLayer::onTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{

}

void BaseLayer::close()
{
	this->retain();
	if (this->getParent())
	{
		removeFromParent();
	}
	this->autorelease();
}

void BaseLayer::onKeyReleased(EventKeyboard::KeyCode keycode, Event* event)
{
	if (event->getType() == Event::Type::KEYBOARD)
	{
		event->stopPropagation();
		{
			if (keycode == EventKeyboard::KeyCode::KEY_BACK)  //返回
			{
				close();
			}
		}
	}
}