#!/usr/bin/ruby

require 'test/unit'
require_relative 'rubyexpect'

class GammaipBase < Test::Unit::TestCase
  self.test_order = :defined

  @@c = RubyExpect::Expect.spawn("picocom --quiet -b 115200 /dev/ttyUSB0")
  @@c.timeout = 1
  #@@c.debug = true

  def test_login
    @@c.send("root")
    @@c.expect("Last login")
    assert_true @@c.cmd?("echo we are logged")
  end

  def test_access_point()
    @@c.send("systemctl start access-point")
    assert_true @@c.cmd("systemctl is-active access-point", "active")
    assert_true @@c.cmd("systemctl is-active config-server", "active")
  end

  def test_var_www_folder()
    assert_true @@c.test?("-d /userdata/www/config-server")
    assert_true @@c.cmd("ls -la  /userdata/www/ | grep -o 'config-server\sconfig-server'", "config-server config-server")
  end

  def test_key_and_cert_exist
    assert_true @@c.test?("-f /userdata/ssl/key/nginx.key")
    assert_true @@c.test?("-f /userdata/ssl/cert/nginx.cert")
  end

  def test_logout
    @@c.send("exit")
  end
end
