#include "GameData.h"

GameData* GameData::_instance = nullptr;

GameData::GameData():
cur_level(0),
cur_score(0),
target_score(0),
history_score(0),
diamond_num(0),
bomb_num(0),
paint_num(0),
rainbow_num(0),
old_score(0)
{

}

GameData::~GameData()
{
	targetScoreList.clear();
	reWordScoreList.clear();
	needMoneyLst.clear();
	diamBuyList.clear();
	diamRewdList.clear();
}

GameData* GameData::getInstance()
{
	if (!_instance)
	{
		_instance = new GameData();
	}
	return _instance;
}

bool GameData::purgeInstance()
{
	CCASSERT(_instance, "instance can not emptoy");
	if (_instance)
	{
		delete _instance;
		_instance = nullptr;
	}
	return true;
}

rapidjson::Document GameData::preparePrase()
{
	FileUtils *fu = FileUtils::getInstance();
	path = fu->getWritablePath();
	string filename = "chapter.json";
	path += filename;
	this->copyFileToPath(filename);

	rapidjson::Document doc;
	std::string data = fu->getStringFromFile(path);
	std::string clearData(data);
	size_t pos = clearData.rfind("}");
	clearData = clearData.substr(0, pos + 1);

	doc.Parse<4>(clearData.c_str());

	if (doc.HasParseError()) {
		log("GetParaseErro %s\n", doc.GetParseError());
		return NULL;
	}

	return doc;
}

void GameData::praseFinish(rapidjson::Document &document)
{
	////修改json内容之后重新写入
	rapidjson::StringBuffer buffer;			//初始化缓冲区
	rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);//初始化写入器
	document.Accept(writer);					//将doc里面的内容放到writer里面的buffer

	FILE* file = fopen(path.c_str(), "wb");//二进制写入
	if (file)
	{
		fputs(buffer.GetString(), file);
		fclose(file);
		cout << "解析完成" << endl;
	}
}

void GameData::praseJsonData()
{
	auto doc = preparePrase();

	targetScoreList.clear();
	reWordScoreList.clear();
	needMoneyLst.clear();
	diamBuyList.clear();
	diamRewdList.clear();

	rapidjson::Value &json_array = doc["Tollgate"];

	for (unsigned int i = 0; i < json_array.Size(); i++)
	{
		rapidjson::Value & first = json_array[i];			//第一个字典
		rapidjson::Value & chapter = first["chapter"];	//第一个字典的第一个键
		//获取数据
		rapidjson::Value & historyScore = chapter["historyScore"];
		rapidjson::Value & currScore = chapter["currScore"];
		rapidjson::Value & level = chapter["level"];
		rapidjson::Value & diamondNum = chapter["diamondNum"];
		rapidjson::Value & bombNum = chapter["bombNum"];
		rapidjson::Value & paintNum = chapter["paintNum"];
		rapidjson::Value & rainbowNum = chapter["rainbowNum"];
		//获取数组
		rapidjson::Value & targetScore = chapter["targetScore"];
		rapidjson::Value & rewordScore = chapter["rewordScore"];
		rapidjson::Value & money = chapter["money"];
		rapidjson::Value & diamBuy = chapter["diam_buy"];
		rapidjson::Value & diamrewd = chapter["diam_rewd"];
		rapidjson::Value & oldScore = chapter["oldScore"];

		for (unsigned int j = 0; j<targetScore.Size(); j++)
		{
			rapidjson::Value &value = targetScore[j];
			targetScoreList.push_back(value.GetInt());
		}
		for (unsigned int k = 0; k < rewordScore.Size();k++)
		{
			rapidjson::Value &value = rewordScore[k];
			reWordScoreList.push_back(value.GetInt());
		}

		for (unsigned int i = 0; i < money.Size(); i++)
		{
			rapidjson::Value &value = money[i];
			needMoneyLst.push_back(value.GetInt());
		}
		for (unsigned int i = 0; i < diamBuy.Size(); i++)
		{
			rapidjson::Value &value = diamBuy[i];
			diamBuyList.push_back(value.GetInt());
		}
		for (unsigned int i = 0; i < diamrewd.Size(); i++)
		{
			rapidjson::Value &value = diamrewd[i];
			diamRewdList.push_back(value.GetInt());
		}

		cur_level = level.GetInt();
		history_score = historyScore.GetInt();
		cur_score = currScore.GetInt();
		diamond_num = diamondNum.GetInt();
		bomb_num = bombNum.GetInt();
		paint_num = paintNum.GetInt();
		rainbow_num = rainbowNum.GetInt();
		old_score = oldScore.GetInt();

		cout << "---------------------------" << endl;
		printf("level==%d\n", level.GetInt());
		printf("historyScore==%d\n", historyScore.GetInt());
		printf("diamondNum==%d\n", diamondNum.GetInt());
		printf("bombNum==%d\n", bombNum.GetInt());
		printf("paintNum==%d\n", paintNum.GetInt());
		printf("rainbowNum==%d\n", rainbowNum.GetInt());
		cout << "---------------------------" << endl;

	}
	praseFinish(doc);
}

