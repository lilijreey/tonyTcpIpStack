require 'rb_tuntap'

## my files
require_relative 'toy_common'
require_relative 'toy_etherent'


def create_tap 
    tap = RbTunTap::TapDevice.new(TAP_NAME)
    tap.open(false) # set NO_IP

    #set ip, netmask
    tap.addr = TAP_IP
    tap.netmask = TAP_MASK
    tap.hwaddr = TAP_MAC
    tap.up

    tap.to_io

end

def main
    tap = create_tap
    $g_ctx.tap = tap

    while true
      ## Qus. 每次读取是否为一个完整以太帧
      l2frame = tap.sysread(65535)
      l2_parser(l2frame) #toy_etherent.rb
    end

end

main
