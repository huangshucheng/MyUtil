#pragma once

#include "cocos2d.h"
#include "ToastLayer.h"

USING_NS_CC;

#define TOAST_LAYER_TAG 100001
/*
��ʾ�㣬С����ʾ��
*/

class ToastManger
{
public:
	static ToastManger* getInstance();
	void createToast(std::string str);

private:
	void createToast(std::string str, Node * sceneNode);
	ToastManger();
	~ToastManger();

private:
	void creatToastLayer();
	
private:
	Node        *  m_scene;//����
	ToastLayer  *  m_ToastLayer;//Toast��
};