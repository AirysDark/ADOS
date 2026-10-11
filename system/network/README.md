# ADOS networking

ADOS owns normal Ethernet and Wi-Fi station networking.

## Interface ownership

- `eth0`: normal ADOS Ethernet
- `wlan0`: normal ADOS Wi-Fi station interface
- `ados0`: reserved exclusively for the ADOS Portable subsystem

The normal network service must never run DHCP, wpa_supplicant, delete, rename, or otherwise claim `ados0`. Portable creates and removes that virtual AP interface itself.

Boot ordering is intentionally:

```text
S01ados
S30ados-network
S45ados-portable
```

This allows the normal `wlan0` station to associate first. Portable can then inspect the active parent-radio channel and create `ados0` on a compatible channel without taking over the user's normal network connection.
