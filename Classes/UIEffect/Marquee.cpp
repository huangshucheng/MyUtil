
#include "Marquee.h"
bool Marquee::init()
{
	//设置模板
	auto stencil = Sprite::create();        ///--------
	//设置显示区域大小
	stencil->setTextureRect(_showRect);

	//设置跑马灯文字
	_label = Label::createWithSystemFont("", _font, _fontSize);///--------
	//设置锚点
	_label->setAnchorPoint(Vec2::ANCHOR_MIDDLE);

	_label->setAlignment(TextHAlignment::LEFT);//右

	//创建裁剪节点
	auto clippingNode = ClippingNode::create(stencil);//模版传进来
	//显示模板内的内容
	clippingNode->setInverted(false);
	//添加显示内容
	clippingNode->addChild(_label);//文字传进来addchild 是显示的内容	 底板   一般底板都是要显示的内容
	//加入到UI树
	addChild(clippingNode);
	stencil->setColor(Color3B::BLACK);
	addChild(stencil, -1);			//模板放在底层

	return true;
}

void Marquee::show(const std::string& text)
{
	_state = State::playing;    //playing状态

	_label->setString(text);

	float _labelX = _label->getContentSize().width+ _showRect.size.width / 2;

	_label->setPosition(Vec2(_labelX, 0));

	auto sequ = Sequence::create(

		//Show::create(),    //？？显示

		MoveBy::create(5.0f, Vec2(-(_label->getContentSize().width*2 + _showRect.size.width ), 0)),

		//Hide::create(),    //？？隐藏

		DelayTime::create(1.0f),

		CCCallFunc::create([&]()
	{
		if (_texts.size() == 0)    //
		{
			_state = State::idle;    //idel状态
		}
		else
		{
			show(_texts.front());    //从最前面开始显示

			_texts.pop();            //把栈顶删除
		}
	}), nullptr);


	_label->runAction(sequ);


}
void Marquee::addMessage(const std::string& text)
{
	if (text.empty())
	{
		return;
	}
	if (_state == State::idle)
	{
		show(text);         //显示文字
	}
	else
	{
		_texts.push(text);  //传入文字
	}
}
