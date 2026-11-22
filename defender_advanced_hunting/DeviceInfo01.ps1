DeviceInfo
| where DeviceName startswith "fly-"
| where OSVersionInfo == "26H2"
| summarize arg_max(Timestamp, *) by DeviceId

DeviceInfo
| where DeviceName startswith "fly-"
| where OsBuildRevision != "9911" and OsBuildRevision != "9974"
| where ClientVersion contains ".26200."
| summarize arg_max(Timestamp, *) by DeviceId
| project  DeviceName, ClientVersion, OsBuildRevision
