```kql
NTANetAnalytics
| where FlowStartTime > ago(30m)
//| where TimeGenerated between (datetime(2026-10-08T11:50:03) .. datetime(2026-10-08T11:53:03))
| where (SrcIp == "10.1.1.1" and DestIp == "10.1.3.1") 
| project TimeGenerated, FlowDirection, FlowStatus, AclRule, SrcIp, DestIp
```
