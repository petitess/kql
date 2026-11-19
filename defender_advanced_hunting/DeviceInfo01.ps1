DeviceInfo
| where DeviceName startswith "fly-"
| where OSVersionInfo == "26H2"
| summarize arg_max(Timestamp, *) by DeviceId
