function LIBRARY:Initialize(tJSONLib, tChaCha20Lib, tPoly1305Lib, tLZWLib)
	return setmetatable(
		{
			JSON		= tJSONLib,
			CHACHA20	= tChaCha20Lib,
			POLY1305	= tPoly1305Lib,
			LZW			= tLZWLib,
		},
	{ __index	= LIBRARY })
end

function LIBRARY:IsValidData(tData)
	return istable(tData)
		and isstring(tData.ID)
		and tData.CONTENT ~= nil
		and isbool(tData.ENCRYPTED)
		and isbool(tData.COMPRESSED)
end

function LIBRARY:Encode(tData)
	assert(istable(self.JSON), "[LIB-CODEC] JSON library required")
	assert(isfunction(self.JSON.encode), "[LIB-CODEC] JSON.encode missing")
	assert(istable(tData) and self:IsValidData(tData), "[LIB-CODEC] Invalid data")

	local sJSONContent;
	local bSuccess, tData.CONTENT = pcall(self.JSON.encode, tData.CONTENT)
	if not bSuccess then
		return MsgC(Color(231,76,60), "[LIB-CODEC] Failed to encode content")
	end

	if tData.COMPRESSED then
		assert(istable(self.LZW) and isfunction(self.LZW.compress), "[LIB-CODEC] LZW.compress missing")

		bSuccess, tData.CONTENT	= pcall(self.LZW.compress, tData.CONTENT)
		if not bSuccess then
			return MsgC(Color(231,76,60), "[LIB-CODEC] Failed to compress content")
		end
	end

	if tData.ENCRYPTED then
		assert(istable(self.CHACHA20) and isfunction(self.CHACHA20.encrypt), "[LIB-CODEC] CHACHA20.encrypt missing")
		assert(istable(self.POLY1305) and isfunction(self.POLY1305.mac), "[LIB-CODEC] POLY1305.mac missing")

		tData.NONCE		= tostring(math.random(0,2^31)) .. "-" .. tostring(math.random(0,2^31))

		bSuccess, tData.CONTENT	= pcall(self.CHACHA20.encrypt, tData.CONTENT, tData.NONCE)
		if not bSuccess then
			return MsgC(Color(231,76,60), "[LIB-CODEC] Failed to encrypt content")
		end

		bSuccess, tData.TAG	= pcall(self.POLY1305.mac, tData.CONTENT, tData.NONCE)
		if not bSuccess then
			return MsgC(Color(231,76,60), "[LIB-CODEC] Failed to generate Poly1305 tag")
		end
	end

	bSuccess, sJSONContent	= pcall(self.JSON.encode, tData)

	return bSuccess and sJSONContent or MsgC(Color(231,76,60), "[LIB-CODEC] Failed to encode data JSON")
end

function LIBRARY:Decode(sData)
	assert(istable(self.JSON) and isfunction(self.JSON.decode), "[LIB-CODEC] JSON.decode missing")
	assert(isstring(sData), "[LIB-CODEC] Data must be string")

	local bSuccess, tData = pcall(self.JSON.decode, sData)
	if not bSuccess then
		return MsgC(Color(231,76,60), "[LIB-CODEC] Failed to decode JSON")
	end

	if not self:IsValidData(tData) then
		return MsgC(Color(231,76,60), "[LIB-CODEC] Invalid data format")
	end

	if tData.ENCRYPTED then
		assert(istable(self.POLY1305) and isfunction(self.POLY1305.mac), "[LIB-CODEC] POLY1305.mac missing")
		assert(istable(self.CHACHA20) and isfunction(self.CHACHA20.decrypt), "[LIB-CODEC] CHACHA20.decrypt missing")

		local bValid, sTag	= pcall(self.POLY1305.mac, tData.CONTENT, tData.NONCE)
		if not bValid or sTag ~= tData.TAG then
			return MsgC(Color(231,76,60), "[LIB-CODEC] Invalid Poly1305 tag - data tampered")
		end

		bSuccess, tData.CONTENT	= pcall(self.CHACHA20.decrypt, tData.CONTENT, tData.NONCE)
		if not bSuccess then
			return MsgC(Color(231,76,60), "[LIB-CODEC] Failed to decrypt content")
		end
	end

	if tData.COMPRESSED then
		assert(istable(self.LZW) and isfunction(self.LZW.decompress), "[LIB-CODEC] LZW.decompress missing")

		bSuccess, tData.CONTENT	= pcall(self.LZW.decompress, tData.CONTENT)
		if not bSuccess then
			return MsgC(Color(231,76,60), "[LIB-CODEC] Failed to decompress content")
		end
	end

	bSuccess, tData.CONTENT	= pcall(self.JSON.decode, tData.CONTENT)
	if not bSuccess then
		return MsgC(Color(231,76,60), "[LIB-CODEC] Failed to decode JSON content")
	end

	return tData.ID, tData.CONTENT
end