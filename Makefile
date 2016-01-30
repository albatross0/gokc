BIN := gokc

all: build

yacc: deps
	go tool yacc -o parser/parser.go -v parser/parser.output parser/parser.go.y

build: yacc
	go build -o $(BIN) ./cmd

buildlinux: yacc
	GOOS=linux GOARCH=amd64 make build

test: build
	find ./testdata -type f | xargs -I{} ./$(BIN) -f {}
	find ./keepalived/doc/samples/keepalived.conf.* -type f | xargs -I{} ./$(BIN) -f {}

cross: deps
	goxc -tasks='xc archive' -bc 'linux,!arm windows darwin' -d .
	cp -p $(PWD)/snapshot/linux_amd64/gokc $(PWD)/snapshot/gokc_linux_amd64
	cp -p $(PWD)/snapshot/linux_386/gokc $(PWD)/snapshot/gokc_linux_386
	cp -p $(PWD)/snapshot/darwin_amd64/gokc $(PWD)/snapshot/gokc_darwin_amd64
	cp -p $(PWD)/snapshot/darwin_386/gokc $(PWD)/snapshot/gokc_darwin_386
	cp -p $(PWD)/snapshot/windows_amd64/gokc.exe $(PWD)/snapshot/gokc_windows_amd64.exe
	cp -p $(PWD)/snapshot/windows_386/gokc.exe $(PWD)/snapshot/gokc_windows_386.exe

patch: gobump
	./script/release.sh patch

minor: gobump
	./script/release.sh minor

gobump:
	go get github.com/motemen/gobump/cmd/gobump

deps:
	go get -d -v ./...

clean:
	go clean

.PHONY: yacc build clean deps test
