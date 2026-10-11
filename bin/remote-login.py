#!/usr/bin/env python3
"""
Remote login via greetd IPC - authenticate and start a Wayland session.

Usage:
    ssh zorak 'sudo ~/src/tobert/bin/remote-login.py'
    ssh zorak 'sudo ~/src/tobert/bin/remote-login.py --user amy --session sway'
"""

import argparse
import getpass
import glob
import json
import socket
import struct
import sys
from pathlib import Path


class GreetdClient:
    """Client for greetd IPC (length-prefixed JSON over Unix socket)."""

    def __init__(self, socket_path: str):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.sock.connect(socket_path)

    def send(self, msg: dict) -> None:
        data = json.dumps(msg).encode()
        self.sock.sendall(struct.pack("<I", len(data)) + data)

    def recv(self) -> dict:
        length_data = self.sock.recv(4)
        if len(length_data) < 4:
            raise ConnectionError("Socket closed unexpectedly")
        length = struct.unpack("<I", length_data)[0]
        data = self.sock.recv(length)
        return json.loads(data)

    def close(self) -> None:
        self.sock.close()


def find_greetd_socket() -> str:
    """Find the greetd socket in /run."""
    sockets = glob.glob("/run/greetd*.sock")
    if not sockets:
        raise FileNotFoundError("No greetd socket found in /run/")
    return sockets[0]


def login(user: str, password: str, session: str) -> bool:
    """Authenticate to greetd and start a session."""
    socket_path = find_greetd_socket()
    print(f"Using socket: {socket_path}")

    client = GreetdClient(socket_path)

    try:
        # Step 1: Create session
        print(f"Creating session for {user}...")
        client.send({"type": "create_session", "username": user})
        resp = client.recv()
        print(f"  → {resp.get('type', 'unknown')}")

        if resp.get("type") == "error":
            print(f"  Error: {resp.get('description', 'unknown error')}")
            return False

        # Step 2: Handle auth (may have multiple rounds)
        while resp.get("type") == "auth_message":
            auth_type = resp.get("auth_message_type", "secret")
            prompt = resp.get("auth_message", "Password")
            print(f"  Auth ({auth_type}): {prompt}")

            if auth_type == "secret":
                response = password
            else:
                response = input(f"  {prompt}: ")

            client.send({"type": "post_auth_message_response", "response": response})
            resp = client.recv()
            print(f"  → {resp.get('type', 'unknown')}")

            if resp.get("type") == "error":
                print(f"  Error: {resp.get('description', 'unknown error')}")
                return False

        # Step 3: Start session
        if resp.get("type") == "success":
            print(f"Starting session: {session}")
            client.send({"type": "start_session", "cmd": [session]})
            resp = client.recv()
            print(f"  → {resp.get('type', 'unknown')}")

            if resp.get("type") == "success":
                print("✓ Session started! Connect via Moonlight.")
                return True
            else:
                print(f"  Error: {resp.get('description', 'failed to start session')}")
                return False
        else:
            print(f"Unexpected response: {resp}")
            return False

    finally:
        client.close()


def main():
    parser = argparse.ArgumentParser(description="Remote login via greetd")
    parser.add_argument("--user", "-u", default="atobey", help="Username")
    parser.add_argument("--session", "-s", default="labwc", help="Session command")
    parser.add_argument("--password", "-p", help="Password (insecure, use stdin instead)")
    args = parser.parse_args()

    # Get password
    if args.password:
        password = args.password
    elif not sys.stdin.isatty():
        password = sys.stdin.readline().rstrip("\n")
    else:
        password = getpass.getpass(f"Password for {args.user}: ")

    success = login(args.user, password, args.session)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