void GameData::copyFileToPath(std::string path){
	//获取文件复制的原路径和目录路径
	FileUtils *fu = FileUtils::getInstance();
	std::string wrpath = fu->getWritablePath();
	wrpath += path;
	log("%s", wrpath.c_str());
	if (!fu->isFileExist(wrpath)) {
		//获取app里面的路径
		std::string datapath = fu->fullPathForFilename(path.c_str());
		log("datapath=%s", datapath.c_str());
		//根据这个路径来获取到文件
		std::string pFileContent = fu->getStringFromFile(datapath);
		CCLOG("%s", pFileContent.c_str());
		//将文件内容读出，写入到沙盒中
		FILE *file = fopen(wrpath.c_str(), "w");
		if (file) {
			fputs(pFileContent.c_str(), file);
			fclose(file);
		}
	}

}

int GameData::getTargetScore(int _curLevel)
{
	if (_curLevel <= 0)
	{
		return 0;
	}
	
	for (int i = 0; i < targetScoreList.size();i++)
	{
		if (_curLevel == i + 1)
		{
			//cout << "第" << _curLevel << "关的目标分数:" << targetScoreList.at(i) << endl;
			return targetScoreList.at(i);
			break;
		}
	}
	return 0;
}

int GameData::getRewordScore(int _leftStarNum)
{
	if (_leftStarNum<0)
	{
		return 0;
	}

	for (int i = 0; i < reWordScoreList.size();i++)
		{
			if (_leftStarNum == i)
			{
				//cout << "剩余个数：" << _leftStarNum << "奖励分数:" << reWordScoreList.at(i) << endl;

				return reWordScoreList.at(i);
				break;
			}
		}
	return 0;
}
//需要的钱
int GameData::getNeedMoney(int _index)
{
	if (_index<0)
	{
		return 0;
	}
	for (int i = 0; i < needMoneyLst.size(); i++)
	{
		if (_index == i)
		{
			return needMoneyLst.at(i);
			break;
		}
	}

	return 0;
}
//买的钻石
int GameData::getDiamBuy(int _index)
{
	if (_index<0)
	{
		return 0;
	}
	for (int i = 0; i < diamBuyList.size(); i++)
	{
		if (_index == i)
		{
			return diamBuyList.at(i);
			break;
		}
	}
	return 0;
}
//奖励的钻石
int GameData::getDiamRewd(int _index)
{
	if (_index<0)
	{
		return 0;
	}
	for (int i = 0; i < diamRewdList.size(); i++)
	{
		if (_index == i)
		{
			return diamRewdList.at(i);
			break;
		}
	}
	return 0;
}

void GameData::setCurLevel(int level)
{
	auto doc = preparePrase();
	cur_level = level;
	
	rapidjson::Value &json_array = doc["Tollgate"];

	for (unsigned int i = 0; i < json_array.Size(); i++)
	{
		rapidjson::Value & first = json_array[i];
		rapidjson::Value & chapter = first["chapter"];
		rapidjson::Value & level = chapter["level"];
		level.SetInt(cur_level);
	}
	praseFinish(doc);
	//cout << "设置当前等级:" << cur_level << endl;
}

