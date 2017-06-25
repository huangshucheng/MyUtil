#include "DrawLine.h"

DrawLine::DrawLine() :m_drawNode(nullptr){

}

DrawLine::~DrawLine()
{

}

bool DrawLine::init(Vec2 &from, Vec2 &to, const std::string &img)
{
	if (!Node::init()){
		return false;
	}
	//m_drawNode = DrawNode::create();
	//addChild(m_drawNode);
	addLine(from,to,img);


	return true;
}

DrawLine* DrawLine::create(Vec2 &from, Vec2 &to, const std::string &img)
{
	DrawLine *pRet = new(std::nothrow) DrawLine();
	if (pRet && pRet->init(from,to,img))
	{
		pRet->autorelease();
		return pRet;
	}
	else
	{
		delete pRet;
		pRet = nullptr;
		return nullptr;
	}
}

void DrawLine::addLine(Vec2 &from, Vec2 &to, const std::string &img)
{
	//线段
	/*
	if (!m_drawNode){
		return;
	}
	m_drawNode->drawSegment(from, to, 5, Color4F(0, 1, 0, 1));
	m_drawNode->drawSegment(from, to, 10, Color4F(0, 0, 1, 1));

	if (img.empty()){
		return;
	}
	*/
	float angle = getAngle(from,to);
	log("angle: %d", (int)angle);

	float pos_x = from.x + (to.x - from.x) / 2;
	float pos_y = from.y + (to.y - from.y) / 2;

	log("x: %f,y: %f",pos_x,pos_y);

	auto sp = Sprite::create(img);
	if (sp){
		sp->setPosition(Vec2(pos_x, pos_y));
		sp->setRotation(-angle);
		addChild(sp);
		m_LineVec.pushBack(sp);
	}
}

float DrawLine::getAngle(const Vec2& beginPoint, const Vec2& endPoint)
{
	float len_y = endPoint.y - beginPoint.y;
	float len_x = endPoint.x - beginPoint.x;

	//float tan_yx = abs(len_y) / abs(len_x);
	float tan_yx = len_y / len_x;
	float angle = 0;

	/*if (len_y >= 0 && len_x <= 0) {
		angle = atan(tan_yx) * 180 / M_PI - 90;
	}
	else if (len_y >= 0 && len_x >= 0) {
		angle = 90 - atan(tan_yx) * 180 / M_PI;
	}
	else if (len_y <= 0 && len_x <= 0) {
		angle = -atan(tan_yx) * 180 / M_PI - 90;
	}
	else if (len_y <= 0 && len_x >= 0) {
		angle = atan(tan_yx) * 180 / M_PI + 90;
	}*/
	angle = atan(tan_yx) * 180 / M_PI;
	return angle;
}

void DrawLine::cleanLine()
{
	for (auto &line :m_LineVec){
		if (line&& line->getParent()){
			line->removeFromParent();
			break;
		}
	}
}