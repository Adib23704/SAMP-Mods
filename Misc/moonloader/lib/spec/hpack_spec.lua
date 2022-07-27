describe("Correctly implements all examples in spec.", function()
	local hpack = require "http.hpack"
	local new_headers = require "http.headers".new

	local function xxd_escape(s)
		return (s
			:gsub(".", function(c) return string.format("%02x", c:byte(1,1)) end)
			:gsub("....", "%0 ")
			:gsub(" $", "")
			:gsub("(.......................................) ", "%1\n")
		)
	end
	local function xxd_unescape(s)
		return (s
			:gsub("[^%x]+", "")
			:gsub("%x%x", function(c) return string.char(tonumber(c, 16)) end)
		)
	end

	it("Example C.1.1", function()
		assert.same("0a", xxd_escape(hpack.encode_integer(10, 5, 0)))
		assert.same(10, (hpack.decode_integer(xxd_unescape("0a"), 5)))
	end)

	it("Example C.1.2", function()
		assert.same("1f9a 0a", xxd_escape(hpack.encode_integer(1337, 5, 0)))
		assert.same(1337, (hpack.decode_integer(xxd_unescape("1f9a 0a"), 5)))
	end)

	it("Example C.1.3", function()
		assert.same("2a", xxd_escape(hpack.encode_integer(42, 8, 0)))
		assert.same(42, (hpack.decode_integer(xxd_unescape("2a"), 8)))
	end)

	it("Example C.2.1", function()
		local encoded = hpack.encode_literal_header_indexed_new("custom-key", "custom-header")
		assert.same("@\10custom-key\13custom-header", encoded)
		local h = new_headers()
		h:append("custom-key", "custom-header", false)
		assert.same(h, hpack.new():decode_headers(encoded))
	end)

	it("Example C.2.2", function()
		local encoded = hpack.encode_literal_header_none(4, "/sample/path")
		assert.same("\04\12/sample/path", encoded)
		local h = new_headers()
		h:append(":path", "/sample/path", false)
		assert.same(h, hpack.new():decode_headers(encoded))
	end)

	it("Example C.2.3", function()
		local encoded = hpack.encode_literal_header_never_new("password", "secret")
		assert.same("\16\8password\6secret", encoded)
		local h = new_headers()
		h:append("password", "secret", true)
		assert.same(h, hpack.new():decode_headers(encoded))
	end)

	it("Example C.2.4", function()
		local encoded = hpack.encode_indexed_header(2)
		assert.same("\130", encoded)
		local h = new_headers()
		h:append(":method", "GET", false)
		assert.same(h, hpack.new():decode_headers(encoded))
	end)

	local function check_request(enc_ctx, dec_ctx, headers, dyn_table, xxd_req)
		for _, v in ipairs(headers) do
			enc_ctx:add_header_indexed(v[1], v[2], v[3])
		end
		assert.same(dyn_table, enc_ctx:dynamic_table_tostring())
		local raw = enc_ctx:render_data()
		assert.same(xxd_req, xxd_escape(raw))
		enc_ctx:clear_data()

		local decoded = dec_ctx:decode_headers(raw)
		assert.same(dyn_table, dec_ctx:dynamic_table_tostring())
		for i, input in ipairs(headers) do
			local name, val = decoded:geti(i)
			assert.same(input[1], name)
			assert.same(input[2], val)
		end
	end
	it("Example C.3", function()
		local enc_ctx = hpack.new(math.huge)
		local dec_ctx = hpack.new(math.huge)

		-- C.3.1
		check_request(enc_ctx, dec_ctx, {
			{ ":method", "GET", false };
			{ ":scheme", "http", false };
			{ ":path", "/", false };
			{ ":authority", "www.example.com", false };
		}, [[
[  1] (s =  57) :authority: www.example.com
      Table size:  57]], [[
8286 8441 0f77 7777 2e65 7861 6d70 6c65
2e63 6f6d]])

		-- C.3.2
		check_request(enc_ctx, dec_ctx, {
			{ ":method", "GET", false };
			{ ":scheme", "http", false };
			{ ":path", "/", false };
			{ ":authority", "www.example.com", false };
			{ "cache-control", "no-cache", false };
		}, [[
[  1] (s =  53) cache-control: no-cache
[  2] (s =  57) :authority: www.example.com
      Table size: 110]], [[
8286 84be 5808 6e6f 2d63 6163 6865]])

		-- C.3.3
		check_request(enc_ctx, dec_ctx, {
			{ ":method", "GET", false };
			{ ":scheme", "https", false };
			{ ":path", "/index.html", false };
			{ ":authority", "www.example.com", false };
			{ "custom-key", "custom-value", false };
		}, [[
[  1] (s =  54) custom-key: custom-value
[  2] (s =  53) cache-control: no-cache
[  3] (s =  57) :authority: www.example.com
      Table size: 164]], [[
8287 85bf 400a 6375 7374 6f6d 2d6b 6579
0c63 7573 746f 6d2d 7661 6c75 65]])
	end)

	it("Example C.4 #huffman", function()
		local enc_ctx = hpack.new(math.huge)
		local dec_ctx = hpack.new(math.huge)

		-- C.4.1
		check_request(enc_ctx, dec_ctx, {
			{ ":method", "GET", true };
			{ ":scheme", "http", true };
			{ ":path", "/", true };
			{ ":authority", "www.example.com", true };
		}, [[
[  1] (s =  57) :authority: www.example.com
      Table size:  57]], [[
8286 8441 8cf1 e3c2 e5f2 3a6b a0ab 90f4
ff]])

		-- C.4.2
		check_request(enc_ctx, dec_ctx, {
			{ ":method", "GET", true };
			{ ":scheme", "http", true };
			{ ":path", "/", true };
			{ ":authority", "www.example.com", true };
			{ "cache-control", "no-cache", true };
		}, [[
[  1] (s =  53) cache-control: no-cache
[  2] (s =  57) :authority: www.example.com
      Table size: 110]], [[
8286 84be 5886 a8eb 1064 9cbf]])

		-- C.4.3
		check_request(enc_ctx, dec_ctx, {
			{ ":method", "GET", true };
			{ ":scheme", "https", true };
			{ ":path", "/index.html", true };
			{ ":authority", "www.example.com", true };
			{ "custom-key", "custom-value", true };
		}, [[
[  1] (s =  54) custom-key: custom-value
[  2] (s =  53) cache-control: no-cache
[  3] (s =  57) :authority: www.example.com
      Table size: 164]], [[
8287 85bf 4088 25a8 49e9 5ba9 7d7f 8925
a849 e95b b8e8 b4bf]])
	end)

	it("Example C.5", function()
		local enc_ctx = hpack.new(256)
		local dec_ctx = hpack.new(256)

		-- C.5.1
		check_request(enc_ctx, dec_ctx, {
			{ ":status", "302", false };
			{ "cache-control", "private", false };
			{ "date", "Mon, 21 Oct 2013 20:13:21 GMT", false };
			{ "location", "https://www.example.com", false };
		}, [[
[  1] (s =  63) location: https://www.example.com
[  2] (s =  65) date: Mon, 21 Oct 2013 20:13:21 GMT
[  3] (s =  52) cache-control: private
[  4] (s =  42) :status: 302
      Table size: 222]], [[
4803 3330 3258 0770 7269 7661 7465 611d
4d6f 6e2c 2032 3120 4f63 7420 3230 3133
2032 303a 3133 3a32 3120 474d 546e 1768
7474 7073 3a2f 2f77 7777 2e65 7861 6d70
6c65 2e63 6f6d]])

		-- C.5.2
		check_request(enc_ctx, dec_ctx, {
			{ ":status", "307", false };
			{ "cache-control", "private", false };
			{ "date", "Mon, 21 Oct 2013 20:13:21 GMT", false };
			{ "location", "https://www.example.com", false };
		}, [[
[  1] (s =  42) :status: 307
[  2] (s =  63) location: https://www.example.com
[  3] (s =  65) date: Mon, 21 Oct 2013 20:13:21 GMT
[  4] (s =  52) cache-control: private
      Table size: 222]], [[
4803 3330 37c1 c0bf]])

		-- C.5.3
		check_request(enc_ctx, dec_ctx, {
			{ ":status", "200", false };
			{ "cache-control", "private", false };
			{ "date", "Mon, 21 Oct 2013 20:13:22 GMT", false };
			{ "location", "https://www.example.com", false };
			{ "content-encoding", "gzip", false };
			{ "set-cookie", "foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1", false };
		}, [[
[  1] (s =  98) set-cookie: foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age\
                 =3600; version=1
[  2] (s =  52) content-encoding: gzip
[  3] (s =  65) date: Mon, 21 Oct 2013 20:13:22 GMT
      Table size: 215]], [[
88c1 611d 4d6f 6e2c 2032 3120 4f63 7420
3230 3133 2032 303a 3133 3a32 3220 474d
54c0 5a04 677a 6970 7738 666f 6f3d 4153
444a 4b48 514b 425a 584f 5157 454f 5049
5541 5851 5745 4f49 553b 206d 6178 2d61
6765 3d33 3630 303b 2076 6572 7369 6f6e
3d31]])
	end)

	it("Example C.6 #huffman", function()
		local enc_ctx = hpack.new(256)
		local dec_ctx = hpack.new(256)

		-- C.6.1
		check_request(enc_ctx, dec_ctx, {
			{ ":status", "302", true };
			{ "cache-control", "private", true };
			{ "date", "Mon, 21 Oct 2013 20:13:21 GMT", true };
			{ "location", "https://www.example.com", true };
		}, [[
[  1] (s =  63) location: https://www.example.com
[  2] (s =  65) date: Mon, 21 Oct 2013 20:13:21 GMT
[  3] (s =  52) cache-control: private
[  4] (s =  42) :status: 302
      Table size: 222]], [[
4882 6402 5885 aec3 771a 4b61 96d0 7abe
9410 54d4 44a8 2005 9504 0b81 66e0 82a6
2d1b ff6e 919d 29ad 1718 63c7 8f0b 97c8
e9ae 82ae 43d3]])

		-- C.6.2
		check_request(enc_ctx, dec_ctx, {
			{ ":status", "307", true };
			{ "cache-control", "private", true };
			{ "date", "Mon, 21 Oct 2013 20:13:21 GMT", true };
			{ "location", "https://www.example.com", true };
		}, [[
[  1] (s =  42) :status: 307
[  2] (s =  63) location: https://www.example.com
[  3] (s =  65) date: Mon, 21 Oct 2013 20:13:21 GMT
[  4] (s =  52) cache-control: private
      Table size: 222]], [[
4883 640e ffc1 c0bf]])

		-- C.6.3
		check_request(enc_ctx, dec_ctx, {
			{ ":status", "200", true };
			{ "cache-control", "private", true };
			{ "date", "Mon, 21 Oct 2013 20:13:22 GMT", true };
			{ "location", "https://www.example.com", true };
			{ "content-encoding", "gzip", true };
			{ "set-cookie", "foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1", true };
		}, [[
[  1] (s =  98) set-cookie: foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age\
                 =3600; version=1
[  2] (s =  52) content-encoding: gzip
[  3] (s =  65) date: Mon, 21 Oct 2013 20:13:22 GMT
      Table size: 215]], [[
88c1 6196 d07a be94 1054 d444 a820 0595
040b 8166 e084 a62d 1bff c05a 839b d9ab
77ad 94e7 821d d7f2 e6c7 b335 dfdf cd5b
3960 d5af 2708 7f36 72c1 ab27 0fb5 291f
9587 3160 65c0 03ed 4ee5 b106 3d50 07]])
	end)
end)

