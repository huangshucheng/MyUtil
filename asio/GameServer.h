#pragma once
#include <iostream>

#include <boost/asio.hpp>
#include "boost/shared_ptr.hpp"
#include "boost/thread/thread.hpp"

class GameServer
{
public:
	typedef boost::shared_ptr<boost::asio::ip::tcp::socket> socket_ptr;

	GameServer();
	~GameServer();

	void ServerTest();
	void AsycServerTest();
	
	void start_accept(socket_ptr socket);
	void handle_accept(socket_ptr socket ,const boost::system::error_code& err);

private:
	boost::asio::io_service _service;
	boost::asio::ip::tcp::acceptor *_acceptor;
	int index = 0;
};