#include "Boost_asio.h"
#include "boost/bind.hpp"

ClientTest::ClientTest()
{
}

ClientTest::~ClientTest()
{
}

void ClientTest::testClient()
{
	using namespace boost::asio;
	try
	{
		std::cout << "client start..." << std::endl;
		io_service _service;
		ip::tcp::endpoint _ep(ip::address::from_string("127.0.0.1"), 2001);
		ip::tcp::socket _socket(_service);
		_socket.connect(_ep);
		_socket.write_some(boost::asio::buffer("calc"));
	}
	catch (std::exception& e)
	{
		std::cout << e.what() << std::endl;
	}
	
}

void ClientTest::testAsycClient()
{
	using namespace boost::asio;
	try
	{
		std::cout << "asyc client start..." << std::endl;
		io_service _service;
		ip::tcp::endpoint _ep(ip::address::from_string("127.0.0.1"), 2001);
		ip::tcp::socket _socket(_service);
		_socket.async_connect(_ep, boost::bind(&ClientTest::connect_handler, this, boost::asio::placeholders::error));
		_socket.write_some(boost::asio::buffer("calc"));
		_service.run();
		//_socket.async_write_some(boost::asio::buffer("calc"), nullptr);
	}
	catch (std::exception& e)
	{
		std::cout << e.what() << std::endl;
	}
}

void ClientTest::connect_handler(const boost::system::error_code& er)
{
	std::cout<<"err code: "<<er.message()<<std::endl;
}