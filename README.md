# LDR to Pocket

    $ export LIVEDOOR_ID=XXXX
    $ export LIVEDOOR_PASSWORD=XXXX
    $ export CONSUMER_KEY=XXXX
    $ export ACCESS_TOKEN=XXXX
    $ bundle install
    $ bundle exec ruby ldr2pocket.rb

# Heroku Scheduler

    $ heroku apps:create ldr2pocket
    $ git push heroku master
    $ heroku addons:add scheduler:standard
    $ heroku config:set LIVEDOOR_ID=XXXX
    $ heroku config:set LIVEDOOR_PASSWORD=XXXX
    $ heroku config:set CONSUMER_KEY=XXXX
    $ heroku config:set ACCESS_TOKEN=XXXX
    
    $ bundle exec ruby ldr2pocket.rb

LDR mechanize code is from https://gist.github.com/yoggy/775768.
