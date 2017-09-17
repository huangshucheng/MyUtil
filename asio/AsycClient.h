#pragma once

#ifdef WIN32
#define _WIN32_WINNT 0x0501
#include <stdio.h>
#endif

#include <iostream>
#include "cocos2d.h"

#include <boost/bind.hpp>
#include <boost/asio.hpp>
#include <boost/thread.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/system/error_code.hpp>
#include <boost/enable_shared_from_this.hpp>

using namespace boost::asio;

#define MEM_FN(x)       boost::bind(&self_type::x, shared_from_this())
#define MEM_FN1(x,y)    boost::bind(&self_type::x, shared_from_this(),y)
#define MEM_FN2(x,y,z)  boost::bind(&self_type::x, shared_from_this(),y,z)

class talk_to_svr : public boost::enable_shared_from_this<talk_to_svr>, boost::noncopyable {
	typedef talk_to_svr self_type;
	talk_to_svr(const std::string & username);
	void start(ip::tcp::endpoint ep);
public:

	static boost::shared_ptr<talk_to_svr> start(ip::tcp::endpoint ep, const std::string & username);
	void stop();
	bool started();
public:
	static void doConnect();
private:
	void on_connect(const boost::system::error_code & err);
	void on_read(const boost::system::error_code & err, size_t bytes);

	void on_login();
	void on_ping(const std::string & msg);
	void on_clients(const std::string & msg);

	void do_ping();
	void postpone_ping();
	void do_ask_clients();

	void on_write(const boost::system::error_code & err, size_t bytes);
	void do_read();
	void do_write(const std::string & msg);
	size_t read_complete(const boost::system::error_code & err, size_t bytes);

private:
	ip::tcp::socket sock_;
	enum { max_msg = 1024 };
	char read_buffer_[max_msg];
	char write_buffer_[max_msg];
	bool started_;
	std::string username_;
	deadline_timer timer_;
};
