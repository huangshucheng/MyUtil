#pragma once

#include <iostream>
#include <boost/asio.hpp>

class ClientTest
{
public:
	ClientTest();
	~ClientTest();
	void testClient();
	void testAsycClient();

	void connect_handler(const boost::system::error_code& er);
};
