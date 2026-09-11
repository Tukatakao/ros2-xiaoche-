from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():

    slam_node = Node(
        package='slam_toolbox',
        executable='async_slam_toolbox_node',
        name='slam_toolbox',
        parameters=[{
            'base_frame': 'cheti',#车体坐标系
            'odom_frame': 'odom',#里程计坐标系
            'map_frame': 'map',#地图坐标系
            'scan_topic': '/scan',#激光雷达话题
            'mode': 'mapping',#模式
        }],
        output='screen'
    )

    return LaunchDescription([
        slam_node,
    ])