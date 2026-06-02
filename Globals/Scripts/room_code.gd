class_name RoomCode

# Encodes IPv4 (4 bytes) + port (2 bytes) = 6 bytes → 10 base-32 chars
const CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

static func encode(port: int) -> String:
	var ip_str = _get_local_ip()
	var parts = ip_str.split(".")
	if parts.size() != 4:
		return ""

	# Pack into 6 bytes: 4 for IP, 2 for port
	var data: PackedByteArray = PackedByteArray([
		int(parts[0]), int(parts[1]), int(parts[2]), int(parts[3]),
		(port >> 8) & 0xFF, port & 0xFF
	])

	return _base32_encode(data)


static func decode(code: String) -> Dictionary:
	code = code.strip_edges().to_upper()
	var data = _base32_decode(code)
	if data.size() < 6:
		return {}

	var ip = "%d.%d.%d.%d" % [data[0], data[1], data[2], data[3]]
	var port = (data[4] << 8) | data[5]
	return {"ip": ip, "port": port}


static func _get_local_ip() -> String:
	for addr in IP.get_local_addresses():
		if addr.begins_with("192.168.") or addr.begins_with("10.") or addr.begins_with("172."):
			return addr
	return "127.0.0.1"


static func _base32_encode(data: PackedByteArray) -> String:
	var result = ""
	var buffer = 0
	var bits = 0
	for byte in data:
		buffer = (buffer << 8) | byte
		bits += 8
		while bits >= 5:
			bits -= 5
			result += CHARS[(buffer >> bits) & 0x1F]
	if bits > 0:
		result += CHARS[(buffer << (5 - bits)) & 0x1F]
	return result


static func _base32_decode(code: String) -> PackedByteArray:
	var result: PackedByteArray = []
	var buffer = 0
	var bits = 0
	for ch in code:
		var val = CHARS.find(ch)
		if val == -1:
			continue
		buffer = (buffer << 5) | val
		bits += 5
		if bits >= 8:
			bits -= 8
			result.append((buffer >> bits) & 0xFF)
	return result
