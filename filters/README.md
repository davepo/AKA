# Filters

*For a great reference, see this [Ponder The Bits](https://ponderthebits.com/2018/02/windows-rdp-related-event-logs-identification-tracking-and-investigation/) blog post by Jonathon Poling*

## *potential-remote-login.rb*
potential-remote-login.rb - Filters event logs for potential remote login evidence.

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
##### Logon types (Applied to Security log ID's 4624,4634)
   * Type 3 (Network/SMB Authentication logon)
   * Type 7 (Screen lock/unlock)
   * Type 8 (Cleartext network logon)
   * Type 10 (RDP/Terminal services)

## *potential-psexec-activity.rb*
potential-psexec-activity.rb - Filters event logs for potential psexec activity evidence.

##### Security.evtx
*Source System*
   * Event ID 4688/4689 (Process created/exited process name "psexec.exe")
*Destination System*
   * Event ID 5156 (Windows filtering platform allowed connect. With ports ":135" and ":445")
   * Event ID 5140 (Network share object accessed. Include's admin share "\??\C:\Windows")
   * Event ID 4672 (Special privileges assigned.)
   * Event ID 4656/4663 (Requested handle/Attempted access to an object named "psexecsvc.exe")
   * Event ID 5140 (Network share object accessed. Include's admin share "\\*\IPC$")
   * Event ID 5145 (Network share objected checked if client can be granted access. Includes "psexecsvc" and "\??\C:\Windows")
   * Event ID 4656/4660/4658 (Handle to an object was requested/deleted/closed. Includes "psexecsvc.exe")
##### System.evtx
*Destination System*
   * Event ID 7045 (A service was installed. Includes "psexecsvc")
   * Event ID 7036 (A service state changed.)

## *potential-wmic-activity.rb*
potential-wmic-activity.rb - Filters event logs for potential evidence of wmic activity.

##### Security.evtx
   * Event ID 4688/4689 (Process created/exited process name "wmic.exe")

## *potential-powershell-activity.rb*
potential-powershell-activity.rb - Filters event logs for potential evidence of powershell activity.

##### Security.evtx
   * Event ID 4688/4689 (Process created/exited process name "powershell.exe")
   * Event ID 5156 (Windows filtering platform allowed connect. With "powershell.exe" or ports "47001",  "5985", or "5896")
   * Event ID 4624 (User logon with type "3")
   * Event ID 4634 (RDP disconnect or logoff with type "3")

##### Powershell.evtx
   * The whole log, if it exists.