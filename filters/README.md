# Filters

## *potential-remote-login.rb*
potential-remote-login.rb - Filters event logs for potential remote login evidence.
*For a great reference, see this [Ponder The Bits](https://ponderthebits.com/2018/02/windows-rdp-related-event-logs-identification-tracking-and-investigation/) blog post by Jonathon Poling*
##### Security.evtx
    * Event ID 4624/4625 (User logon/failed logon)
    * Event ID 4634 (RDP disconnect or logoff)
    * Event ID 4647 (Formal logoff)
    * Event ID 4676 (Kerberos Authentication)
    * Event ID 4778/4779 (RDP session was reconnected/RDP session disconnected)
##### Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.evtx
    * Event ID 1149 (Just logs a successful network connection, not user authentication)
##### Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx
    * Event ID 21/22 (Remote desktop service logon succeeded/Remote desktop service shell started)
    * Event ID 23 (Remote desktop service formal logoff)
    * Event ID 24/25 (Remote desktop service disconnect/remote desktop service reconnect)
    * Event ID 39 (Remote desktop service session X has been disconnected by Y)
    * Event ID 40 (Remote desktop service session X has been disconnected for reason Y)
##### System.evtx
    * Event ID 9009 (User closed out an RDP connection)
##### Logon types
    * Type 3 (Network/SMB Authentication logon)
    * Type 8 (Cleartext network logon)
    * Type 10 (RDP/Terminal services)
