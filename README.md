# Minim OpenWrt feed

This feed adds [Minim][1]'s open source Unum agent to OpenWrt builds.

> Running the Unum agent requires a Minim Labs developer account. 
> [Sign up for an account][2] on the Minim website.

Download a pre-built ipk package for your platform on the 
[Unum SDK releases][3] page.

## Usage

In-depth instructions are available in the [Unum SDK repository][4] and [wiki][5].

### Overview

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

Enable or install the Unum agent in `make menuconfig` under *Network* then 
`make` as normal to generate images, etc.

Build an Unum agent ipk with `make package/unum/compile`, then use `scp` to 
copy the ipk onto your router and use `opkg install` to install it.




[1]: https://www.minim.co
[2]: https://my.minim.co/labs
[3]: https://github.com/MinimSecure/unum-sdk/releases
[4]: https://github.com/MinimSecure/unum-sdk/blob/master/README-openwrt_generic.md
[5]: https://github.com/MinimSecure/unum-sdk/wiki
