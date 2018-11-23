#!/usr/bin/ruby

require 'test/unit'
require 'net/scp'
require_relative 'rubyexpect'

class GammaipBase < Test::Unit::TestCase
  self.test_order = :defined

  @@c = RubyExpect::Expect.spawn("picocom --quiet -b 115200 /dev/ttyUSB0")
  @@c.timeout = 1
  #@@c.debug = true
  @@remote_path = '/media/scratch/update.swu'
  @@local_path = './tftp/gammaip-image-update-gammaip.swu'

  def test_login
    @@c.send("root")
    @@c.expect("Last login")
    assert_true @@c.cmd?("echo we are logged")
  end

  def test_update
    @@c.cmd?("modprobe g_ether")
    @@c.cmd?("ip addr add 192.168.7.11/24 dev usb0")
    @@c.cmd?("ip link set usb0 up")

    Net::SCP.start('192.168.7.11', 'root', :password => "" ) do |scp|
      puts 'SCP Started!'
      x = scp.upload('/home/aleblanc/sfl/dhcp_tftp/tftp/gammaip-image-update-gammaip.swu', @@remote_path)
      x.wait
    end

  end

  def test_logout
    @@c.send("exit")
  end
end


