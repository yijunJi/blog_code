#!usr/bin/env sh
#当发生错误中止脚本
set -e
# 打包
yarn build
# cd 到构建输出的目录下
cd ./docs/.vuepress/dist
# 打包后的文件上传到github主页
git init
git add -A
git commit -m 'deploy'
git remote add origin git@github.com:yijunJi/yijunJi.github.io.git
git push -f origin master
rm -rf ../dist
cd -