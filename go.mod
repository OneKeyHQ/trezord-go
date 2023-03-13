module onekey.so/bridge

go 1.19

require (
	github.com/OneKeyHQ/onekey-bridge v2.1.0+incompatible
	github.com/getsentry/sentry-go v0.18.0
	github.com/gorilla/csrf v1.5.1
	github.com/gorilla/handlers v1.3.0
	github.com/gorilla/mux v1.6.1
	gopkg.in/natefinch/lumberjack.v2 v2.0.0-20170531160350-a96e63847dc3
)

require (
	github.com/gorilla/context v1.1.1 // indirect
	github.com/gorilla/securecookie v1.1.1 // indirect
	github.com/pkg/errors v0.9.1 // indirect
	golang.org/x/sys v0.0.0-20220928140112-f11e5e49a4ec // indirect
	golang.org/x/text v0.3.7 // indirect
)

replace github.com/OneKeyHQ/onekey-bridge => ./

replace github.com/OneKeyHQ/onekey-bridge/core => ./core

replace github.com/OneKeyHQ/onekey-bridge/memorywriter => ./memorywriter

replace github.com/OneKeyHQ/onekey-bridge/server => ./server

replace github.com/OneKeyHQ/onekey-bridge/usb => ./usb
