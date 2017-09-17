#include "TBClient.h"
#include "boost/bind.hpp"
#include "boost/asio.hpp"
#include "boost/thread.hpp"

void asyc_echo(std::string &msg)
{
	using namespace boost::asio;
	try
	{
		boost::asio::io_service _TB_service;
		std::cout << "client start..." << std::endl;
		ip::tcp::endpoint _ep(ip::address::from_string("192.168.1.103"), 2001);
		ip::tcp::socket _socket(_TB_service);
		_socket.connect(_ep);

		_socket.write_some(buffer(msg));
		std::vector<char>_buf(100, 0);
		_socket.read_some(buffer(_buf));
		_socket.close();

		log("send msg ====== %s", msg.c_str());
		log("receive buf:%s", &_buf[0]);
	}
	catch (std::exception& e)
	{
		log("exception:%s", e.what());
		std::cout << "exception:  " << e.what() << std::endl;
	}
}

void startTBConnect()
{
	
	std::vector<std::string> _vec;
	_vec.push_back("hcc");
	_vec.push_back("longzhao");
	_vec.push_back("wangminjun");
	_vec.push_back("linrongjun");
	boost::thread_group threads;
	for (auto &str:_vec)
	{
		threads.create_thread(boost::bind(asyc_echo, str));
		//boost::this_thread::sleep(boost::posix_time::microsec(300));
	}
	threads.join_all();
	/*
	std::string tmpstr = "hccfuck";
	asyc_echo(tmpstr);
	*/
}