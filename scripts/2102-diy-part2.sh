#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 移除 openwrt feeds 自带的核心包
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
git clone https://github.com/sbwml/openwrt_helloworld package/helloworld

# 更新 golang 1.23 版本
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# 替换 Passwall 软件
rm -rf feeds/luci/applications/luci-app-passwall/*
git clone -b main --single-branch https://github.com/xiaorouji/openwrt-passwall passwall
mv passwall/luci-app-passwall/* feeds/luci/applications/luci-app-passwall/
rm -rf passwall

# 添加 Passwall2 软件
# rm -rf feeds/luci/applications/luci-app-passwall2
mkdir feeds/luci/applications/luci-app-passwall2
git clone -b main --single-branch https://github.com/xiaorouji/openwrt-passwall2 passwall2
mv passwall2/luci-app-passwall2/* feeds/luci/applications/luci-app-passwall2/
rm -rf passwall2

# 修改 Passwall 检测规则
sed -i 's/socket" "iptables-mod-//g' feeds/luci/applications/luci-app-passwall/root/usr/share/passwall/app.sh

# 修改 Passwall2 检测规则
sed -i 's/socket" "iptables-mod-//g' feeds/luci/applications/luci-app-passwall2/root/usr/share/passwall2/app.sh

# 添加 OpenClash 软件
git clone --depth 1 https://github.com/vernesong/openclash.git OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
mv OpenClash/luci-app-openclash feeds/luci/applications/luci-app-openclash

# Remove v2ray-geodata package from feeds (openwrt-22.03 & master)
rm -rfv feeds/packages/net/v2ray-geodata
git clone https://github.com/Ljzkirito/v2ray-geodata feeds/packages/net/v2ray-geodata
rm -rfv feeds/packages/net/mosdns
find ./ | grep Makefile | grep luci-app-mosdns | xargs rm -fv
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

# 替换 Smartdns
./scripts/feeds uninstall luci-app-smartdns smartdns
./scripts/feeds install -a -p customsd

# 替换 luci-app-ssr-plus & Depends
Replace_package="xray-core xray-plugin v2ray-core v2ray-plugin hysteria ipt2socks microsocks redsocks2 chinadns-ng dns2socks dns2tcp naiveproxy simple-obfs tcping tuic-client luci-app-ssr-plus"
./scripts/feeds uninstall ${Replace_package}
./scripts/feeds install -f -p helloworld ${Replace_package}

# 替换 shadowsocks-rust
rm -rfv feeds/packages/net/shadowsocks-rust
git clone https://github.com/Ljzkirito/shadowsocks-rust feeds/packages/net/shadowsocks-rust

# 修改登录 IP
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# 修改默认 SSID
sed -i "s/ImmortalWrt-2.4G/Breakwa11/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i "s/ImmortalWrt-5G/Breakwa11 ax/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# ttyd 终端自动登录
sed -i "s?/bin/login?/usr/libexec/login.sh?g" feeds/packages/utils/ttyd/files/ttyd.config
