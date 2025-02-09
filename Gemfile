# Source for RubyGems
source "https://rubygems.org"

# Authentication & Security
gem "bcrypt", "~> 3.1.7"

# Rails Framework
gem "rails", "~> 8.0.1"

# Database (PostgreSQL)
gem "pg"

# Web Server
gem "puma", ">= 5.0"

# Timezone support for Windows
gem "tzinfo-data", platforms: %i[windows jruby]

# Caching & Queueing
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Performance Optimizations
gem "bootsnap", require: false

# Docker Deployment
gem "kamal", require: false

# HTTP Caching
gem "thruster", require: false

# Environment Variables
gem "dotenv-rails", groups: [:development, :test]

# ✅ OpenAI API Integration
gem "ruby-openai", "~> 7.1.0"

# Rails Preloader
#gem "spring", group: :development
#
gem 'rack-cors'

# Development & Testing Tools
group :development, :test do
  # Debugging
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Security Analysis
  gem "brakeman", require: false

  # Ruby Code Style Linting
  gem "rubocop-rails-omakase", require: false
end
