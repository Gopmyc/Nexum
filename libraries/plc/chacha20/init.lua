-- Copyright (c) 2018  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------
--[[

Chacha20 stream encryption

Pure Lua implementation of the chacha20 algorithm

This implements the IETF variant of  chacha20 encryption
as defined in RFC 7539  (12-byte nonce) and the xchacha20
variant (same encryption algorithm, but with a 24-byte nonce)

For the combined authenticated encryption with associated
data (AEAD) based on chacha20 encryption and poly1305
authentication, see the aead_chacha20.lua file


See also:
- many chacha20 links at
  http://ianix.com/pub/chacha-deployment.html

]]

-- Copyright (c) 2018  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------
local app, concat = table.insert, table.concat
local bit = require("bit")

local function rotl32(x, n)
	return bit.bor(bit.lshift(x, n), bit.rshift(x, 32 - n))
end

local function qround(st, x, y, z, w)
	local a, b, c, d = st[x], st[y], st[z], st[w]
	local t
	a = bit.band(a + b, 0xffffffff)
	t = bit.bxor(d, a); d = rotl32(t, 16)
	c = bit.band(c + d, 0xffffffff)
	t = bit.bxor(b, c); b = rotl32(t, 12)
	a = bit.band(a + b, 0xffffffff)
	t = bit.bxor(d, a); d = rotl32(t, 8)
	c = bit.band(c + d, 0xffffffff)
	t = bit.bxor(b, c); b = rotl32(t, 7)
	st[x], st[y], st[z], st[w] = a, b, c, d
	return st
end

local chacha20_state = {}
local chacha20_working_state = {}
for i = 1,16 do
	chacha20_state[i] = 0
	chacha20_working_state[i] = 0
end

local function unpack_u32_le(s, idx, n)
	idx = idx or 1
	n = n or math.floor((#s - idx + 1) / 4)
	local t = {}
	for i = 0, n-1 do
		local a,b,c,d = s:byte(idx + i*4, idx + i*4 + 3)
		t[#t+1] = a + b*2^8 + c*2^16 + d*2^24
	end
	return t
end

local function pack_u32_le(t)
	local s = {}
	for i=1,#t do
		local n = t[i]
		s[#s+1] = string.char(
			bit.band(n,0xff),
			bit.band(bit.rshift(n,8),0xff),
			bit.band(bit.rshift(n,16),0xff),
			bit.band(bit.rshift(n,24),0xff)
		)
	end
	return table.concat(s)
end

local function chacha20_block(key, counter, nonce)
	local st, wst = chacha20_state, chacha20_working_state
	st[1], st[2], st[3], st[4] = 0x61707865, 0x3320646e, 0x79622d32, 0x6b206574
	for i=1,8 do st[i+4] = key[i] end
	st[13] = counter
	for i=1,3 do st[i+13] = nonce[i] end
	for i=1,16 do wst[i] = st[i] end
	for _=1,10 do
		qround(wst,1,5,9,13)
		qround(wst,2,6,10,14)
		qround(wst,3,7,11,15)
		qround(wst,4,8,12,16)
		qround(wst,1,6,11,16)
		qround(wst,2,7,12,13)
		qround(wst,3,8,9,14)
		qround(wst,4,5,10,15)
	end
	for i=1,16 do st[i] = bit.band(st[i] + wst[i], 0xffffffff) end
	return st
end

local function chacha20_encrypt_block(key, counter, nonce, pt, ptidx)
	local rbn = #pt - ptidx + 1
	if rbn < 64 then
		local tmp = string.sub(pt, ptidx)
		pt = tmp .. string.rep("\0", 64 - rbn)
		ptidx = 1
	end
	local ba = unpack_u32_le(pt, ptidx, 16)
	local keystream = chacha20_block(key, counter, nonce)
	for i=1,16 do
		ba[i] = bit.bxor(ba[i], keystream[i])
	end
	local es = pack_u32_le(ba)
	if rbn < 64 then es = string.sub(es,1,rbn) end
	return es
end

local function chacha20_encrypt(key, counter, nonce, pt)
	assert((counter + math.floor(#pt/64) + 1) < 0xffffffff)
	assert(#key == 32)
	assert(#nonce == 12)
	local keya = unpack_u32_le(key,1,8)
	local noncea = unpack_u32_le(nonce,1,3)
	local t = {}
	local ptidx = 1
	while ptidx <= #pt do
		app(t, chacha20_encrypt_block(keya, counter, noncea, pt, ptidx))
		ptidx = ptidx + 64
		counter = counter + 1
	end
	return concat(t)
end

local function hchacha20(key, nonce16)
	local keya = unpack_u32_le(key,1,8)
	local noncea = unpack_u32_le(nonce16,1,4)
	local st = {}
	st[1], st[2], st[3], st[4] = 0x61707865,0x3320646e,0x79622d32,0x6b206574
	for i=1,8 do st[i+4] = keya[i] end
	for i=1,4 do st[i+12] = noncea[i] end
	for _=1,10 do
		qround(st,1,5,9,13)
		qround(st,2,6,10,14)
		qround(st,3,7,11,15)
		qround(st,4,8,12,16)
		qround(st,1,6,11,16)
		qround(st,2,7,12,13)
		qround(st,3,8,9,14)
		qround(st,4,5,10,15)
	end
	return pack_u32_le({st[1],st[2],st[3],st[4],st[13],st[14],st[15],st[16]})
end

local function xchacha20_encrypt(key, counter, nonce, pt)
	assert(#key == 32)
	assert(#nonce == 24)
	local subkey = hchacha20(key, nonce:sub(1,16))
	local nonce12 = "\0\0\0\0" .. nonce:sub(17)
	return chacha20_encrypt(subkey, counter, nonce12, pt)
end

return {
	chacha20_encrypt    = chacha20_encrypt,
	chacha20_decrypt    = chacha20_encrypt,
	encrypt             = chacha20_encrypt,
	decrypt             = chacha20_encrypt,
	hchacha20           = hchacha20,
	xchacha20_encrypt   = xchacha20_encrypt,
	xchacha20_decrypt   = xchacha20_encrypt,
	key_size            = 32,
	nonce_size          = 12,
	xnonce_size         = 24,
}


--end of chacha20