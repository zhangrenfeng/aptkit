# Program:
#
# History:
#   2018/12/27      renfeng.zhang   0.1.0

source helper.sh

# 安装搜狗输入法
echo_green "Install sogouinput ... "
brew cask install sogouinput
sogou_base="/usr/local/Caskroom/sogouinput"
sogou_version="$sogou_base/"`ls "$sogou_base"`
sogou_app="$sogou_version/"`ls $sogou_version | grep .app | tail -n 1`
open "$sogou_app"

# 扩展预览程序
# 对于一些文本文件, 按下空格键就可以调用系统的预览程序, 快速浏览文件内容.
# 但如果想获得更好的阅读体验, 或支持更多类型的快速浏览, 就需要通过插件来完成
#   1. qlcolorcode 代码高亮插件
#   2. qlstephen 预览没有后缀的文本文件
#   3. qlmarkdown 预览 markdown 文件的渲染效果
#   4. quicklook-json 提供对 JSON 文件的格式化和高亮支持
#   5. qlimagesize 展示图片的分辨率和大小
#   6. webpquicklook 预览 WebP 格式的图片
#   7. qlvideo 预览更多格式的视频文件
#   8. provisionql 预览 .app 或者 .ipa后缀的程序
echo_green "Install quick look plugins ... "
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json webpquicklook provisionql
brew cask install --appdir='/usr/local/bin' qlimagesize qlvideo

# 安装应用

# 1. 安装 Charles
echo_green "Install charles ... "
if [[ -e "/Applications/Charles.app" ]]; then
    echo_blue "You have installed Charles"
else
    if [[ ! -e "$HOME/Downloads/Charles.app.zip" ]]; then
        download_url="http://p2w4johvr.bkt.clouddn.com/Charles.app.zip"
        echo_green "Download charles from ${download_url}"
        curl "${download_url}" -o ~/Downloads/Charles.app.zip
    fi

    echo_green "Unzip $HOME/Downloads/Charles.app.zip"
    unzip -q $HOME/Downloads/Charles.app.zip -d /Applications
    echo_green "Remove $HOME/Downloads/Charles.app.zip"
    rm $HOME/Downloads/Charles.app.zip
fi

# 2. 安装 Dash