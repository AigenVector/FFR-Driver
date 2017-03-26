# Driver
This program attempts to drive the Raspberry Pi by exposing 
RESTful HTTP endpoints for manipulating the GPIO pins.

## Getting Started
1. Install [RVM](http://rvm.io)
1. Install Ruby 2.4.0
    ```
    $ rvm install ruby-2.4.0
    ```
1. Install ``bundler``
    ```
    $ gem install bundler
    ```
1. Install dependencies
    ```
    $ bundle install
    ```
1. Fire it up!
    ```
    $ rvmsudo ./driver.rb
    ```
1. Get the IP address of the Pi
    ```
    ip addr
    ```
1. Visit endpoints from other devices on the same network
    ```
    # Example
    $ wget 192.168.1.14:4567/on
    $ wget 192.168.1.14:4567/off
    $ wget 192.168.1.14:4567/
    ```
