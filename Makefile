build:
	gem build transparent_ruby_client

lint-changes:
	git ls-files -m -o --exclude-standard | xargs bundle exec rubocop

fixlint:
	git diff --name-only --cached --diff-filter=d | xargs bundle exec rubocop -a
