# lib/server.rb

require "bencode"
require "em/pure_ruby"
#require "eventmachine"

class NReplServer::Server < EM::Connection
  @@connected_clients = Array.new
  @@sessions = {}

  #
  # EventMachine handlers
  #

  def post_init
    @@connected_clients.push(self)
    puts "A client has connected."
  end

  def unbind
    @@connected_clients.delete(self)
    puts "A client has disconnected."
  end

  def receive_data(data)
    msg = BEncode.load(data)
    pp msg
    op = msg["op"]
    meth = "handle_#{op.tr('-','_')}"
    if self.respond_to? meth
      puts "Op #{op}"
      self.send(meth, msg)
    else
      puts "Unknown op #{op}"
      send_response msg, {"status" => ["unknown-op"]}
    end
  end

  #
  # nREPL handlers
  #

  def handle_clone(msg)
    id = rand(999999999).to_s
    @@sessions[id] = NReplServer::Session.new(self)

    send_response msg, {"status" => ["done"], "new-session" => id}
  end

  def handle_close(msg)
    @@sessions[msg["session"]] = nil
    send_response msg, {"status" => ["done"]}
  end

  def handle_describe(msg)
    ops = {}

    self.class.instance_methods.each do |meth|
      meth = meth.to_s
      if meth.start_with? "handle_"
        op = meth.delete_prefix "handle_"
        ops[op] = op
      end
    end

    response = {
      "status" => ["done"],
      "versions" => {
        "runtime" => {"name" => "ruby", "version-string" => "0.1.0"},
        "nrepl" => {"version-string" => "0.8.0"}
      },
      "ops" => ops
    }

    send_response msg, response
  end

  def handle_eval(msg)
    begin
      result = eval(msg["code"])
      send_response msg, {"status" => ["done"], "value" => result.pretty_inspect}
    rescue Exception => e
      send_response msg, {"status" => ["done"], "err" => e.inspect}
    end
  end

  def handle_load_file(msg)
    begin
      result = eval(msg["file"])
      send_response msg, {"status" => ["done"], "value" => result.pretty_inspect}
    rescue Exception => e
      send_response msg, {"status" => ["done"], "err" => e.inspect}
    end
  end

  def handle_ls_sessions(msg)
    send_response msg, {"status" => ["done"], "sessions" => @@sessions.keys}
  end

  def handle_stdin(msg)
    @@sessions[msg["session"]].stdin = msg["stdin"]
    send_response msg, {"status" => ["done"]}
  end

  def handle_interrupt(msg)
  end

  private

  def send_response(msg, resp)
    defaults = {"id" => msg["id"], "ns" => ">"}
    if msg["session"]
      defaults["session"] = msg["session"]
    end
    puts "sending #{resp.inspect}"
    send_data resp.merge(defaults).bencode
  end
end
