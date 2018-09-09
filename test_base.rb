#!/usr/bin/ruby

require 'test/unit'
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

    def cmd(cmd, expected)
      send cmd
      sleep(0.1)
      r = expect expected
      !r.nil?
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

class Basic  < Test::Unit::TestCase
  self.test_order = :defined

  @@c = RubyExpect::Expect.spawn("picocom -b 115200 /dev/ttyUSB0")
  @@c.timeout = 1
  @@c.debug = true

  def test_login
    assert_true(!@@c.expect("Last login").nil?)
  end

  def test_irtel_cpu_fail
    assert_false(@@c.cmd?('cat /proc/cpuinfo | grep --only-matching --quiet "irtel"'))
  end

  def test_intel_cpu
    assert_true(@@c.cmd?('grep --only-matching --quiet "intel" /proc/cpuinfo'))
  end

  def test_file_bob
    assert_true @@c.cmd?('touch bob')
    assert_true @@c.test?('-f bob')
  end

  def test_md5_intel_cpu
    assert_true @@c.md5sum_cmd?('cat /proc/cpuinfo | grep --only-matching --quiet "intel"')
  end

  def test_md5_file_bob
    assert_true @@c.cmd?('touch bob')
    assert_true @@c.md5sum_test?('-f bob')
  end

  def test_redirect
    assert_true @@c.md5sum_cmd?('echo "allo" > bob2')
    assert_true @@c.md5sum_test?('-f bob2')
  end

  def test_piping_and_long_cmd_with_eval_in_md5_fail
    assert_false @@c.md5sum_cmd?("cat /etc/passwd | grep macmata | awk -F \":\" \'{print $1, $5}\' | wc --words")
  end

  def test_piping
    assert_true @@c.cmd("cat /etc/passwd | grep macmata | awk -F \":\" \'{print $1, $5}\' | wc --words", '2')
  end
end
