#!/bin/sh

go mod init build
go get github.com/geek1011/easy-novnc@v1.1.0
go build -o /bin/easy-novnc github.com/geek1011/easy-novnc