local say    = require "say"
local assert = require "luassert"

-- is function
local function is_function(_, args)
  return type(args[1]) == "function"
end

say:set("assertion.is_func.positive", "Expected %s to be a function")
say:set("assertion.is_func.negative", "Expected %s not to be a function")

assert:register("assertion", "is_func", is_function,
                "assertion.is_func.positive",
                "assertion.is_func.negative")
assert:register("matcher",   "func",   is_function)
