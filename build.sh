#!/bin/bash

FILE=gsvc
if [ -f $FILE ]; then
   echo "
        ------------------------------------------------------
        -- Building update.
        ------------------------------------------------------
   "
else
   echo "

        ------------------------------------------------------
        -- README FIRST TO GET IT WORKING
        ------------------------------------------------------

        Install protobuf compiler...

        $ sudo apt-get install autoconf automake libtool curl make g++ unzip #!!! THIS will work on debian/ubuntu
        $ git clone https://github.com/google/protobuf
        $ cd protobuf
        $ ./autogen.sh
        $ ./configure
        $ make
        $ make check
        $ sudo make install
        $ sudo ldconfig 

        Install the protoc Go plugin

        $ go get -u github.com/golang/protobuf/protoc-gen-go

        Rebuild the generated Go code

        $ protoc -I helloworld/ helloworld/helloworld.proto --go_out=plugins=grpc:helloworld

    "
fi


#Generate certificates for gRPC
#Common Name (e.g. server FQDN or YOUR name) []:backend.local
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./backend.key -out ./backend.cert -subj "/C=US/ST=San Francisco/L=San Francisco/O=SFPL/OU=IT Department/CN=backend.local"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./frontend.key -out ./frontend.cert -subj "/C=US/ST=San Francisco/L=San Francisco/O=SFPL/OU=IT Department/CN=frontend.local"

#go generate github.com/dioptre/gtrpc/proto
protoc -I proto/ proto/helloworld.proto --go_out=plugins=grpc:proto/

#Build client & server
go build -o gsvc -tags netgo service/service.go
go build -o gcli -tags netgo client/client.go
./gsvc # & ./gcli

#Not used
#go get -u github.com/celrenheit/sandglass-client/go/sg
