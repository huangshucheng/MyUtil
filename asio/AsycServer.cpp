#include "AsycServer.h"

class talk_to_client;
typedef boost::shared_ptr<talk_to_client> client_ptr;
typedef std::vector<client_ptr> _Sarray;
_Sarray clients;

io_service _Sservice;
ip::tcp::acceptor _acceptor(_Sservice, ip::tcp::endpoint(ip::tcp::v4(), 2001));

talk_to_client::talk_to_client():
sock_(_Sservice),
started_(false),
timer_(_Sservice),
clients_changed_(false)
{
	std::cout << "talk_to_client()" << std::endl;
}

//talk_to_client::~talk_to_client()
//{
//	std::cout << "~talk_to_client()" << std::endl;
//}

void talk_to_client::start() 
{
	std::cout << "start..." << std::endl;
	started_ = true;
	clients.push_back(shared_from_this());
	last_ping = boost::posix_time::microsec_clock::local_time();
	// first, we wait for client to login
	do_read();
}
boost::shared_ptr<talk_to_client> talk_to_client::new_()
{
	boost::shared_ptr<talk_to_client> new_(new talk_to_client);
	return new_;
}
void talk_to_client::stop() 
{
	std::cout << "stop()" << std::endl;

	if (!started_) return;
	started_ = false;
	sock_.close();

	boost::shared_ptr<talk_to_client> self = shared_from_this();
	_Sarray::iterator it = std::find(clients.begin(), clients.end(), self);
	clients.erase(it);
	update_clients_changed();
}
bool talk_to_client::started() const 
{ 
	return started_; 
}

ip::tcp::socket & talk_to_client::sock() 
{ 
	return sock_; 
}

std::string talk_to_client::username() const 
{ 
	return username_; 
}

void talk_to_client::set_clients_changed() 
{ 
	clients_changed_ = true; 
}

void talk_to_client::on_read(const error_code & err, size_t bytes) 
{
	std::cout << "on_read()" << std::endl;
	if (err) stop();
	if (!started()) return;
	// process the msg
	std::string msg(read_buffer_, bytes);
	if (msg.find("login ") == 0) on_login(msg);
	else if (msg.find("ping") == 0) on_ping();
	else if (msg.find("ask_clients") == 0) on_clients();
	else std::cout << "invalid msg " << msg << std::endl;
}

void talk_to_client::on_login(const std::string & msg) {
	std::cout << "on_login()" << std::endl;

	std::istringstream in(msg);
	in >> username_ >> username_;
	std::cout << username_ << " logged in" << std::endl;
	do_write("login ok\n");
	update_clients_changed();
}
void talk_to_client::on_ping() {
	std::cout << "on_ping()" << std::endl;

	do_write(clients_changed_ ? "ping client_list_changed\n" : "ping ok\n");
	clients_changed_ = false;
}
void talk_to_client::on_clients() {
	std::cout << "on_clients()" << std::endl;

	std::string msg;
	for (_Sarray::const_iterator b = clients.begin(), e = clients.end(); b != e; ++b)
		msg += (*b)->username() + " ";
	do_write("clients " + msg + "\n");
}

void talk_to_client::do_ping() {
	std::cout << "do_ping()" << std::endl;

	do_write("ping\n");
}
void talk_to_client::do_ask_clients() {
	std::cout << "do_ask_clients()" << std::endl;

	do_write("ask_clients\n");
}

void talk_to_client::on_check_ping() {
	std::cout << "on_check_ping()" << std::endl;

	boost::posix_time::ptime now = boost::posix_time::microsec_clock::local_time();
	if ((now - last_ping).total_milliseconds() > 5000) {
		std::cout << "stopping " << username_ << " - no ping in time" << std::endl;
		stop();
	}
	last_ping = boost::posix_time::microsec_clock::local_time();
}
void talk_to_client::post_check_ping() {
	std::cout << "post_check_ping()" << std::endl;

	timer_.expires_from_now(boost::posix_time::millisec(5000));
	timer_.async_wait(MEM_FN(on_check_ping));
}

void talk_to_client::on_write(const boost::system::error_code & err, size_t bytes) {
	std::cout << "on_write()" << std::endl;

	do_read();
}
void talk_to_client::do_read() {
	std::cout << "do_read()" << std::endl;

	async_read(sock_, buffer(read_buffer_),
		MEM_FN2(read_complete, _1, _2), MEM_FN2(on_read, _1, _2));
	post_check_ping();
}
void talk_to_client::do_write(const std::string & msg) {
	std::cout << "do_write()" << std::endl;

	if (!started()) return;
	std::copy(msg.begin(), msg.end(), write_buffer_);
	sock_.async_write_some(buffer(write_buffer_, msg.size()),
		MEM_FN2(on_write, _1, _2));
}
size_t talk_to_client::read_complete(const boost::system::error_code & err, size_t bytes) {
	std::cout << "read_complete()" << std::endl;

	if (err) return 0;
	bool found = std::find(read_buffer_, read_buffer_ + bytes, '\n') < read_buffer_ + bytes;
	// we read one-by-one until we get to enter, no buffering
	return found ? 0 : 1;
}

void talk_to_client::doConnect()
{
	std::cout << "doConnect()" << std::endl;

	boost::shared_ptr<talk_to_client> client = talk_to_client::new_();
	_acceptor.async_accept(client->sock(), boost::bind(handle_accept, client, _1));
	_Sservice.run();
}

void update_clients_changed()
{
	std::cout << "update_clients_changed()" << std::endl;

	for (_Sarray::iterator b = clients.begin(), e = clients.end(); b != e; ++b)
		(*b)->set_clients_changed();
}

void handle_accept(boost::shared_ptr<talk_to_client> client, const boost::system::error_code & err)
{
	std::cout << "start accept..." << std::endl;
	client->start();
	boost::shared_ptr<talk_to_client> new_client = talk_to_client::new_();
	_acceptor.async_accept(new_client->sock(), boost::bind(handle_accept, new_client, _1));
}