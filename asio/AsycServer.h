#pragma once

#ifdef WIN32
#define _WIN32_WINNT 0x0501
#include <stdio.h>
#endif

#include <iostream>
#include <boost/bind.hpp>
#include <boost/asio.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>

using namespace boost::asio;
using namespace boost::posix_time;

#define MEM_FN(x)       boost::bind(&self_type::x, shared_from_this())
#define MEM_FN1(x,y)    boost::bind(&self_type::x, shared_from_this(),y)
#define MEM_FN2(x,y,z)  boost::bind(&self_type::x, shared_from_this(),y,z)

class talk_to_client : public boost::enable_shared_from_this<talk_to_client>, boost::noncopyable {
	typedef talk_to_client self_type;
	talk_to_client();
	//~talk_to_client();
public:
	typedef boost::system::error_code error_code;

	void start();
	static boost::shared_ptr<talk_to_client> new_();
	void stop();
	bool started() const;
	ip::tcp::socket & sock();
	std::string username() const;
	void set_clients_changed();
private:
	void on_read(const error_code & err, size_t bytes);

	void on_login(const std::string & msg);
	void on_ping();
	void on_clients();

	void do_ping();
	void do_ask_clients();

	void on_check_ping();
	void post_check_ping();

	void on_write(const error_code & err, size_t bytes);
	void do_read();
	void do_write(const std::string & msg);
	size_t read_complete(const boost::system::error_code & err, size_t bytes);

public:
	static void doConnect();
private:
	ip::tcp::socket sock_;
	enum { max_msg = 1024 };
	char read_buffer_[max_msg];
	char write_buffer_[max_msg];
	bool started_;
	std::string username_;
	deadline_timer timer_;
	boost::posix_time::ptime last_ping;
	bool clients_changed_;
};

void update_clients_changed();
void handle_accept(boost::shared_ptr<talk_to_client> client, const boost::system::error_code & err);