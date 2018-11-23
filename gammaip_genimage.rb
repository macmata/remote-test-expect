#!/usr/bin/ruby

require 'test/unit'
require 'net/scp'
require_relative 'rubyexpect'

class GammaipBase < Test::Unit::TestCase
  self.test_order = :defined

  @@c = RubyExpect::Expect.spawn("picocom --quiet -b 115200 /dev/ttyUSB0")
  @@c.debug = true

  def boot_reset
    @@c.timeout = 20
    @@c.expect("")
    @@c.send("setenv bootpart 9;")
    @@c.send("fatload mmc 1:${bootpart} ${fdtaddr} ${fdtfile};")
    @@c.send("fatload mmc 1:${bootpart} ${loadaddr} ${bootfile};")
    @@c.send("setenv bootargs console=ttyO0,115200n8;")
    @@c.send("bootz ${loadaddr} - ${fdtaddr};'")
    @@c.expect("/ #")
    @@c.send("modprobe g_ether")
    @@c.expect("dhclient usb0")
    @@c.send("dhclient usb0")
    puts "device prep for update"
  end

end


