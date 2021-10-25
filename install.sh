#!/bin/bash



function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(($RANDOM+1000000000)) #增加一个10位的数再求余
    echo $(($num%$max+$min))
}

read -p "使用内置 frp 服务器(yes/no, 默认 yes):" defaultFrp
defaultFrp=${defaultFrp:yes}


read -p "frp remote_port(用于访问遥控车控制界面, 如: 9088, 默认随机):" frpPort
defaultPort=$(rand 9010 9098)
frpPort=${frpPort:-$defaultPort}
read -p "Network RC 密码(默认 networkrc):" password
password=${password:-networkrc}

if [ "$defaultFrp" = "no" ]; then
  read -p "frp 服务器地址(默认: gz.esonwong.com):" frpServer
  read -p "frp 服务器连接端口, server_port(默认9099):" frpServerPort
  read -p "frp user:" frpServerToken
  read -p "frp token:" frpServerUser
  read -p "https 证书 cert 路径:" -e tslCertPath
  read -p "https 证书 key 路径:" -e tslKeyPath
fi

defaultFrp=${defaultFrp:yes}
frpServer="${frpServer:-gz.esonwong.com}"
frpServerPort="${frpServerPort:-9099}"
frpServerToken="${frpServerToken:-"eson's network-rc"}"
frpServerUser="${frpServerUser:-""}"
tslCertPath="${tslCertPath:-"/home/pi/network-rc/lib/frpc/gz.esonwong.com/fullchain.pem"}"
tslKeyPath="${tslKeyPath:-"/home/pi/network-rc/lib/frpc/gz.esonwong.com/privkey.pem"}"


echo ""
echo ""
echo ""
echo "你的设置如下"
echo "frp 服务器地址: $frpServer"
echo "frp 服务器连接端口, server_port: $frpServerPort"
echo "frp user: $frpServerUser"
echo "frp token: $frpServerToken"
echo "frp remote_port(用于访问遥控车控制界面, 如: 9088): $frpPort" 
echo "https 证书 cert 路径: $tslCertPath"
echo "https 证书 key 路径: $tslKeyPath"
echo ""
echo ""
echo ""
echo "Network RC 控制界面访问地址: https://$frpServer:$frpPort"
echo "Network RC 控制界面访问密码: $password"
echo ""
echo ""
echo ""


read -p "输入 ok 继续， 输入其他结束:" ok
echo "$ok"


if [ "$ok" = "ok" ]; then

echo ""
echo ""
echo ""
echo "下载 Network RC"
sudo rm -f /tmp/network-rc.tar.gz
wget -O /tmp/network-rc.tar.gz https://download.esonwong.com/network-rc/network-rc.tar.gz

echo ""
echo ""
echo ""
echo "解压 Network RC 中..."
tar -zxf /tmp/network-rc.tar.gz -C /home/pi/


echo ""
echo ""
echo ""
echo "安装 Network RC 服务"

echo "[Unit]
Description=network-rc
After=syslog.target  network.target
Wants=network.target

[Service]
User=root
Type=simple
ExecStart=/home/pi/network-rc/node /home/pi/network-rc/index.js --tsl -f $frpServer -o $frpPort -p \"$password\" --frpServerPort $frpServerPort --frpServerToken \"$frpServerToken\" --frpServerUser \"${frpServerUser}\" --tslCertPath \"${tslCertPath}\" --tslKeyPath \"${tslKeyPath}\"
Restart=always
RestartSec=15s

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/network-rc.service

echo ""
echo ""
echo "创建 Network RC 服务完成"


sudo systemctl enable network-rc.service
echo "重启 Network RC 服务"
sudo systemctl restart network-rc.service

apiToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI2MTBjZDM1MDdhMDQwY2U1ZDZiMTM0YjgiLCJpYXQiOjE2MjgyMzA0ODB9.EsmkfPq4H5oduC9XOSuYx3jf-goGoDartF5BwmxlQJ4
curl -X POST 'https://api.hipacloud.com/v1/apps/610cd37366dab8af97741508/tables/610cd37366dab8af97741509/records' \
-H "Authorization: Bearer $apiToken" \
-H "Content-Type: application/json" \
-o /dev/null \
--data "{
  \"values\": {
    \"名称\": \"安装\",
    \"描述\": \"\",
    \"端口\": $frpPort
  }
}
"


echo ""
echo ""
echo ""
echo "安装 Network RC 完成"

else 
exit 0
fi



