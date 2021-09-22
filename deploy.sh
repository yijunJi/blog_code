#!usr/bin/env sh
#当发生错误中止脚本
set -e
# cd 到构建输出的目录下
cd ./docs/.vuepress/dist
git init
git add -A
git commit -m 'deploy'
# 这里的access_token是travis设置的环境变量
git push -f https://${jiyijun}@github.com/yijunJi/yijunJi.github.io.git master
cd -  # 返回上一层