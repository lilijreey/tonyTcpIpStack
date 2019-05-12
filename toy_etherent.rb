require 'bindata'

require_relative 'toy_arp'



=begin
  https://wiki.wireshark.org/Ethernet

1. 以太帧介绍
 以太网有多种帧结构最常用的是 802.3

 +---------------------------------------------------------------------------------+
 |Preamble | Dst Mac | Src Mac | type/length| User Data    | Frame Check Sequence  |
 +---------------------------------------------------------------------------------+
 | 8B      |  6B     |   6B    |    2       |    46-1500   |  4                    |
 +---------------------------------------------------------------------------------+
           |                                               |   有的支持有的不支持
           \___________程序会接收的部分____________________/


 1 前导码：7字节0x55,一串1、0间隔，用于信号同步(程序側不会接收)
 2 帧起始定界符：1字节0xD5(10101011)，表示一帧开始 (程序側不会接收)
 3.FCS 使用CRC计算从目的MAC到数据域这部分内容而得到的校验和,发包的时候填充
       接受时网卡自动检查，如果不匹配则丢弃
 
2. 包大小
   * 协议规定载荷的范围是46-1500 所以加上包头就是整包的大小范围
     以太帧的最小长度为64B 18包头字节=6+6+2+4(FCS) + 46B
     以太帧的最大长度为 18包头字节=6+6+2+4(FCS) + 46B
   * 当载荷小于46B时，会填充到46B
   * 当载荷大于1500时， TODO

   巨帧: 有些网络设备支持巨帧超过1518
 

=end




class EtherHead < BinData::Record
=begin
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|       Ethernet destination address (first 32 bits)            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
| Ethernet dest (last 16 bits)  |Ethernet source (first 16 bits)|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|       Ethernet source address (last 32 bits)                  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|        Type code              |                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
=end
  endian :big
  mac_addr :dst
  mac_addr :src
  uint16   :eth_type
  rest     :payload
  #choice   :payload, selection: :ether_type do
  #  ip_pdu IPV4
  #  rest   :default
  #end
end

ETH_TYPE_IPV4 = 0x0800
ETH_TYPE_ARP  = 0x0806



def mk_ether(src, dst, eth_type, payload)
  pkg = EtherHead.new
  pkg.dst = dst
  pkg.src = src
  pkg.eth_type = eth_type
  pkg.payload = payload

  puts "mk eth #{pkg}"
  pkg.to_binary_s
end

def l2_parser(frame)
  head = EtherHead.read(frame)
  # only handle dst-mac or src-mac is myself package
  dir = 
  if head.dst == $g_ctx.mac
    :recv
  elsif head.src = $g_ctx.mac
    :send
  else
    return
    :nil
  end


  #TODO 广播包也应该处理
  if head.eth_type == ETH_TYPE_ARP
    #puts "#{head}"
    handle_arp(dir, head)
  end

end
