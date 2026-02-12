-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------
--[[

Poly1305 message authentication (MAC) created by Dan Bernstein

Originally used with AES, then with Salsa20 in the NaCl library.
Used with Chacha20 in recent TLS and SSH [1]

[1] https://en.wikipedia.org/wiki/Poly1305

Specified in RFC 7539 [2] jointly with chacha20 stream encryption and
with an AEAD construction (authenticated encryption with additional
data).

[2] http://www.rfc-editor.org/rfc/rfc7539.txt

This file contains only the poly1305 functions:

	auth(m, k) -> mac
		-- compute the mac for a message m and a key k
		-- this is tha main API of the module

	the following functions should be used only if the MAC must be
	computed over several message parts.

	init(k) -> state
		-- initialize the poly1305 state with a key
	update(state, m) -> state
		-- update the state with a fragment of a message
	finish(state) -> mac
		-- finalize the computation and return the MAC

	Note: several update() can be called between init() and finish().
	For every invocation but the last, the fragment of message m
	passed to update() must have a length multiple of 16 bytes:
		st = init(k)
		update(st, m1) -- here,  #m1 % 16 == 0
		update(st, m2) -- here,  #m2 % 16 == 0
		update(st, m3) -- here,  #m3 can be arbitrary
		mac = finish(st)

	The simple API auth(m, k) is implemented as
		st = init(k)
		update(st, m)  -- #m can be arbitrary
		mac = finish(st)

Credits:
  This poly1305 Lua implementation is based on the cool
  poly1305-donna C 32-bit implementation (just try to figure
  out the h * r mod (2^130-5) computation!) by Andrew Moon,
  https://github.com/floodyberry/poly1305-donna

See also:
  - many chacha20 links at
    http://ianix.com/pub/chacha-deployment.html

]]

-----------------------------------------------------------
-- poly1305

local bit = require("bit")

local unpack32
if table.unpack then
	unpack32 = table.unpack
else
	unpack32 = unpack
end

