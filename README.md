# Shopbeam Order Manager

Web service that places orders coming from [Spock](https://github.com/shopbeam/spock/) app on partner sites.
Built on the following technology stack:

* [Ruby 2.2.2][1]
* [Rails 4.2.3][2]
* [PostgreSQL][3]
* [Nginx][4]
* [Puma][5]
* [Sidekiq][6]
* [RSpec][7]

[1]: http://www.ruby-lang.org/en/
[2]: http://rubyonrails.org/
[3]: http://www.postgresql.org/
[4]: http://nginx.org/
[5]: http://puma.io/
[6]: http://sidekiq.org/
[7]: http://rspec.info/

## Supported partners

* [Well.ca][1]
* [Lacoste US][2]

[1]: https://well.ca/
[2]: https://www.lacoste.com/us/

## Installation

1. **Essential packages**

    ```
    $ sudo apt-get update
    $ sudo apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev libpq-dev libsqlite3-dev libnss3 libgconf-2-4 xvfb unzip
    ```

2. **PostgreSQL**

    ```
    $ sudo apt-get install -y postgresql
    ```

3. **Redis**

    ```
    $ sudo apt-get install -y redis-server
    ```

4. **WebDriver for Chrome**

    For Linux (Ubuntu x64):
    ```
    $ wget -N http://chromedriver.storage.googleapis.com/2.19/chromedriver_linux64.zip -P ~/Downloads
    $ unzip ~/Downloads/chromedriver_linux64.zip -d ~/Downloads
    $ chmod +x ~/Downloads/chromedriver
    $ sudo mv -f ~/Downloads/chromedriver /usr/local/share/chromedriver
    $ sudo ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
    $ sudo ln -s /usr/local/share/chromedriver /usr/bin/chromedriver
    ```

## Usage

    $ curl -X POST http://localhost:3000/orders/:id/fill

## Monitoring

####Sidekiq Web UI:

Navigate to [http://localhost:3000/admin/monitor/](http://localhost:3000/admin/monitor/).

####MailCatcher:

    $ mailcatcher

and navigate to [http://localhost:1080/](http://localhost:1080/).

## Partners integration tests
located in "features" directory
To run tests against specific partner:
`rake cucumber:partners:lacoste`
or
`rake cucumber:partners:well_ca`
Please use mentioned rake tasks instead of just `cucumber`, as rake task loads specific steps definitions.

There is cronjob which runs all partners tests, by calling every 4 hours following task:
`rake cucumber:partners`
