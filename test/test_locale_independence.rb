# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "rbconfig"

# Regression: the gem must load when the host default encoding is US-ASCII (Vercel, bare Docker),
# i.e. every file read declares its own encoding instead of trusting Encoding.default_external.
class LocaleIndependenceTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_gem_loads_under_us_ascii_default_encoding
    code = 'Encoding.default_external = Encoding::US_ASCII; require "jekyll-theme-resume"'
    out, status = Open3.capture2e(RbConfig.ruby, "-I#{ROOT}/lib", "-e", code)
    assert status.success?, out
  end
end
