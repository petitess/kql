```kql
NTANetAnalytics
| where FlowStartTime > ago(30m)
| where (SrcIp == "10.100.88.4" and DestIp == "10.10.30.10") 
| project TimeGenerated, FlowDirection, FlowStatus, AclRule, SrcIp, DestIp
```
| TimeGenerated                | FlowDirection | FlowStatus | AclRule               | SrcIp       | DestIp      |
| ---------------------------- | ------------- | ---------- | --------------------- | ----------- | ----------- |
| 2026-10-08T11:52:42.2123106Z | Inbound       | Allowed    | platformrule          | 10.100.88.4 | 10.10.30.10 |
| 2026-10-08T11:52:42.2123106Z | Outbound      | Allowed    | allowvnetoutbound     | 10.100.88.4 | 10.10.30.10 |
| 2026-10-08T11:52:39.2947074Z | Inbound       | Allowed    | infra-vnettoany       | 10.100.88.4 | 10.10.30.10 |
| 2026-10-08T11:52:39.6965342Z | Inbound       | Allowed    | platformrule          | 10.100.88.4 | 10.10.30.10 |
| 2026-10-08T11:52:40.3326676Z | Inbound       | Denied     | defaultinbounddenyall | 10.100.88.4 | 10.10.30.10 |
| 2026-10-08T11:52:40.2187792Z | Inbound       | Allowed    | infra-vnettoany       | 10.100.88.4 | 10.10.30.10 |
```mermaid
sequenceDiagram
    participant SRC as Source VM (10.100.88.4)
    participant NSG as Azure NSG (Outbound)
    participant AFW as Azure Firewall
    participant VGW as Azure VPN Gateway
    participant ONPREM as On-Prem Firewall/Srv (10.10.30.10)

    Note over SRC, AFW: [Azure Cloud]
    SRC->>NSG: TCP Port 22 Request
    NSG-->>AFW: ALLOWED (allowvnetoutbound)
    AFW-->>VGW: ALLOWED (platformrule / infra-vnettoany)
    
    Note over VGW, ONPREM: [VPN Tunnel]
    VGW->>ONPREM: Encapsulated Packet Sent
    
    alt Successful Path (The "Allowed" Logs)
        ONPREM-->>VGW: Response (SYN-ACK)
        VGW-->>AFW: Return Packet
        AFW-->>SRC: Connection Established
    else Current Failure Path (The "Denied/No Response" Logs)
        ONPREM-x VGW: ❌ Blocked by On-Prem Firewall
        Note right of ONPREM: OR: No Route back to Azure IPs
        Note right of ONPREM: OR: Server OS Firewall blocks Port 22
    end

    Note over VGW: Return packet arriving without state...
    VGW-x SRC: ❌ 'defaultinbounddenyall' (Return packet dropped/rejected)
```
