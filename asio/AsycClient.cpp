#include "AsycClient.h"

io_service service;

talk_to_svr::talk_to_svr(const std::string & username)
:sock_(service),
started_(true),
username_(username),
timer_(service)
{
}

void talk_to_svr::start(ip::tcp::endpoint ep)
{
	cocos2d::log("start...");
	sock_.async_connect(ep, MEM_FN1(on_connect, _1));
}

boost::shared_ptr<talk_to_svr> talk_to_svr::start(ip::tcp::endpoint ep, const std::string & username)
{
	boost::shared_ptr<talk_to_svr> new_(new talk_to_svr(username));
	new_->start(ep);
	return new_;
}

void talk_to_svr::stop() 
{
	cocos2d::log("stop...");
	if (!started_) 
		return;
	std::cout << "stopping " << username_ << std::endl;
	started_ = false;
	sock_.close();
}

bool talk_to_svr::started() 
{ 
	cocos2d::log("started...");
	return started_;
}

void talk_to_svr::on_connect(const boost::system::error_code & err)
{
	
	if (!err)
	{
		cocos2d::log("on_connect success...");
		do_write("login: " + username_ + "\n");
	}
	else
	{
		cocos2d::log("on_connect failed...%s",err.message().c_str());
		std::cout << err.message() << std::endl;
		stop();
	}
}

void talk_to_svr::on_read(const boost::system::error_code & err, size_t bytes)
{
	cocos2d::log("on_read...");
	if (err) stop();
	if (!started()) return;
	std::string msg(read_buffer_, bytes);
	if (msg.find("login ") == 0) on_login();
	else if (msg.find("ping") == 0) on_ping(msg);
	else if (msg.find("clients ") == 0) on_clients(msg);
	else std::cerr << "invalid msg " << msg << std::endl;
}

void talk_to_svr::on_login()
{
	cocos2d::log("on_login...");
	std::cout << username_ << " logged in" << std::endl;
	do_ask_clients();
}

void talk_to_svr::on_ping(const std::string & msg) 
{
	cocos2d::log("on_ping...");
	std::istringstream in(msg);
	std::string answer;
	in >> answer >> answer;
	if (answer == "client_list_changed") 
		do_ask_clients();
	else 
		postpone_ping();
}

void talk_to_svr::on_clients(const std::string & msg)
{
	cocos2d::log("on_clients...");
	std::string clients = msg.substr(8);
	std::cout << username_ << ", new client list:" << clients;
	postpone_ping();
}

void talk_to_svr::do_ping() 
{
	cocos2d::log("do_ping...");
	do_write("ping\n");
}

void talk_to_svr::postpone_ping()
{
	cocos2d::log("postpone_ping...");
	int millis = rand() % 7000;
	std::cout << username_ << " postponing ping " << millis
		<< " millis" << std::endl;
	timer_.expires_from_now(boost::posix_time::millisec(millis));
	timer_.async_wait(MEM_FN(do_ping));
}

void talk_to_svr::do_ask_clients() 
{
	cocos2d::log("do_ask_clients...");
	do_write("ask_clients\n");
}

void talk_to_svr::on_write(const boost::system::error_code & err, size_t bytes)
{
	cocos2d::log("on_write...");
	do_read();
}

void talk_to_svr::do_read()
{
	cocos2d::log("do_read...");
	async_read(sock_, buffer(read_buffer_),
		MEM_FN2(read_complete, _1, _2), MEM_FN2(on_read, _1, _2));
}

void talk_to_svr::do_write(const std::string & msg) 
{
	cocos2d::log("do_write...");
	if (!started()) return;
	std::copy(msg.begin(), msg.end(), write_buffer_);
	sock_.async_write_some(buffer(write_buffer_, msg.size()),
		MEM_FN2(on_write, _1, _2));
}

size_t talk_to_svr::read_complete(const boost::system::error_code & err, size_t bytes) 
{
	cocos2d::log("read_complete...");
	if (err) return 0;
	bool found = std::find(read_buffer_, read_buffer_ + bytes, '\n') < read_buffer_ + bytes;
	return found ? 0 : 1;
}

void talk_to_svr::doConnect()
{
	cocos2d::log("doConnect...");
	ip::tcp::endpoint ep(ip::address::from_string("192.168.1.103"), 2001);
	/*
	char* names[] = { "John", "James", "Lucy", "Tracy", "Frank", "Abby", 0 };
	for (char ** str = names; *str; ++str) {
		talk_to_svr::start(ep, *str);
		boost::this_thread::sleep(boost::posix_time::millisec(100));
	}
	*/
	talk_to_svr::start(ep, "hcc");
	service.run();
}