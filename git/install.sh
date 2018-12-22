#!/usr/bin/env bash
# Program:
#   git工具集的安装脚本, 该工具集主要提供以下功能:
#       1. git ci命令: 用来代替git commit, 提供交互式提交操作, 用于定制统一的提交信息.
#       2.
#
# History:
#       2018/06/21  renfeng.zhang   0.1.0
#
# Usage:
#   1. 使用curl安装: bash -c "$(curl -fsSL https://github.com/zhangrenfeng/aptkit/blob/master/git/install.sh)"
#   2. 使用wget安装: bash -c "$(wget https://github.com/zhangrenfeng/aptkit/blob/master/git/install.sh -O -)"
#   3. 本地安装: 将该工程下载到本地, 然后进入该文件所在的目录, 执行命令:
#           sudo sh -x ./install.sh install

# 初始化环境变量
function init()
{
    COMMAND="git/command"
    CONFIG="git/config"
    HOOKS="git/hooks"

    # 命令脚本文件
    SCRIPT_FILES=("git-ci" "git-clog")

    # commit模板信息
    TEMPLATE_FILES="git-message-template"

    # 用户主目录
    USER_HOME_DIRECTORY="$(env | grep ^HOME | cut -c 6-)"

    # aptkit远程git仓库名称
    if [[ -z "$REPO_NAME" ]]; then
        REPO_NAME="aptkit"
    fi

    # aptkit远程git仓库地址
    if [[ -z "$REPO_URL" ]]; then
        REPO_URL="https://github.com/zhangrenfeng/aptkit.git"
    fi

    # 命令执行路径和安装路径
    COMMAND_PATHS=("/usr/local/bin" "$USER_HOME_DIRECTORY/bin")
    INSTALL_PATHS=("/usr/local/$REPO_NAME" "$USER_HOME_DIRECTORY/.$REPO_NAME")

    # 获取命令执行路径
    PATH_NUMBER=0
    uname -a | egrep -i linux && { echo $PATH | egrep /usr/local/sbin || PATH=$PATH:/usr/local/sbin; }
    for path in "${COMMAND_PATHS[@]}"; do
        if [[ "$(echo $PATH | grep "${path}")" ]]; then
            touch "$path/gitkit-tmp" > /dev/null 2>&1
            if [[ $? == 0 ]]; then
                COMMAND_PATH_PREFIX="$path"
                rm "$path/gitkit-tmp" > /dev/null 2>&1
                break
            fi
        fi
        PATH_NUMBER=$(($PATH_NUMBER+1))
    done

    # 获取安装路径
    if [[ $PATH_NUMBER =~ ^[0-$(expr ${#COMMAND_PATHS[@]} - 1)] ]]; then
        INSTALL_PATH=${INSTALL_PATHS[PATH_NUMBER]}
    fi

    if [[ -z "$COMMAND_PATH_PREFIX" || -z "$INSTALL_PATH" ]]; then
        echo "$REPO_NAME environment init failed."
        exit 1
    fi
}

# clone远程仓库
function clone()
{
    if [[ -d "$INSTALL_PATH" && -d "$INSTALL_PATH/.git" ]]; then
        echo "Using existing repo: $REPO_NAME"

        cd $INSTALL_PATH || exit 1
        git pull
        cd - || exit 1
    else
        echo "Cloning repo from GitHub to $INSTALL_PATH"
        git clone "$REPO_URL" "$INSTALL_PATH" || exit 1
        chmod -R 755 "$INSTALL_PATH/$COMMAND"
        chmod -R 755 "$INSTALL_PATH/$HOOKS"
    fi
}

# 安装命令
function install_command()
{
    echo "Insall git command..."

    mkdir -p $COMMAND_PATH_PREFIX

    for scriptFile in "${SCRIPT_FILES[@]}"; do
        ln -s "$INSTALL_PATH/$COMMAND/$scriptFile" "$COMMAND_PATH_PREFIX/$scriptFile" > /dev/null 2>&1 || echo "$COMMAND_PATH_PREFIX/$scriptFile installed"
    done

    ln -s "$INSTALL_PATH/git/install.sh" "$COMMAND_PATH_PREFIX/gitkit" > /dev/null 2>&1 || echo "$COMMAND_PATH_PREFIX/$REPO_NAME installed."
}

# 安装配置
function install_config()
{
    echo "Install git config..."

    ALIAS=`git config --list | grep 'alias.ci'`
    if [[ -n "$ALIAS" ]]; then
        git config --global --unset alias.ci
    fi

    git config --global commit.template "$INSTALL_PATH/$CONFIG/$TEMPLATE_FILES"
}

# 安装命令
function install_command()
{
    echo "Insall git command..."

    mkdir -p $COMMAND_PATH_PREFIX

    for scriptFile in "${SCRIPT_FILES[@]}"; do
        ln -s "$INSTALL_PATH/$COMMAND/$scriptFile" "$COMMAND_PATH_PREFIX/$scriptFile" > /dev/null 2>&1 || echo "$COMMAND_PATH_PREFIX/$scriptFile installed"
    done

    ln -s "$INSTALL_PATH/git/install.sh" "$COMMAND_PATH_PREFIX/gitkit" > /dev/null 2>&1 || echo "$COMMAND_PATH_PREFIX/$REPO_NAME installed."
}

# 安装配置
function install_config()
{
    echo "Install git config..."

    ALIAS=`git config --list | grep 'alias.ci'`
    if [[ -n "$ALIAS" ]]; then
        git config --global --unset alias.ci
    fi

    git config --global commit.template "$INSTALL_PATH/$CONFIG/$TEMPLATE_FILES"
}

# 安装钩子
function install_hooks()
{
    echo "Install git hooks..."

    git config --global core.hooksPath "$INSTALL_PATH/$HOOKS"
}

# 卸载
function uninstall()
{
    if [[ -d "$INSTALL_PATH" ]]; then
        echo "Uninstalling $REPO_NAME"
        rm -rf "$INSTALL_PATH" > /dev/null 2>&1
    else
        echo "$INSTALL_PATH is not existing."
    fi

    if [[ -d "$COMMAND_PATH_PREFIX" ]]; then
        echo "Uninstalling $REPO_NAME command from $COMMAND_PATH_PREFIX"
        for scriptFile in "${SCRIPT_FILES[@]}"; do
            echo "rm -vf $COMMAND_PATH_PREFIX/$scriptFile"
            rm -vf "$COMMAND_PATH_PREFIX/$scriptFile"
        done

        rm -vf "$COMMAND_PATH_PREFIX/gitkit"
    else
        echo "The '$COMMAND_PATH_PREFIX' directory was not found."
    fi

    git config --global --unset commit.template
    git config --global --unset core.hooksPath
}

# 使用帮助
function help()
{
    echo "Usage: gitkit [install|uninstall|update|help]"
}
# 安装
function install()
{
    echo "Installing $REPO_NAME to $COMMAND_PATH_PREFIX"

    clone
    install_command
    install_config
    install_hooks
}

# 更新
function update()
{
    echo "Update $REPO_NAME"

    install
}

# 欢迎信息
function welcome()
{
    echo "gitkit installer"
    echo "----------------------------------------";
    echo "欢迎使用 gitkit";
    echo "";
}

# 主函数
function main()
{
    welcome

    # 获取系统信息, 并进行初始化操作
    uname -a | egrep -i linux && { [ `id -u` -eq 0 ] && init || { echo "Please  sudo  bash installer.sh " && exit 0; } ;} || init

    case $1 in
        uninstall )
            uninstall
            ;;

        update )
            update
            exit
            ;;

        help )
            help
            exit
            ;;

        * )
            install
            exit
            ;;
    esac
}

main "$@"