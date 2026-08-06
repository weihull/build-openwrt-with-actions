# 请在下方输入自定义命令(一般用来安装第三方插件)(可以留空)

# ===== OpenWrt 下载镜像源（解决 GitHub Actions 访问官方源 404/403/502）=====
# 方法1：写入 scripts/localmirrors 文件（download.pl 会读取）
mkdir -p scripts
cat > scripts/localmirrors << 'EOF'
https://mirrors.tuna.tsinghua.edu.cn/openwrt
https://mirrors.aliyun.com/openwrt
https://mirrors.nju.edu.cn/openwrt
EOF
# 方法2：设置环境变量（本步骤内有效，workflow 顶层 env 已全局设置）
export DOWNLOAD_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/openwrt;https://mirrors.aliyun.com/openwrt;https://mirrors.nju.edu.cn/openwrt"


# 编辑默认的lan口ip地址
sed -i 's/192.168.1.1/192.168.31.1/g' package/base-files/files/bin/config_generate

# 编辑默认的主题
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 编辑默认的luci显示的固件名称
#sed -i 's/OpenWrt/ZWRT/g' package/base-files/files/bin/config_generate
#sed -i 's/ImmortalWrt/ZWRT/g' package/base-files/files/bin/config_generate

# 添加额外的软件包，echo 方式和git clone 方式二选一即可
#echo 'src-git kenzok8 https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default
#echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default
#echo 'src-git kiddin9 https://github.com/kiddin9/kwrt-packages' >>feeds.conf.default
#echo 'src-git UA3F https://github.com/SunBK201/UA3F.git' >>feeds.conf.default
#git clone https://github.com/kenzok8/openwrt-packages.git package/openwrt-packages
#git clone https://github.com/kenzok8/small.git package/small
#git clone https://github.com/SunBK201/UA3F.git package/UA3F
#git clone https://github.com/stevenjoezhang/luci-app-adguardhome.git package/ADGH
#git clone https://github.com/kiddin9/kwrt-packages.git package/kwrt-packages

# === 内置首次开机配置（不依赖 files 大法，直接编译进固件）===
# 功能：设置主机名、双频WiFi名称、WiFi无密码；root 保持 ImmortalWrt 默认（无密码）
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-custom <<'EOF'
#!/bin/sh
# === 自动化 OpenWrt 首次配置脚本 ===

# === 用户自定义变量 ===
wlan_name0="MIwifi"
wlan_name1="MIwifi"
wlan_password=""
root_password=""
lan_ip_address="192.168.31.1"
pppoe_username=""
pppoe_password=""
hostname="Xiaomi Mini"

# === 设置管理员密码（空则保留 ImmortalWrt 默认，即 root 无密码） ===
if [ -n "$root_password" ]; then
  (echo "$root_password"; sleep 1; echo "$root_password") | passwd >/dev/null 2>&1
fi

# === 配置 LAN 网络 ===
if [ -n "$lan_ip_address" ]; then
  uci set network.lan.ipaddr="$lan_ip_address"
  uci set network.lan.netmask="255.255.255.0"
  uci commit network
fi

# === 配置 Wi-Fi ===
# 2.4GHz（radio0）
uci set wireless.radio0.disabled='0'
uci set wireless.radio0.htmode='HT40'
uci set wireless.radio0.channel='auto'
uci -q delete wireless.default_radio0.encryption
uci -q delete wireless.default_radio0.key
uci set wireless.default_radio0.ssid="$wlan_name0"
uci set wireless.default_radio0.encryption='none'

uci set wireless.radio1.disabled='0'
uci set wireless.radio1.htmode='VHT80'
uci set wireless.radio1.channel='auto'
uci -q delete wireless.default_radio1.encryption
uci -q delete wireless.default_radio1.key
uci set wireless.default_radio1.ssid="$wlan_name1"
uci set wireless.default_radio1.encryption='none'

uci commit wireless

# === 配置 PPPoE 拨号 ===
if [ -n "$pppoe_username" ] && [ -n "$pppoe_password" ]; then
  uci set network.wan.proto='pppoe'
  uci set network.wan.username="$pppoe_username"
  uci set network.wan.password="$pppoe_password"
  uci commit network
fi

# === 设置主机名 ===
if [ -n "$hostname" ]; then
  uci set system.@system[0].hostname="$hostname"
  uci commit system
fi

# === 设置时区 ===
uci set system.@system[0].zonename='Asia/Shanghai'
uci set system.@system[0].timezone='CST-8'
uci commit system

echo "✅ 首次启动配置完成！"
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-custom
#git clone https://github.com/stevenjoezhang/luci-app-adguardhome.git package/ADGH
#git clone https://github.com/kiddin9/kwrt-packages.git package/kwrt-packages
