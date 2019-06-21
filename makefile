server:
	env $$(cat .env) bundle exec puma -C config/puma.rb

dev-server:
	env $$(cat .env.development) bundle exec puma -C config/puma.rb

test:
	env $$(cat .env) bundle exec rspec spec

console:
	make console-env env=development

console-env:
	@if [ $(env) = "production" ]; then\
		env $$(cat .env) bundle exec irb -r ./app;\
	else\
		env $$(cat .env.$(env)) bundle exec irb -r ./app;\
	fi

qsubscribers:
	env $$(cat .env.development) ./bin/queue_subscribers

batchprocess-start:
	env $$(cat .env.development) ./bin/batch_process_top_10

publish-tracks:
    env $$(cat .env) bundle exec bin/fake_tracks_publisher.rb