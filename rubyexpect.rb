require 'ruby_expect'
require 'digest/md5'

module RubyExpect
  class Expect
    attr_reader :child_pid
    def cmd?(cmd)
      send cmd
      sleep(0.1)
      send 'echo $?'
      sleep(0.1)
      r = expect /^0/
      !r.nil?
    end

    def cmd(cmd, expected, timeout = 0.1)
      send cmd
      sleep(timeout)
      r = expect expected
      !r.nil?
    end

    def exit()
      send "exit"
      r = expect "logout"
      !r.nil?
    end

    def clear()
      send " "
      send " "
    end

    def test?(test)
      cmd? "test #{test}"
    end

    def md5(cmd)
      hex = Digest::MD5.hexdigest cmd
      send "cmd=\'#{cmd}\'"
      sleep(0.5)
      send "echo -n $cmd | md5sum"
      sleep(0.2)
      expect hex
    end

    def md5sum_test?(test)
      r = md5 "test #{test}"
      if !r.nil?
        cmd? 'eval "$cmd"'
      else
        false
      end
    end

    def md5sum_cmd?(cmd)
      r = md5 cmd
      if !r.nil?
        cmd? 'eval "$cmd"'
      else
        false
      end
    end
  end
end
