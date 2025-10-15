在 ImmortalWrt 中，首次启动时运行的脚本可以用于自动化配置，例如设置网络、Wi-Fi、管理员密码等,
脚本示例:
#!/bin/sh
# 设置变量
wlan_name0="Redmi_255E"
wlan_name1="Redmi_255E_5G"
wlan_password="13595751450"
lan_ip_address="192.168.31.1"
#root_password=""
#pppoe_username=" "
#pppoe_password=" "
#hostname="ImmortalRouter"
# 设置管理员密码
:<<EOF
if [ -n "$root_password" ]; then
 (echo "$root_password"; sleep 1; echo "$root_password") | passwd > /dev/null
fi
EOF
# 配置 LAN 网络
if [ -n "$lan_ip_address" ]; then
 uci set network.lan.ipaddr="$lan_ip_address"
 uci set network.lan.netmask="255.255.255.0"
 uci commit network
fi
# 配置 Wi-Fi
if [ -n "$wlan_name0" -a -n "$wlan_password" -a ${#wlan_password} -ge 8 ]; then
 #uci set wireless.radio0.disabled='0'
 #uci set wireless.radio0.htmode='HT40'
 #uci set wireless.radio0.channel='auto'
 uci set wireless.radio1.cell_density='0'
 uci set wireless.default_radio0.ssid="$wlan_name0"
 uci set wireless.default_radio0.encryption='psk2'
 uci set wireless.default_radio0.key="$wlan_password"
fi
if [ -n "$wlan_name1" -a -n "$wlan_password" -a ${#wlan_password} -ge 8 ]; then
 #uci set wireless.radio1.disabled='0'
 #uci set wireless.radio1.htmode='VHT80'
 #uci set wireless.radio1.channel='auto'
 uci set wireless.radio1.cell_density='0'
 uci set wireless.default_radio1.ssid="$wlan_name1"
 uci set wireless.default_radio1.encryption='psk2'
 uci set wireless.default_radio1.key="$wlan_password"
fi
uci commit wireless
# 配置 PPPoE 拨号
:<<EOF
if [ -n "$pppoe_username" -a -n "$pppoe_password" ]; then
 uci set network.wan.proto='pppoe'
 uci set network.wan.username="$pppoe_username"
 uci set network.wan.password="$pppoe_password"
 uci commit network
fi
# 设置主机名
if [ -n "$hostname" ]; then
 uci set system.@system[0].hostname="$hostname"
 uci commit system
fi
# 设置时区
uci set system.@system[0].zonename='Asia/Shanghai'
uci set system.@system[0].timezone='CST-8'
EOF
# 重启网络服务
/etc/init.d/network restart
echo "首次启动配置完成！"