describe("Partial input is returned with correct offset", function()
	local hpack = require "http.hpack"
	it("decodes integers without errors", function()
		-- Empty string should return nil
		assert.is._nil(hpack.decode_integer("", 7, 1))

		-- Encode a large number and trim off last character
		local s = hpack.encode_integer(2^20, 7, 0)
		s = s:sub(1, -2)
		assert.is._nil(hpack.decode_integer(s, 7, 1))
	end)
	it("decodes strings without errors", function()
		-- Empty string should return nil
		assert.is._nil(hpack.decode_string(""))

		-- Encode a large string and trim off last character
		local s1 = hpack.encode_string("this is a test", false)
		s1 = s1:sub(1, -2)
		assert.is._nil(hpack.decode_string(s1))
		-- with huffman
		local s2 = hpack.encode_string("this is a test", true)
		s2 = s2:sub(1, -2)
		assert.is._nil(hpack.decode_string(s2))
	end)
	it("decodes partial headers without errors", function()
		local h = hpack.new()
		-- empty string should do nothing
		assert.same(1, select(2, h:decode_headers("")))

		-- trim off last character
		local s1 do
			local e = hpack.new()
			e:add_header_indexed("foo", "bar")
			s1 = e:render_data()
		end
		assert.same(1, select(2, h:decode_headers(s1:sub(1, -2))))

		-- try again but this time with two headers
		local s2 do
			local e = hpack.new()
			e:add_header_indexed("foo", "bar")
			e:add_header_indexed("baz", "qux")
			s2 = e:render_data()
		end
		assert.same(#s1+1, select(2, h:decode_headers(s2:sub(1, -2))))
	end)
end)
