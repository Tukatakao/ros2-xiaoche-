#!/usr/bin/env bash
# install_deps.sh - 一键安装 xwdc_description 所需依赖
set -e

# ---------- 颜色 ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ---------- 检查 ROS 2 ----------
if [ -z "$ROS_DISTRO" ]; then
  error "ROS_DISTRO 未设置，请先 source /opt/ros/<distro>/setup.bash"
fi

info "检测到 ROS 2 版本: $ROS_DISTRO"

# ---------- 检查权限 ----------
if [ "$EUID" -eq 0 ]; then
  error "请不要用 root 运行，脚本内部会用 sudo"
fi

# ---------- 更新 apt ----------
info "更新 apt 索引..."
sudo apt update

# ---------- ROS 2 基础依赖 ----------
info "安装 ROS 2 基础依赖..."
sudo apt install -y \
  ros-$ROS_DISTRO-robot-state-publisher \
  ros-$ROS_DISTRO-joint-state-publisher \
  ros-$ROS_DISTRO-joint-state-publisher-gui \
  ros-$ROS_DISTRO-xacro \
  ros-$ROS_DISTRO-rviz2 \
  ros-$ROS_DISTRO-tf2-tools \
  ros-$ROS_DISTRO-tf2-ros

# ---------- Gazebo 仿真 ----------
info "安装 Gazebo 相关依赖..."
sudo apt install -y \
  ros-$ROS_DISTRO-gazebo-ros-pkgs \
  ros-$ROS_DISTRO-gazebo-ros \
  ros-$ROS_DISTRO-gazebo-plugins

# ---------- 控制 ----------
info "安装遥控与速度控制依赖..."
sudo apt install -y \
  ros-$ROS_DISTRO-teleop-twist-keyboard

# ---------- 录包与可视化 ----------
info "安装 rosbag 与可视化工具..."
sudo apt install -y \
  ros-$ROS_DISTRO-rosbag2 \
  ros-$ROS_DISTRO-rosbag2-py \
  ros-$ROS_DISTRO-rqt \
  ros-$ROS_DISTRO-rqt-plot \
  ros-$ROS_DISTRO-rqt-topic

# ---------- SLAM ----------
info "安装 slam_toolbox..."
sudo apt install -y \
  ros-$ROS_DISTRO-slam-toolbox

# ---------- Nav2 ----------
info "安装 Nav2..."
sudo apt install -y \
  ros-$ROS_DISTRO-nav2-bringup \
  ros-$ROS_DISTRO-nav2-map-server

# ---------- 系统工具 ----------
info "安装系统工具..."
sudo apt install -y \
  python3-pip \
  python3-matplotlib \
  sqlite3 \
  git

# ---------- Python 依赖 ----------
info "安装 Python 依赖..."
pip3 install --user \
  matplotlib \
  numpy

# ---------- rosdep ----------
info "初始化 rosdep..."
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
  sudo rosdep init || warn "rosdep 可能已初始化"
fi
rosdep update

# ---------- 从 package.xml 安装 ----------
if [ -f "package.xml" ]; then
  info "根据 package.xml 安装依赖..."
  rosdep install --from-paths . --ignore-src -r -y
else
  warn "未找到 package.xml，跳过 rosdep install"
fi

# ---------- 完成 ----------
info "所有依赖安装完成！"
echo ""
echo "下一步："
echo "  colcon build"
echo "  source install/setup.bash"
echo "  ros2 launch xwdc_description gazebo.launch.py"