server:
	env $$(cat .env) bundle exec puma -C config/puma.rb

test:
	env $$(cat .env) bundle exec rspec spec

console:
	env $$(cat .env) bundle exec irb -r ./app