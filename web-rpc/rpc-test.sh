result=`curl --insecure -X POST https://192.168.1.1/cgi-bin/luci/rpc/auth --data '{"method":"login","params":["root","felixoscar123"]}'`
key=`echo ${result} | awk -F, '{print $2}' | awk -F: '{print $2}' | awk -F\" '{print $2}'`
echo ${key}
result=`curl --insecure -X POST https://192.168.1.1/cgi-bin/luci/rpc/uci?auth=${key} --data '{"method":"delete", "params":["network","wan","tom"]}'`
echo ${result}
result=`curl --insecure -X POST https://192.168.1.1/cgi-bin/luci/rpc/uci?auth=${key} --data '{"method":"set", "params":["network","wan","ben","awesome"]}'`
echo ${result}
result=`curl --insecure -X POST https://192.168.1.1/cgi-bin/luci/rpc/uci?auth=${key} --data '{"method":"commit", "params":["network"]}'`
echo ${result}

# uci set network.wan.tom=washere
# uci delete network.wan.ben
# uci commit
