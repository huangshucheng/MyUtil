#include "GameServer.h"
#include "boost/array.hpp"
#include "boost/bind.hpp"

GameServer::GameServer()
{
}

GameServer::~GameServer()
{
}
//同步服务端
void GameServer::ServerTest()
{
	using namespace boost::asio;
	try
	{
		std::cout << "Server start." << std::endl;
		boost::asio::io_service m_io_service;
		ip::tcp::endpoint _ep(ip::tcp::v4(), 2001);
		ip::tcp::acceptor acceptor(m_io_service, _ep);
		std::cout <<"Server Local address:"<<acceptor.local_endpoint().address() <<"   ,port:" << acceptor.local_endpoint().port() << std::endl;
		while (true)
		{
			ip::tcp::socket socket(m_io_service);
			acceptor.accept(socket);
			std::cout << "client address:" << socket.remote_endpoint().address() << "connected!!!!" << std::endl;
			//socket.write_some(boost::asio::buffer("hello asio------------------->"));
			std::vector<char>str(100,0);
			socket.read_some(buffer(str));
			system(&str[0]);
			std::cout << "Server receive buff : " <<&str[0]<< std::endl;
		}
	}
	catch (std::exception& e)
	{
		std::cout << e.what() << std::endl;
	}
}
//异步服务端
void GameServer::AsycServerTest()
{
	using namespace boost::asio;
	try
	{
		ip::tcp::endpoint _ep(ip::tcp::v4(), 2001);
		this->_acceptor = new ip::tcp::acceptor(this->_service, _ep);
		socket_ptr _socket(new ip::tcp::socket(this->_service));
		this->_service.run();
		this->start_accept(_socket);
	}
	catch (std::exception& e)
	{
		std::cout << e.what() << std::endl;
	}
}

void GameServer::start_accept(socket_ptr socket)
{
	using namespace boost::asio;
	index++;
	this->_acceptor->async_accept(*socket, boost::bind(&GameServer::handle_accept,this,socket, boost::asio::placeholders::error));
	std::cout << "start_accept... index:"<<this->index<< std::endl;
}

void GameServer::handle_accept(socket_ptr socket, const boost::system::error_code& err)
{
	if (err)
	{
		std::cout << "error----->" << std::endl;
		return;
	}
	using namespace boost::asio;

	//TODO user socket to read or write
	std::cout << "client address:" << socket->remote_endpoint().address() << "connected!!!!" << std::endl;
	std::vector<char>str(100, 0);
	socket->read_some(buffer(str));
	system(&str[0]);
	std::cout << "Server receive buff : " << &str[0] << std::endl;
	system(&str[0]);

	//create next socket
	socket_ptr next_sock(new ip::tcp::socket(this->_service));
	std::cout << "handle_accept..." << std::endl;
	this->start_accept(next_sock);
}