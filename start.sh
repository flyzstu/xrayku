#!/bin/bash

install_xray(){

	# Download files
	XRAY_FILE="Xray-linux-64.zip"
	echo "Downloading binary file: ${XRAY_FILE}"

	wget -O ${PWD}/Xray.zip "https://github.com/flyzstu/dist/raw/main/${XRAY_FILE}"

	if [ $? -ne 0 ]; then
		echo "Error: Failed to download binary file: ${XRAY_FILE} " && exit 1
	fi
	echo "Download binary file: ${XRAY_FILE} completed"

	# Prepare
	echo "Prepare to use"
	unzip Xray.zip && chmod +x ./xray && rm Xray.zip
}

install_dat(){
	wget -O geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
	wget -O geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
	echo ".dat has been downloaded!"
}
install_config(){
cat << EOF > ./config.json
{
  "log": {
    "loglevel": "info"
  },
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [            
	   {
                "type": "field",
                "outboundTag": "Proxy",
                "domain": [
                    "domain:gstatic.com",
                    "domain:edge.activity.windows.com"
                ]
            },
            {
                "type": "field",
                "outboundTag": "Reject",
                "domain": [
                    "geosite:category-ads-all",
                    "geosite:win-spy",
		    "domain:jable.tv",
		    "domain:supjav.com",
		    "domain:netflav.com"
                ]
            }
        ]
},
  "inbounds": [
    {
      "port": $PORT, 
      "protocol": "vless", 
      "settings": {
        "decryption": "none", 
        "clients": [
          {
            "id": "$ID"
          }
        ]
      }, 
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "$WS_PATH"
        }, 
        "security": "none"
      }
    }
  ], 
  "outbounds": [
    {
      "protocol": "freedom", 
      "tag": "Proxy"
    }, 
    {
      "protocol": "blackhole", 
      "settings": {
        "response": {
          "type": "http"
        }
      }, 
      "tag": "Reject"
    }
  ]
}
EOF
}

install_xray
install_dat
install_config

chmod +x xray

./xray -c config.json
