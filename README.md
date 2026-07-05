Are you sick of Darktide taking 10 minutes to load into the Mourningstar? 
I stopped playing for a year due to this issue, and it has never been fixed.

Looking into Console Logs (AppData/Roaming/Fatshark/Darktide/console_logs/) I found endless spam of:

14:55:00.986 error:   [DnsResolver] GetAddrInfoExW failed in GetAddressInfoComplete with error(11001): Host not found. 
14:55:00.986 warning: [PingSystem] Failed to resolve ping DNS hostname: echo-prod-ga-aws-eu-west-1.atoma.cloud

 This shows that the in game networking was failing to do any DNS lookup, wasting all that time.
 I'm not sure why the game does this, but as a crude workaround, if we just lookup all these addresses first and store them in the hosts file, Darktide doesn't have to try (and fail) to do it itself.

 Simply run this script, and it will fill the hosts file at /etc/hosts with all Darktide servers like this:

BEGIN darktide-dns-fix
13.247.40.120 echo-prod-aws-af-south-1.atoma.cloud
43.198.253.103 echo-prod-aws-ap-east-1.atoma.cloud
35.79.217.49 echo-prod-aws-ap-northeast-1.atoma.cloud
54.180.27.86 echo-prod-aws-ap-northeast-2.atoma.cloud
13.235.131.156 echo-prod-aws-ap-south-1.atoma.cloud

The game now loads in 30 seconds instead of 10 minutes.
Run this script each time you play so the addresses are updated.
