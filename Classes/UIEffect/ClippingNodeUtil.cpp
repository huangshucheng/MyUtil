#include"ClippingNodeUtil.h"

#define visibleSize Director::getInstance()->getVisibleSize()

bool ClippingNodeTest::init(){
	LayerColor::initWithColor(Color4B::BLACK);
	test();

	//schedule(schedule_selector(ClippingNodeTest::myUpdate), 2.0f);
	//scheduleUpdate();

	// m = Marquee::create();
	//m->setPosition(Vec2(550, 600));
	//this->addChild(m);

	//setup();
	return true;
}

void ClippingNodeTest::update(float dt)
{
	m->addMessage("helloworld");
	m->addMessage("wochaoyuewoahdjkfdjkfhjksinia");
	m->addMessage("haldjfklasjdlkfjkasdjfashdfaskldjflk;aj");
}

void ClippingNodeTest::test()
{
	Sprite* bg = Sprite::create("login_bg.png");//背景
	bg->setPosition(visibleSize / 2);
	addChild(bg);

	Sprite* gameTitle = Sprite::create("10001.png");	//文字标题（模板）
	clipSize = gameTitle->getContentSize();

	spark = Sprite::create("spark.png");			//光效（底板）
	spark->setRotation(30);
	spark->setScale(2);
	spark->setPosition(-clipSize.width, 0);

	ClippingNode* clip = ClippingNode::create();
	clip->setInverted(false);
	clip->setAlphaThreshold(0);				//设置底板的alpha为0
	clip->setContentSize(clipSize);
	clip->setPosition(Vec2(visibleSize.width / 2, visibleSize.height / 2));
	this->addChild(clip);

	clip->setStencil(gameTitle);			//设置模版
	clip->addChild(gameTitle, 1);
	clip->addChild(spark, 2);				//设置底板

	auto moveAction = MoveTo::create(2.5f, Vec2(clipSize.width, 0));
	auto callbackFunc = [=](){
		//log("judge positioon");
		if (spark->getPositionX() >= clipSize.width)
		{
			spark->setPosition(-clipSize.width, 0);
			//log("spark moveback");
		}
	};
	auto dely = DelayTime::create(0.5f);

	CallFunc* callFunc = CallFunc::create(callbackFunc);

	Sequence* seq = Sequence::create(callFunc, dely, moveAction, NULL);
	RepeatForever* repeatAction = RepeatForever::create(seq);
	spark->runAction(repeatAction);

	//MoveTo* moveBackAction = MoveTo::create(1.0f, Vec2(-clipSize.width, 0));
	//Sequence* seq = Sequence::create(moveAction, moveBackAction, NULL);
	//RepeatForever* repeatAction = RepeatForever::create(seq);
	//spark->runAction(repeatAction);
}

void ClippingNodeTest::myUpdate(float dt)
{
	if (spark->getPositionX() >= clipSize.width)
	{
		spark->setPosition(-clipSize.width, 0);
	}
	auto moveAction = MoveTo::create(1.5f, Vec2(clipSize.width, 0));
	spark->runAction(moveAction);
}

void ClippingNodeTest::setup()
{

	auto target = Sprite::create("res/blocks.png");	//模板大图
	target->setAnchorPoint(Vec2::ZERO);
	target->setScale(2);

	_outerClipper = ClippingNode::create();		//第一个节点
	_outerClipper->retain();
	AffineTransform tranform = AffineTransform::IDENTITY;
	tranform = AffineTransformScale(tranform, target->getScale(), target->getScale());

	_outerClipper->setContentSize(SizeApplyAffineTransform(target->getContentSize(), tranform));
	_outerClipper->setAnchorPoint(Vec2(0.5, 0.5));
	_outerClipper->setPosition(Vec2(visibleSize.width / 2 + 250, visibleSize.height / 2));
	_outerClipper->runAction(RepeatForever::create(RotateBy::create(1, 45)));

	_outerClipper->setStencil(target);	//设置模板

	auto holesClipper = ClippingNode::create();	//第二个节点
	holesClipper->setInverted(true);
	holesClipper->setAlphaThreshold(0.05f);

	holesClipper->addChild(target);

	_holes = Node::create();
	_holes->retain();

	holesClipper->addChild(_holes);

	_holesStencil = Node::create();
	_holesStencil->retain();

	holesClipper->setStencil(_holesStencil);

	_outerClipper->addChild(holesClipper);

	this->addChild(_outerClipper);

	auto listener = EventListenerTouchOneByOne::create();
	listener->onTouchBegan = [&](Touch*touch, Event*){
		Vec2 point = _outerClipper->convertToNodeSpace(Director::getInstance()->convertToGL(touch->getLocationInView()));
		auto rect = Rect(0, 0, _outerClipper->getContentSize().width, _outerClipper->getContentSize().height);
		if (!rect.containsPoint(point)) return false;
		this->pokeHoleAtPoint(point);
		log("fuck");
		return true;
	};
	_eventDispatcher->addEventListenerWithSceneGraphPriority(listener, this);
}

void ClippingNodeTest::pokeHoleAtPoint(Vec2 point){
	float scale = CCRANDOM_0_1() * 0.2 + 0.9;
	float rotation = CCRANDOM_0_1() * 360;

	auto hole = Sprite::create("res/hole_effect.png");
	hole->setPosition(point);
	hole->setRotation(rotation);
	hole->setScale(scale);

	_holes->addChild(hole);

	auto holeStencil = Sprite::create("res/hole_stencil.png");
	holeStencil->setPosition(point);
	holeStencil->setRotation(rotation);
	holeStencil->setScale(scale);

	_holesStencil->addChild(holeStencil);

	_outerClipper->runAction(Sequence::createWithTwoActions(ScaleBy::create(0.05f, 0.95f),
		ScaleTo::create(0.125f, 1)));
}