local function unpack_u32_le(s, idx, n)
	idx = idx or 1
	n   = n or math.floor((#s - idx + 1)/4)
	local t = {}
	for i = 0,n-1 do
		local a,b,c,d = s:byte(idx+i*4, idx+i*4+3)
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

local function poly_init(k)
	local r = unpack_u32_le(k,1,8)
	local st = {
		r = {
			bit.band(r[1],0x3ffffff),
			bit.band(bit.rshift(r[2],2),0x3ffff03),
			bit.band(bit.rshift(r[3],4),0x3ffc0ff),
			bit.band(bit.rshift(r[4],6),0x3f03fff),
			bit.band(bit.rshift(r[5],8),0x00fffff),
		},
		h = {0,0,0,0,0},
		pad = {r[5],r[6],r[7],r[8]},
		buffer = "",
		leftover = 0,
		final = false,
	}
	return st
end

local function poly_blocks(st,m)
	local bytes = #m
	local midx  = 1
	local hibit = st.final and 0 or 0x01000000

	local r0,r1,r2,r3,r4 = unpack32(st.r)
	local s1,s2,s3,s4     = r1*5,r2*5,r3*5,r4*5
	local h0,h1,h2,h3,h4  = unpack32(st.h)
	local d0,d1,d2,d3,d4,c

	while bytes >= 16 do
		local u = unpack_u32_le(m,midx,4)
		h0 = h0 + bit.band(u[1],0x3ffffff)
		h1 = h1 + bit.band(bit.rshift(u[2],2),0x3ffffff)
		h2 = h2 + bit.band(bit.rshift(u[3],4),0x3ffffff)
		h3 = h3 + bit.band(bit.rshift(u[4],6),0x3ffffff)
		h4 = h4 + bit.bor(bit.rshift(u[4],8), hibit)

		d0 = h0*r0 + h1*s4 + h2*s3 + h3*s2 + h4*s1
		d1 = h0*r1 + h1*r0 + h2*s4 + h3*s3 + h4*s2
		d2 = h0*r2 + h1*r1 + h2*r0 + h3*s4 + h4*s3
		d3 = h0*r3 + h1*r2 + h2*r1 + h3*r0 + h4*s4
		d4 = h0*r4 + h1*r3 + h2*r2 + h3*r1 + h4*r0

		c  = math.floor(d0 / 2^26); h0 = d0 % 2^26
		d1 = d1 + c; c = math.floor(d1 / 2^26); h1 = d1 % 2^26
		d2 = d2 + c; c = math.floor(d2 / 2^26); h2 = d2 % 2^26
		d3 = d3 + c; c = math.floor(d3 / 2^26); h3 = d3 % 2^26
		d4 = d4 + c; c = math.floor(d4 / 2^26); h4 = d4 % 2^26
		h0 = h0 + c*5; c = math.floor(h0 / 2^26); h0 = h0 % 2^26
		h1 = h1 + c

		midx = midx + 16
		bytes = bytes - 16
	end

	st.h[1],st.h[2],st.h[3],st.h[4],st.h[5] = h0,h1,h2,h3,h4
	st.bytes,st.midx = bytes,midx
	return st
end

local function poly_update(st,m)
	st.bytes, st.midx = #m, 1
	if st.bytes >= 16 then poly_blocks(st,m) end
	if st.bytes > 0 then
		local buffer = string.sub(m,st.midx) .. "\x01" .. string.rep("\0",16-st.bytes-1)
		st.final = true
		poly_blocks(st,buffer)
	end
	return st
end

local function poly_finish(st)
	local h0,h1,h2,h3,h4 = unpack32(st.h)
	local c

	c  = math.floor(h1/2^26); h1 = h1 % 2^26
	h2 = h2 + c; c = math.floor(h2/2^26); h2 = h2 % 2^26
	h3 = h3 + c; c = math.floor(h3/2^26); h3 = h3 % 2^26
	h4 = h4 + c; c = math.floor(h4/2^26); h4 = h4 % 2^26
	h0 = h0 + c*5; c = math.floor(h0/2^26); h0 = h0 % 2^26
	h1 = h1 + c

	local g0 = h0+5; c = math.floor(g0/2^26); g0 = g0 % 2^26
	local g1 = h1+c; c = math.floor(g1/2^26); g1 = g1 % 2^26
	local g2 = h2+c; c = math.floor(g2/2^26); g2 = g2 % 2^26
	local g3 = h3+c; c = math.floor(g3/2^26); g3 = g3 % 2^26
	local g4 = h4+c-0x4000000

	local mask = bit.bnot(bit.rshift(g4,31))
	h0 = bit.bor(bit.band(h0,mask), g0)
	h1 = bit.bor(bit.band(h1,mask), g1)
	h2 = bit.bor(bit.band(h2,mask), g2)
	h3 = bit.bor(bit.band(h3,mask), g3)
	h4 = bit.bor(bit.band(h4,mask), g4)

	h0 = bit.band(h0 + bit.lshift(h1,26),0xffffffff)
	h1 = bit.band(bit.rshift(h1,6) + bit.lshift(h2,20),0xffffffff)
	h2 = bit.band(bit.rshift(h2,12) + bit.lshift(h3,14),0xffffffff)
	h3 = bit.band(bit.rshift(h3,18) + bit.lshift(h4,8),0xffffffff)

	local f
	f  = h0 + st.pad[1]; h0 = bit.band(f,0xffffffff)
	f  = h1 + st.pad[2] + math.floor(f/2^32); h1 = bit.band(f,0xffffffff)
	f  = h2 + st.pad[3] + math.floor(f/2^32); h2 = bit.band(f,0xffffffff)
	f  = h3 + st.pad[4] + math.floor(f/2^32); h3 = bit.band(f,0xffffffff)

	return pack_u32_le({h0,h1,h2,h3})
end

local function poly_auth(m,k)
	assert(#k==32)
	local st = poly_init(k)
	poly_update(st,m)
	return poly_finish(st)
end

local function poly_verify(m,k,mac)
	return poly_auth(m,k) == mac
end

return {
	init   = poly_init,
	update = poly_update,
	finish = poly_finish,
	auth   = poly_auth,
	verify = poly_verify,
	mac    = poly_auth
}