#!/usr/bin/ruby

require 'test/unit'
require_relative 'rubyexpect'

class GammaipBase < Test::Unit::TestCase
	self.test_order = :defined

  @@c = RubyExpect::Expect.spawn("picocom -b 115200 /dev/ttyUSB0")
  @@c.timeout = 1

  def test_login
    @@c.send("root")
	@@c.expect("password")
    @@c.send("root")
	@@c.expect("Last login")
	assert_true @@c.cmd?("echo we are logged")
  end

  def test_logout
    @@c.send("exit")
  end
end
