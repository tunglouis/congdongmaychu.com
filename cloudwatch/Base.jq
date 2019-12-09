{
    "agent": {
        "metrics_collection_interval": 60,
        "debug": false
    },
    "metrics": {
        "append_dimensions": {
            "InstanceId": "${aws:InstanceId}"
        },
        "aggregation_dimensions": [["InstanceName","InstanceVersion", "InstanceId"]],
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60,
                "totalcpu": true,
                "append_dimensions": {
                    "InstanceName": ($ec2tags.Name // "unknown"),
                    "InstanceVersion": ($ec2tags.Version // "unknown")
                }
            },
            "disk": {
                "measurement": [
                    "used_percent",
                    "inodes_free"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                        "*"
                ],
                "append_dimensions": {
                    "InstanceName": ($ec2tags.Name // "unknown"),
                    "InstanceVersion": ($ec2tags.Version // "unknown")
                }
            },
            "mem": {
                "measurement": [
                        "mem_used_percent"
                ],
                "metrics_collection_interval": 60,
                "append_dimensions": {
                    "InstanceName": ($ec2tags.Name // "unknown"),
                    "InstanceVersion": ($ec2tags.Version // "unknown")
                }
            },
            "netstat": {
                "measurement": [
                        "tcp_established",
                        "tcp_time_wait"
                ],
                "metrics_collection_interval": 60,
                "append_dimensions": {
                    "InstanceName": ($ec2tags.Name // "unknown"),
                    "InstanceVersion": ($ec2tags.Version // "unknown")
                }
            },
            "swap": {
                "measurement": [
                        "swap_used_percent"
                ],
                "metrics_collection_interval": 60,
                "append_dimensions": {
                    "InstanceName": ($ec2tags.Name // "unknown"),
                    "InstanceVersion": ($ec2tags.Version // "unknown")
                }
            }
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/system/secure*",
                        "log_group_name": "/global/system/secure",
                        "timezone": "UTC",
                        "log_stream_name": (($ec2tags.Name // "unknown") + "/" + ($ec2tags.Version // "unknown") + "/" + "{instance_id}")
                    },
                    {
                        "file_path": "/var/log/system/message*",
                        "log_group_name": "/global/system/message",
                        "timezone": "UTC",
                        "log_stream_name": (($ec2tags.Name // "unknown") + "/" + ($ec2tags.Version // "unknown") + "/" + "{instance_id}")
                    }
                ]
            }
        }
    }
}