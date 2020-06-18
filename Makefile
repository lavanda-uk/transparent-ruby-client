install:
	gem install bundler
	bundle

build:
	gem build transparent_ruby_client

check: sorbet-check lint test
	@echo 'Checked!'

sorbet-check:
	bundle exec srb tc

test:
	bundle exec rspec

lint:
	bundle exec rubocop

lint-changes:
	git ls-files -m -o --exclude-standard | xargs bundle exec rubocop

fixlint:
	git diff --name-only --cached --diff-filter=d | xargs bundle exec rubocop -a
