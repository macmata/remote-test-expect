#!/usr/bin/ruby

require 'test/unit'
require 'ruby_expect'
require_relative 'rubyexpect'

class Basic  < Test::Unit::TestCase
  self.test_order = :defined
  @@c = RubyExpect::Expect.spawn("picocom -b 115200 /dev/ttyUSB0")
  @@c.timeout = 1
  @@c.debug = true

  def test_login
    @@c.send("root")
  end

  def test_irtel_cpu_fail
    assert_false(@@c.cmd?('cat /proc/cpuinfo | grep --only-matching --quiet "irtel"'))
  end

  def test_ARMv7_cpu
    assert_true(@@c.cmd?('grep --only-matching --quiet "ARMv7" /proc/cpuinfo'))
  end

  def test_file_bob
    assert_true @@c.cmd?('touch bob')
    assert_true @@c.test?('-f bob')
  end

  def test_md5_intel_cpu
    assert_true @@c.md5sum_cmd?('cat /proc/cpuinfo | grep --only-matching --quiet "ARMv7"')
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
    assert_false @@c.md5sum_cmd?("cat /etc/passwd | grep root | awk -F \":\" \'{print $1, $5}\' | wc --words")
  end

  def test_piping
    assert_true @@c.cmd("cat /etc/passwd | grep root | awk -F \":\" \'{print $1, $5}\' | wc --words", '2')
  end

  def test_login
    @@c.send("exit")
  end
end
