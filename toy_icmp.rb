require 'bindata'

require_relative 'toy_common'

=begin
https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol

0               8              16                               31
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|   type(8)     |  code(8)      |       Checksum(16)            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|               other head, 不同类型不同                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

ping 命令通过imcp协议实现

=end
