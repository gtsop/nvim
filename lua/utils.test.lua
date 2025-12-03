local assert = require("luassert")

local utils = require("utils")

describe("Utils", function()
  it("subsequence_score works", function()
    assert.equal(nil, string.find("", "a", 1, false))
    assert.equal(1, string.find("a", "a", 1, false))
    assert.equal(2, string.find("_a", "a", 1, false))
    --[[assert.is_same(
      { is_subsequence = true, matches = { 4, 6 }, score = -5 },
      utils.subsequence_score("oooaooa", "aa", false)
    )]]
    assert.is_same({ is_subsequence = true, matches = {}, score = 0 }, utils.subsequence_score("", "", false))
    assert.is_same({ is_subsequence = true, matches = {}, score = -1 }, utils.subsequence_score("a", "", false))
    assert.is_same({ is_subsequence = false, matches = {}, score = 0 }, utils.subsequence_score("a", "b", false))
    assert.is_same({ is_subsequence = true, matches = { 1 }, score = 0 }, utils.subsequence_score("a", "a", false))
    assert.is_same({ is_subsequence = true, matches = { 2 }, score = -1 }, utils.subsequence_score("_a", "a", false))
    assert.is_same({ is_subsequence = true, matches = { 3 }, score = -2 }, utils.subsequence_score("__a", "a", false))
    assert.is_same({ is_subsequence = true, matches = { 2 }, score = -2 }, utils.subsequence_score("_a_", "a", false))
    assert.is_same({ is_subsequence = true, matches = { 3 }, score = -3 }, utils.subsequence_score("__a_", "a", false))
    assert.is_same(
      { is_subsequence = true, matches = { 2, 3 }, score = -1 },
      utils.subsequence_score("_ab", "ab", false)
    )

    --[[assert.is_same(
      { is_subsequence = true, matches = { 5, 6, 7 }, score = -5 },
      utils.subsequence_score("init.lua", "lua", false)
    )]]
  end)
end)
