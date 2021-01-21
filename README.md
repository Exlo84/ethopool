## Open Source ether-1 Mining Pool

![Miner's stats page](http://data.ethofs.com/ipfs/QmWabuC2L7NQ1AgyG6KX7p3AXcaZ9pdzVyioNArAqeJ9r4/pool%20front%20chart.jpg)
![Miner's stats page](http://data.ethofs.com/ipfs/QmWabuC2L7NQ1AgyG6KX7p3AXcaZ9pdzVyioNArAqeJ9r4/pool%20miner%20chart.jpg)


### Features

**This pool is being further developed to provide an easy to use pool for Ethereum miners. This software is functional however an optimised release of the pool is expected soon. Testing and bug submissions are welcome!**

* Support for HTTP and Stratum mining
* Detailed block stats with luck percentage and full reward
* Failover geth instances: geth high availability built in
* Modern beautiful Ember.js frontend
* Separate stats for workers: can highlight timed-out workers so miners can perform maintenance of rigs
* JSON-API for stats

### Building on Linux

Dependencies:

  * go >= 1.9
  * geth or parity
  * redis-server >= 2.8.0
  * nodejs >= 4 LTS
  * nginx

First of all let's get up to date and install the dependencies:

    sudo apt-get update && sudo apt-get dist-upgrade -y
    sudo apt-get install build-essential make git screen curl nginx tcl -y

Install GO:

    wget https://storage.googleapis.com/golang/go1.13.5.linux-amd64.tar.gz
    tar -xvf go1.13.5.linux-amd64.tar.gz
    rm go1.13.5.linux-amd64.tar.gz
    sudo mv go /usr/local
    export GOROOT=/usr/local/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
    
    sudo nano ~/.profile
    
    #add this in the end and save
    export PATH=$PATH:/usr/local/go/bin
    
    source ~/.profile
    go version


Clone & compile:

    git config --global http.https://gopkg.in.followRedirects true
    git clone https://github.com/Exlo84/ether1pool.git
    cd ether1pool
    make

Installing Redis latest version

    curl -O http://download.redis.io/redis-stable.tar.gz
    tar xzvf redis-stable.tar.gz
    cd redis-stable
    make
    make test 
    sudo make install
    
    sudo mkdir /etc/redis
    sudo cp ~/redis-stable/redis.conf /etc/redis
    sudo nano /etc/redis/redis.conf
        
    # Set supervised to systemd
      supervised systemd
    # Set the dir
      dir /var/lib/redis
            
        
**Create a Redis systemd Unit File

    sudo nano /etc/systemd/system/redis.service

Add

    [Unit]
    Description=Redis In-Memory Data Store
    After=network.target

    [Service]
    User=redis
    Group=redis
    ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
    ExecStop=/usr/local/bin/redis-cli shutdown
    Restart=always

    [Install]
    WantedBy=multi-user.target
    
**Create the Redis User, Group and Directories

    sudo adduser --system --group --no-create-home redis
    sudo mkdir /var/lib/redis
    sudo chown redis:redis /var/lib/redis
    sudo chmod 770 /var/lib/redis
    
### Start and Test Redis

    sudo systemctl start redis
    sudo systemctl status redis

### Install Node.js

    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install nodejs -y

### Install Geth

    cd ~
    wget -N https://github.com/Ether1Project/Ether1/releases/download/1.4.2/ether-1-linux-1.4.2.tar.gz
    tar xfvz ether-1-linux-1.4.2.tar.gz
    rm ether-1-linux-1.4.2.tar.gz
    sudo mv geth /usr/local/bin/geth 

Make geth system service

    sudo nano /etc/systemd/system/geth.service
    
Copy the following

    [Unit]
    Description=Geth for Pool
    After=network-online.target
    
    [Service]
    ExecStart=/usr/local/bin/geth --rpc --allow-insecure-unlock --rpcaddr 127.0.0.1 --rpcport 8545 --syncmode "fast" --etherbase <your-address> --mine --extradata "<your-pool>"
    User=<your-user-name>
    
    [Install]
    WantedBy=multi-user.target

Then run geth by the following commands

    sudo systemctl enable geth
    sudo systemctl start geth
    sudo systemctl status geth

Run console

    geth attach

Register pool account and open wallet for transaction. This process is always required, when the wallet node is restarted.

    personal.newAccount()
    personal.unlockAccount(eth.accounts[0],"password",40000000)

### Set up pool

    mv config.example.json config.json
    nano config.json

Make pool system service

    sudo nano /etc/systemd/system/pool.service

Copy the following

    [Unit]
    Description=Ethopool
    After=geth.target
    
    [Service]
    ExecStart=/home/<name>/ether1pool/build/bin/open-ethereum-pool /home/<name>/ether1pool/config.json
    
    [Install]
    WantedBy=multi-user.target

Then run pool by the following commands

    sudo systemctl enable pool
    sudo systemctl start pool
    sudo systemctl status pool

### Building Frontend

    cd www

Modify your configuration file

    nano ~/ether1pool/www/config/environment.js

Create frontend

    cd ~/ether1pool/www/
    
    sudo npm install -g ember-cli@^2.18.2
    sudo npm install -g bower
    sudo chown -R $USER:$GROUP ~/.npm
    sudo chown -R $USER:$GROUP ~/.config
    npm install
    bower install
    npm i intl-format-cache
    
    ./build.sh


Configure nginx to serve API on <code>/api</code> subdirectory.
Configure nginx to serve <code>www/dist</code> as static website.

#### Serving API using nginx

Edit this

    sudo nano /etc/nginx/sites-available/default

Delete everything in the file and replace it with the text below.
Be sure to change with your info

    upstream api {
            server 127.0.0.1:8080;
    }
    
    server {
      listen 80 default_server;
      listen [::]:80 default_server;
      root /home/<name>/ether1pool/www/dist;
     
     index index.html index.htm index.nginx-debian.html;
     
    server_name _;
     
    location / {
            try_files $uri $uri/ =404;
            }
      
    location /api {
            proxy_pass http://api;
            }
    }
    
Save and close

Restart nginx

    sudo service nginx restart

### How To Secure the pool frontend with Let's Encrypt (https)

First, install the Certbot's Nginx package with apt-get


    $ sudo add-apt-repository ppa:certbot/certbot
    $ sudo apt-get update
    $ sudo apt-get install python-certbot-nginx
And then open your nginx setting file, make sure the server name is configured!

    $ sudo nano /etc/nginx/sites-available/default
    . . .
    server_name <your-pool-domain>;
    . . .

Change the _ to your pool domain, and now you can obtain your auto-renewaled ssl certificate for free!

    $ sudo certbot --nginx -d <your-pool-domain>

Now you can access your pool's frontend via https!

### Notes

* Unlocking and payouts are sequential, 1st tx go, 2nd waiting for 1st to confirm and so on. You can disable that in code. Carefully read `docs/PAYOUTS.md`.
* Also, keep in mind that **unlocking and payouts will halt in case of backend or node RPC errors**. In that case check everything and restart.
* You must restart module if you see errors with the word *suspended*.
* Don't run payouts and unlocker modules as part of mining node. Create separate configs for both, launch independently and make sure you have a single instance of each module running.
* If `poolFeeAddress` is not specified all pool profit will remain on coinbase address. If it specified, make sure to periodically send some dust back required for payments.

### Credits

Made by sammy007. Licensed under GPLv3.

#### Contributors

[Alex Leverington](https://github.com/subtly)