class_name PacketReader extends Object

var buffer : PackedByteArray
var position : int

func set_buffer(data):
	buffer = data
	position = 0

func get_u8():
	var result = buffer.decode_u8(position)
	position += 1
	return result
	
func get_u16():
	var result = buffer.decode_u16(position)
	position += 2
	return result

func get_u32():
	var result = buffer.decode_u32(position)
	position += 4
	return result
	
func get_u64():
	var result = buffer.decode_u64(position)
	position += 8
	return result
	
func get_s8():
	var result = buffer.decode_s8(position)
	position += 1
	return result
	
func get_s16():
	var result = buffer.decode_s16(position)
	position += 2
	return result

func get_s32():
	var result = buffer.decode_s32(position)
	position += 4
	return result
	
func get_s64():
	var result = buffer.decode_s64(position)
	position += 8
	return result
	
func get_float():
	var result = buffer.decode_float(position)
	position += 4
	return result
	
func get_double():
	var result = buffer.decode_double(position)
	position += 8
	return result
	
func get_string():
	var length = buffer.decode_u16(position)
	position += 2
	
	var result = buffer.slice(position, position + length).get_string_from_utf8()
	position += length
	return result
