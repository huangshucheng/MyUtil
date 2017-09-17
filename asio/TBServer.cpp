#include "TBServer.h"
#include "boost/bind.hpp"
#include "boost/asio.hpp"
#include "boost/thread.hpp"

void TBServerStart()
{
	using namespace boost::asio;
	io_service _myservice;
	ip::tcp::acceptor _acceptor(_myservice,ip::tcp::endpoint(ip::tcp::v4(),2001));
	std::vector<char>_buf(100, 0);
	while (1)
	{
		std::cout << "start server..." << std::endl;
		ip::tcp::socket _socket(_myservice);
		_acceptor.accept(_socket);
		std::cout << "client address:" << _socket.remote_endpoint().address() << "connected!!!!" << std::endl;
		_socket.read_some(buffer(_buf));
		_socket.write_some(buffer(_buf));
		std::cout << "Server receive buff : " << &_buf[0] << std::endl;
		_socket.close();
	}
}