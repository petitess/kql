Destinct 
```kql
AzureDiagnostics
| where Category == "ApplicationGatewayFirewallLog"
| where action_s == "Blocked"
| where hostname_s == "api.abc.me"
| summarize arg_max(TimeGenerated, *) by clientIp_s
```
```kql
 AzureDiagnostics
| where Category == "ApplicationGatewayFirewallLog"
| where action_s == "Blocked"
| where hostname_s == "api.abc.me"
| summarize
    latestTime=max(TimeGenerated),
    hostnames=make_set(hostname_s),
    rules=make_set(ruleId_s),
    url=make_set(requestUri_s)
by clientIp_s
```
Timerange
```kql
NTANetAnalytics
| where FlowStartTime > ago(30m)
//| where TimeGenerated between (datetime(2026-10-08T11:50:03) .. datetime(2026-10-08T11:53:03))
| where (SrcIp == "10.1.1.1" and DestIp == "10.1.3.1") 
| project TimeGenerated, FlowDirection, FlowStatus, AclRule, SrcIp, DestIp
```
