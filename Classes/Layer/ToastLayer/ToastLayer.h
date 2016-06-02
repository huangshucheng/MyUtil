#pragma once

#include "cocos2d.h"
#include "ui/CocosGUI.h"

using namespace cocos2d::ui;
USING_NS_CC;

#define MOVE_LENGTH 50 //�ƶ�����

class ToastLayer:public Layer
{
public:
	static  ToastLayer* create();

	ToastLayer();
	~ToastLayer();
	void addLayer(std::string str);//��Ӳ�
	void  moveNode();//�ƶ��ڵ�


	void OnInit();//��ʼ��
	
	void deleteNode(Node * node);//ɾ���ڵ�

public:

	std::vector<Node *> m_node;//��ڵ�
};

class  Toast:public Layer
{
public:
	static  Toast* create(std::string str, ToastLayer * toastLayer);
	void OnInit();
	void  nodeDeleteAction();
	void  removeThis();

	ToastLayer * m_toastLayer;
	std::string m_showString;
};