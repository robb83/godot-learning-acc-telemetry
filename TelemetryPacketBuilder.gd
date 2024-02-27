class_name PacketBuilder extends RefCounted

var values = []

func append_u8(data):
	var a = PackedByteArray()
	a.resize(1)
	a.encode_u8(0, data)
	values.push_back(a)
	
func append_u16(data):
	var a = PackedByteArray()
	a.resize(2)
	a.encode_u8(0, data)
	values.push_back(a)
	
func append_u32(data):
	var a = PackedByteArray()
	a.resize(4)
	a.encode_u32(0, data)
	values.push_back(a)
	
func append_s32(data):
	var a = PackedByteArray()
	a.resize(4)
	a.encode_s32(0, data)
	values.push_back(a)
	
func append_string(data):
	var a = data.to_utf8_buffer()
	append_u16(a.size())
	values.push_back(a)

func to_packed_byte_array():
	var result = PackedByteArray()
	for v in values:
		result += v
	return result
