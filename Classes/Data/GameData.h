#pragma  once

#include "json/rapidjson.h"
#include "json/document.h"
#include "json/writer.h"
#include "json/stringbuffer.h"

#include <iostream>
#include "cocos2d.h"

using namespace cocos2d;
using namespace std;

/*
json数据的处理
*/

class GameData
{
public:
	static GameData* getInstance();
	static bool purgeInstance();

	rapidjson::Document preparePrase();
	void praseFinish(rapidjson::Document &document);

	void copyFileToPath(std::string path);
	void praseJsonData();

private:
	GameData();
	~GameData();

public:

	 void setCurLevel(int _level);
	 int getCurLevel(){ return cur_level; }

	 void setCurScore(int _score);
	 int getCurSocre() { return cur_score; }

	 void setHistoryScore(int _socre);
	 int getHistoryScore(){ return history_score;}

	 void setDiamondNum(int _num);
	 int getDiamondNum(){ return diamond_num;}

	 void setBombNum(int _num);
	 int getBombNum(){ return bomb_num; }

	 void setPaintNum(int _num);
	 int getPaintNum(){ return paint_num; }

	 void setRanbowNum(int _num);
	 int getRanbowNum(){ return rainbow_num; }

	 void setOldScore(int _score);
	 int getOldScore(){ return old_score; }

	 int getTargetScore(int _curLevel);
	 int getRewordScore(int _leftStarNum);

	 int getNeedMoney(int _index);	//需要的钱
	 int getDiamBuy(int _index);	//买的钻石
	 int getDiamRewd(int _index);	//奖励的钻石

private:

	static GameData* _instance;

	std::vector< int > targetScoreList;
	std::vector< int > reWordScoreList;
	std::vector< int > needMoneyLst;
	std::vector< int > diamBuyList;
	std::vector< int > diamRewdList;

	int cur_level;		//当前关卡
	int cur_score;		//当前分数
	int history_score;	//历史最高分
	int diamond_num;	//钻石数量
	int bomb_num;		//炸弹数量
	int	paint_num;		//改单个星星颜色道具 数量
	int rainbow_num;	//全部改颜色道具 数量

	int target_score;	//当前关卡的目标分数

	int old_score;		//前一关卡的分数

private:
	string path;
};