void GameData::setCurScore(int _score)
{
	auto doc = preparePrase();
	cur_score = _score;

	rapidjson::Value &json_array = doc["Tollgate"];
	for (unsigned int i = 0; i < json_array.Size(); i++)
	{
		rapidjson::Value & first = json_array[i];
		rapidjson::Value & chapter = first["chapter"];

		rapidjson::Value & curScore = chapter["currScore"];
		curScore.SetInt(cur_score);
	}
	praseFinish(doc);
	//cout << "设置当前分数:" << cur_score << endl;
}

void GameData::setHistoryScore(int _socre)
{
	auto doc = preparePrase();
	history_score = _socre;

	rapidjson::Value &json_array = doc["Tollgate"];
	for (unsigned int i = 0; i < json_array.Size(); i++)
	{
		rapidjson::Value & first = json_array[i];
		rapidjson::Value & chapter = first["chapter"];

		rapidjson::Value & historyScore = chapter["historyScore"];
		historyScore.SetInt(history_score);
	}
	praseFinish(doc);
	//cout << "设置当前最高分:" << history_score << endl;
}

void GameData::setDiamondNum(int _num)
{
	auto doc = preparePrase();
	diamond_num = _num;

	rapidjson::Value &json_array = doc["Tollgate"];
	for (unsigned int i = 0; i < json_array.Size(); i++)
	{
		rapidjson::Value & first = json_array[i];
		rapidjson::Value & chapter = first["chapter"];

		rapidjson::Value & diamondNum = chapter["diamondNum"];
		diamondNum.SetInt(diamond_num);
	}
	praseFinish(doc);
	//cout << "设置钻石数量:" << diamond_num << endl;
}

void GameData::setBombNum(int _num)
{
	auto doc = preparePrase();
	bomb_num = _num;

	rapidjson::Value &json_array = doc["Tollgate"];
	for (unsigned int i = 0; i < json_array.Size(); i++)
	{
		rapidjson::Value & first = json_array[i];
		rapidjson::Value & chapter = first["chapter"];

		rapidjson::Value & bombNum = chapter["bombNum"];
		bombNum.SetInt(bomb_num);
	}
	praseFinish(doc);
	//cout << "设置炸弹数量:" << bomb_num << endl;
}

void GameData::setPaintNum(int _num)
{
	auto doc = preparePrase();
	paint_num = _num;

	rapidjson::Value &json_array = doc["Tollgate"];
	for (unsigned int i = 0; i < json_array.Size(); i++)
	{
		rapidjson::Value & first = json_array[i];
		rapidjson::Value & chapter = first["chapter"];

		rapidjson::Value & paintNum = chapter["paintNum"];
		paintNum.SetInt(paint_num);
	}
	praseFinish(doc);
	//cout << "设置改色数量:" << paint_num << endl;
}

void GameData::setRanbowNum(int _num)
{
	auto doc = preparePrase();
	rainbow_num = _num;

	rapidjson::Value &json_array = doc["Tollgate"];
	for (unsigned int i = 0; i < json_array.Size(); i++)
	{
		rapidjson::Value & first = json_array[i];
		rapidjson::Value & chapter = first["chapter"];

		rapidjson::Value & ranbowNum = chapter["rainbowNum"];
		ranbowNum.SetInt(rainbow_num);
	}
	praseFinish(doc);
	//cout << "设置rainbow数量:" << rainbow_num << endl;
}

void GameData::setOldScore(int _score)
{
	auto doc = preparePrase();
	old_score = _score;

	rapidjson::Value &json_array = doc["Tollgate"];

	for (unsigned int i = 0; i < json_array.Size(); i++)
	{
		rapidjson::Value & first = json_array[i];
		rapidjson::Value & chapter = first["chapter"];

		rapidjson::Value & oldScore = chapter["oldScore"];
		oldScore.SetInt(old_score);
	}

	praseFinish(doc);
}