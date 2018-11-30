# iQvoc

For more info on iQvoc, visit https://github.com/innoq/iqvoc

## Cloud Foundry ##

Execute these steps:

```gem install bundler```
```bundle install --without development test```
```bundle exec rake db:migrate && bundle exec rake db:seed && bundle exec rake assets:precompile```
```cf push```

