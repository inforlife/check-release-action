source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "octokit", "~> 10.0"
gem "faraday-retry", "~> 2.3"

group :test do
  gem "rspec", "~> 3.13"
  gem "vcr", "~> 6.3"
  gem "webmock", "~> 3.25"
end
