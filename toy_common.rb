require 'bindata'

TAP_NAME = 'tap1'
TAP_MAC = '4e:b8:17:02:3b:17'
TAP_IP = '192.168.33.22'
TAP_MASK = '255.255.255.0'

STACK_IP ='192.168.33.11'
STACK_MAC = '4e:e8:17:02:11:03'
$g_ctx = Struct.new(:name, :ip, :mac, :stack_ip, :stack_mac, :tap).new(TAP_NAME, TAP_IP, TAP_MAC,
                                                                STACK_IP, STACK_MAC)


class IpAddr < BinData::Primitive
  array :octets, type: :uint8, initial_length: 4

  def set(val)
    self.octets = val.split(/\./).collect(&:to_i)
  end

  def get
    self.octets.collect { |octet| "%d" % octet }.join(".")
  end
end

class MacAddr < BinData::Primitive
  array :octets, type: :uint8, initial_length: 6

  def set(val)
    self.clear
    self.octets = val.split(/\:/).collect {|i| i.to_i(16)}
  end

  def get
    self.octets.collect { |octet| "%02x" % octet }.join(":")
  end
end

MAC_BROADCAST_ADDR = MacAddr.new("ff:ff:ff:ff:ff:ff")
MAC_ZORE_ADDR = MacAddr.new()

