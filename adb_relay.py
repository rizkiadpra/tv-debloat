#!/usr/bin/env python3
# ponytail: dumb TCP relay so Homebrew adb (blocked by macOS Local Network Privacy)
# reaches the TV via loopback. Apple-signed python IS allowed on the LAN.
# Port 15555: adb reserves 5554-5585 for emulators, so stay out of that range.
import socket, threading, sys

# usage: adb_relay.py <tv-ip> [local-port] [tv-port]
TV_IP    = sys.argv[1] if len(sys.argv) > 1 else "192.168.100.33"
LOCAL_PT = int(sys.argv[2]) if len(sys.argv) > 2 else 15555
TV_PORT  = int(sys.argv[3]) if len(sys.argv) > 3 else 5555

LISTEN = ("127.0.0.1", LOCAL_PT)
UPSTREAM = (TV_IP, TV_PORT)

def pump(a, b):
    try:
        while True:
            d = a.recv(65536)
            if not d: break
            b.sendall(d)
    except OSError:
        pass
    finally:
        for s in (a, b):
            try: s.shutdown(socket.SHUT_RDWR)
            except OSError: pass
            try: s.close()
            except OSError: pass

def handle(c):
    try:
        u = socket.create_connection(UPSTREAM, 10)
    except OSError as e:
        print("upstream fail:", e, flush=True); c.close(); return
    threading.Thread(target=pump, args=(c, u), daemon=True).start()
    threading.Thread(target=pump, args=(u, c), daemon=True).start()

srv = socket.socket()
srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind(LISTEN); srv.listen(16)
print(f"relay {LISTEN[0]}:{LISTEN[1]} -> {UPSTREAM[0]}:{UPSTREAM[1]}", flush=True)
while True:
    c, _ = srv.accept()
    threading.Thread(target=handle, args=(c,), daemon=True).start()
