server:
	env $$(cat .env) bundle exec puma -C config/puma.rb

dev-server:
	env $$(cat .env.development) bundle exec puma -C config/puma.rb

test:
	env $$(cat .env) bundle exec rspec spec

console:
	@if [ $(env) = "production" ]; then\
		env $$(cat .env) bundle exec irb -r ./app;\
	else\
		env $$(cat .env.$(env)) bundle exec irb -r ./app;\
	fi
	