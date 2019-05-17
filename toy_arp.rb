require 'bindata'

require_relative 'toy_common'
require_relative 'toy_etherent'

=begin
ARP 地址解析协议, 用与实现实现 IP 地址所在的设备Mac地址信息


例子:
A ping B, 对于A要把数据包发给B，需要得知链路层的地址（MAC),所以发送之前需要先
查询B 的ip所对应的Mac地址,使用ARP来实现

1. 谁会发
2. arp 请求
   自带本机IP,Mac, 发生二层广播
3. arp 相应
   只有ip是自己时才相应，其他情况丢弃

ARP 不仅可以工作在以太网和IP，也适用于其他链路层协议


=end



class Arp < BinData::Record
=begin
0             8                16                               31
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|            hwType             |    protcol_type               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
| hwAddLen    |  protocalAddrLen|          op                   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|      src hw addr (hwAdderLen) 对于以太网就是Mac地址6B         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|      src protocol addr (protocalAddrLen) 对于IP 就是ip地址    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|      dst hw addr (hwAdderLen) 对于以太网就是Mac地址6B         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|      dst protocol addr (protocalAddrLen) 对于IP 就是ip地址    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
=end

 HW_TYPE_ETHER = 1
 PROTO_TYPE_IP = 0x800
 OP_TYPE_ARP_REQ = 1
 OP_TYPE_ARP_RSP = 2
 OP_TYPE_RARP_REQ =3
 OP_TYPE_RARP_RSP =4
  endian :big
  uint16  :l2_type
  uint16  :l3_type
  uint8   :l2_adder_len
  uint8   :l3_adder_len
  uint16  :op # OP 
  mac_addr :src_mac
  ip_addr  :src_ip
  mac_addr :dst_mac
  ip_addr  :dst_ip

  #string  :src_l2_adder, read_length: :l2_adder_len
  #string  :src_l3_adder, read_length: :l3_adder_len
  #string  :dst_l2_adder, read_length: :l2_adder_len
  #string  :dst_l3_adder, read_length: :l3_adder_len
  # 由于肯定是以太网/IP协议arp 所以直接写死了
end

def mk_arp(op, src_mac, src_ip, dst_mac, dst_ip)
  arp = Arp.new
  arp.l2_type = Arp::HW_TYPE_ETHER
  arp.l3_type = Arp::PROTO_TYPE_IP
  arp.l2_adder_len = 6 #mac leng
  arp.l3_adder_len = 4 #ip len
  arp.op = op
  arp.src_mac = src_mac
  arp.src_ip = src_ip
  arp.dst_mac = dst_mac
  arp.dst_ip  = dst_ip
  puts "mk apr #{arp}"

  arp.to_binary_s
end

def hand_arp_request(req)
  # 这时的dst_mac 为全0
  if req.dst_ip.get == $g_ctx.stack_ip
    #mkdir arp rsp
    #puts "stack recv arp #{req}"
    printf "stack recv arp request src_ip:%s, src_mac:%s\n", req.src_ip.get, req.src_mac
    rsp = mk_arp(Arp::OP_TYPE_ARP_RSP, 
                 $g_ctx.stack_mac, $g_ctx.stack_ip,
                 req.src_mac, req.src_ip)
    eth = mk_ether(STACK_MAC, req.src_mac, ETH_TYPE_ARP, rsp)
    $g_ctx.tap.syswrite(eth)
  end
end

def handle_arp(dir, head)
  arp = Arp.read(head.payload)

 #OP_TYPE_ARP_REQ = 1
 #OP_TYPE_ARP_RSP = 2
 #OP_TYPE_RARP_REQ =3
 #OP_TYPE_RARP_RSP =4
  case arp.op
  when Arp::OP_TYPE_ARP_REQ
    hand_arp_request(arp)
  else :pass
  end
  
  #puts "my #{dir} arp  #{arp}"
end
