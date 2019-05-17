require 'bindata'

require_relative 'toy_common'
require_relative 'toy_icmp'

=begin
IPv4 https://en.wikipedia.org/wiki/IPv4#Header

0               8              16                               31
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  ver  |  ihl  |   dscp  | ecn |         total-length          |
|  (4)  |  (4)  |   (6)   | (2) |           (16)                |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|        id (16)                | flags(3)| fragment-offset(13) |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|   ttl(8)      |  protocol(8)  |      header-checksum(16)      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                           srouce-ip                           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         dstionation-ip                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options(if IHL > 5) (0-320B)               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

ver: ipv4 or ipv6
ihl: 头部长度，单位为4B，由于ip头有可选字段用于确认可选字段长度
     可选字段必须为4bit倍数
dscp: 分区服务, 用于支持服务质量功能
ecn: 拥塞标识符，当路由器感知拥塞后设置为11以降低发送速度
id:  用于表示一组ip分片,属于同一个ip
flags: 最后一个分片为0，其他为1
fragoffset: 用于表示本分片在原始ip中的偏移,单位为8B,由于只有13位，能够表示的最大偏移为
           (1<<13 -1)* 8 = 65528
ttl:

=end

# IP Protocol Data Unit
class IpV4Head < BinData::Record
  endian :big

  bit4   :version, asserted_value: 4
  bit4   :header_length
  uint8  :tos
  uint16 :total_length
  uint16 :ident
  bit3   :flags
  bit13  :frag_offset
  uint8  :ttl
  uint8  :protocol
  uint16 :checksum
  ip_addr :src_addr
  ip_addr :dest_addr
  string :options, read_length: :options_length_in_bytes
  rest   :payload

  def header_length_in_bytes
    header_length * 4
  end

  def options_length_in_bytes
    header_length_in_bytes - options.rel_offset
  end

  def payload_length_in_bytes
    total_length - header_length_in_bytes
  end
end

# https://en.wikipedia.org/wiki/List_of_IP_protocol_numbers

IP_PROTO_ICMP = 1
IP_PROTO_IGMP = 2
IP_PROTO_IPINIP = 4
IP_PROTO_TCP = 6
IP_PROTO_UDP = 17
IP_PROTO_ICMPV6 = 58
IP_PROTO_SCTP = 132

def ip_protocol_to_name(proto)
  case proto
    when IP_PROTO_ICMP then "ICMP"
    when IP_PROTO_IGMP then "IGMP"
    when IP_PROTO_IPINIP then "IPinIP"
    when IP_PROTO_TCP then "TCP"
    when IP_PROTO_UDP then "UDP"
    when IP_PROTO_ICMPV6 then "ICMPv6"
    when IP_PROTO_SCTP then "SCTP"
    else "unkonwn protocol:#{proto}"
  end
end

def handle_ipv4(dir, l2)
  ip = IpV4Head.read(l2.payload)
  #TODO checkmask
  #TODO IP fragment assemable
  #TODO optional

  case ip.protocol
  when IP_PROTO_ICMP then handle_icmp(ip)
  else
    puts "recv ip#{ip}"
  end




end

