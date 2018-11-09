# Minim OpenWrt feed

This feed adds [Minim][1]'s open source Unum agent to OpenWrt builds.

> Running the Unum agent requires a Minim Labs developer account. 
> [Sign up for an account][2] on the Minim website.


## Usage

Add the Minim feed to an OpenWrt build's `feeds.conf` file:

```
# Minim feed
src-git minim https://github.com/MinimSecure/minim-openwrt-feed
```

Update the local copy of the Minim feed with the OpenWrt `feeds` script:

```bash
./scripts/feeds update minim
./scripts/feeds install unum
``` 

Next:

- Enable or install the Unum agent in `make menuconfig` under *Network*
    - Then `make` as normal to generate images, etc.
- Build an Unum agent ipk with `make package/feeds/minim/unum/compile`
    - Then `scp` the `.ipk` onto your router and use `opkg install` to install 
      it.

[1]: https://www.minim.co
[2]: https://my.minim.co/developers/sign_up
