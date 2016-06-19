#include "LayerTest.h"
#include "Utils/CommonFunction.h"

bool LayerTest::init()
{
	if (!Pop::init())
	{
		return false;
	}

	/*auto sp = Sprite::create("supercell.png");
	sp->setScale(0.7f);
	sp->setTag(99);
	m_popNode->addChild(sp);*/

	//addParallaxNode();
	return true;
}

void	LayerTest::addParallaxNode()
{
	Sprite* spFont = Sprite::create("front.png");
	Sprite* spMiddle = Sprite::create("middle.png");
	Sprite* spFar = Sprite::create("far.png");

	ParallaxNode * parallaxNode = ParallaxNode::create();
	m_popNode->addChild(parallaxNode);

	//近景
	parallaxNode->addChild(spFont, 3, Vec2(4.8f, 0), Vec2(spFont->getContentSize().width*0.5, spFont->getContentSize().height*0.5));
	//中景
	parallaxNode->addChild(spMiddle,2, Vec2(1.6f, 0), Vec2(spMiddle->getContentSize().width*0.5, spMiddle->getContentSize().height*0.5 + spFont->getContentSize().height*0.5));
	//远景
	parallaxNode->addChild(spFar, 1, Vec2(0.5f, 0), Vec2(spFar->getContentSize().width*0.5, spFar->getContentSize().height*0.5 + spFont->getContentSize().height*0.5 + spMiddle->getContentSize().height*0.5));

	ActionInterval* go = MoveBy::create(8, Vec2(-200, 0));
	ActionInterval* goBack = go->reverse();
	FiniteTimeAction* seq = Sequence::create(go, goBack, NULL);
	parallaxNode->runAction((RepeatForever::create((ActionInterval*)seq)));
}