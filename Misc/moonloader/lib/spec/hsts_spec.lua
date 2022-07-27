describe("hsts module", function()
	local http_hsts = require "http.hsts"
	it("doesn't store ip addresses", function()
		local s = http_hsts.new_store()
		assert.falsy(s:store("127.0.0.1", {
			["max-age"] = "100";
		}))
		assert.falsy(s:check("127.0.0.1"))
	end)
	it("can be cloned", function()
		local s = http_hsts.new_store()
		do
			local clone = s:clone()
			local old_heap = s.expiry_heap
			s.expiry_heap = nil
			clone.expiry_heap = nil
			assert.same(s, clone)
			s.expiry_heap = old_heap
		end
		assert.truthy(s:store("foo.example.com", {
			["max-age"] = "100";
		}))
		do
			local clone = s:clone()
			local old_heap = s.expiry_heap
			s.expiry_heap = nil
			clone.expiry_heap = nil
			assert.same(s, clone)
			s.expiry_heap = old_heap
		end
		local clone = s:clone()
		assert.truthy(s:check("foo.example.com"))
		assert.truthy(clone:check("foo.example.com"))
	end)
	it("rejects :store() when max-age directive is missing", function()
		local s = http_hsts.new_store()
		assert.falsy(s:store("foo.example.com", {}))
		assert.falsy(s:check("foo.example.com"))
	end)
	it("rejects :store() when max-age directive is invalid", function()
		local s = http_hsts.new_store()
		assert.falsy(s:store("foo.example.com", {
			["max-age"] = "-1";
		}))
		assert.falsy(s:check("foo.example.com"))
	end)
	it("erases on max-age == 0", function()
		local s = http_hsts.new_store()
		assert.truthy(s:store("foo.example.com", {
			["max-age"] = "100";
		}))
		assert.truthy(s:check("foo.example.com"))
		assert.truthy(s:store("foo.example.com", {
			["max-age"] = "0";
		}))
		assert.falsy(s:check("foo.example.com"))
	end)
	it("respects includeSubdomains", function()
		local s = http_hsts.new_store()
		assert(s:store("foo.example.com", {
			["max-age"] = "100";
			includeSubdomains = true;
		}))
		assert.truthy(s:check("foo.example.com"))
		assert.truthy(s:check("qaz.bar.foo.example.com"))
		assert.falsy(s:check("example.com"))
		assert.falsy(s:check("other.com"))
	end)
	it("removes expired entries on :clean()", function()
		local s = http_hsts.new_store()
		assert(s:store("foo.example.com", {
			["max-age"] = "100";
		}))
		assert(s:store("other.com", {
			["max-age"] = "200";
		}))
		assert(s:store("keep.me", {
			["max-age"] = "100000";
		}))
		-- Set clock forward
		local now = s.time()
		s.time = function() return now+1000 end
		assert.truthy(s:clean())
		assert.falsy(s:check("qaz.bar.foo.example.com"))
		assert.falsy(s:check("foo.example.com"))
		assert.falsy(s:check("example.com"))
		assert.truthy(s:check("keep.me"))
	end)
	it("cleans out expired entries automatically", function()
		local s = http_hsts.new_store()
		assert(s:store("foo.example.com", {
			["max-age"] = "100";
		}))
		assert(s:store("other.com", {
			["max-age"] = "200";
		}))
		assert(s:store("keep.me", {
			["max-age"] = "100000";
		}))
		-- Set clock forward
		local now = s.time()
		s.time = function() return now+1000 end
		assert.falsy(s:check("qaz.bar.foo.example.com"))
		-- Set clock back to current; everything should have been cleaned out already.
		s.time = function() return now end
		assert.falsy(s:check("foo.example.com"))
		assert.falsy(s:check("example.com"))
		assert.truthy(s:check("keep.me"))
	end)
	it("enforces .max_items", function()
		local s = http_hsts.new_store()
		s.max_items = 0
		assert.falsy(s:store("example.com", {
			["max-age"] = "100";
		}))
		s.max_items = 1
		assert.truthy(s:store("example.com", {
			["max-age"] = "100";
		}))
		assert.falsy(s:store("other.com", {
			["max-age"] = "100";
		}))
		s:remove("example.com", "/", "foo")
		assert.truthy(s:store("other.com", {
			["max-age"] = "100";
		}))
	end)
end)
