# build-openwrt-with-actions

## 使用方法

fork这个仓库。可选编译immortalwrt或者openwrt。可以上传.config也可以在编译的时候勾选ssh选项手动配置config。还可以将已有的openwrt的/etc下的配置文件放入files目录，编译的时候会自动使用配置文件，这样更新固件就不会丢失配置了。但是将项目私有化会导致编译环境优化的存储空间只有50G+，大概率会报空间不足的错误，公开项目就能使用120G存储空间。

    勾选了很多插件容易导致编译慢以及报错，建议按需勾选。以及自己慢慢测试，我自己编译是成功的。

## 默认.config如下

- target ramips/mt7620
- device Xiaomi MiWiFi Mini
- 160M 内核空间
- 1600M root空间
  
-------------------------------

- network/adguardhome
- luci-app-homeproxy
- luci-app-openclash
- luci-app-acme
- luci-app-wol
- luci-app-upnp
- luci-app-n2n
  