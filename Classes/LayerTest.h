#include "cocos2d.h"
#include "Layer/PopLayer_1/Pop.h"
USING_NS_CC;

class LayerTest: public Pop
{
public:
	class IServers
	{
		//使用代理
		public:
			virtual void sureclick() = 0;
	};

public:

	virtual bool init(IServers*_delegate);
	static LayerTest* create(IServers*_delegate);
	void itemClicked(Ref* sender);

protected:
	void	addParallaxNode();	//视觉差效果
	IServers* m_pService;
};

