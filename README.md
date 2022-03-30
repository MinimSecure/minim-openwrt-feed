# Minim OpenWrt feed

Add the Minim feed to an OpenWrt build's `feeds.conf` file:

```
# Minim feed
src-git minim https://github.com/MinimSecure/minim-openwrt-feed
```

Update the local copy of the Minim feed with the OpenWrt `feeds` script:

```bash
./scripts/feeds update minim
```
## Agent

This package adds [Minim][1]'s open source Unum agent to OpenWrt builds.

> Running the Unum agent requires a Minim Labs developer account. 
> [Sign up for an account][2] on the Minim website.

Download a pre-built ipk package for your platform on the 
[Unum SDK releases][3] page.

### Usage

In-depth instructions are available in the [Unum SDK repository][4] and [wiki][5].

### Overview

After adding the feed as above, install the package with

```bash
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

## WEB-RPC

This package is a limited functionality replacement for https://openwrt.org/packages/pkgdata/luci-mod-rpc that removes the dependency on lua/luci.

Examples of the luci-mod-rpc api can be found at https://floatingoctothorpe.uk/2017/managing-openwrt-remotely-with-curl.html

This package has slightly different semantics
- it makes assumptions about the json syntax for simplicity
- it commits immediately instead of deferring the operation until a commit is performed
- it assumes network parameter changes are being made as per https://github.com/MinimSecure/minim-openwrt-feed/blob/master/web-rpc/src/web_rpc.c#L242
