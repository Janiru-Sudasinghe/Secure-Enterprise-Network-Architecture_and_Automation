# Secure Enterprise Network Architecture & Automation

## Project Overview
This project demonstrates the design and implementation of a secure, segmented enterprise network infrastructure using **pfSense** and **CentOS/Enterprise Linux**. The primary focus was to simulate a real-world environment requiring strict traffic filtering, proxy management, high-availability web services, and automated disaster recovery.

**Key Competencies Demonstrated:**
* **Network Security:** Deep packet inspection, firewall rule creation, and DMZ segmentation.
* **Traffic Control:** Transparent proxying (Squid), content filtering (SquidGuard), and bandwidth shaping.
* **High Availability:** Weighted Round-Robin Load Balancing using Nginx.
* **Automation:** Bash scripting for incremental backups with rotation logic.

---

## 🏗️ 1. Network Topology & Segmentation

[cite_start]The infrastructure was deployed using VMware Workstation with four distinct isolated networks to simulate a secure corporate environment[cite: 36, 39].

| Network Zone | Subnet | Description |
| :--- | :--- | :--- |
| **WAN** | DHCP (NAT) | External Internet connection |
| **LAN (Server Farm)** | `10.0.0.0/24` | Hosted internal backend servers (Server A, B, C) |
| **LAN2 (Client)** | `192.168.3.0/24` | User workstation network |
| **DMZ** | `172.16.0.0/24` | Demilitarized zone for exposed services |

**[View Network Topology Diagram](diagrams/network_topology.png)**
**[View VMware Virtual Network Config](docs/01_vmware_network.png)**

---

## 🛡️ 2. Firewall & Perimeter Security (pfSense)

[cite_start]The core security gateway was built on **pfSense**, managing strict access control lists (ACLs) between zones[cite: 20].

### Key Configurations:
* [cite_start]**Interface Assignment:** Configured WAN, LAN, LAN2, and DMZ interfaces with static IPs[cite: 43].
* **Access Control:**
    * **LAN:** Allowed outgoing HTTP/HTTPS; [cite_start]Denied incoming traffic from LAN2[cite: 52, 53].
    * **LAN2:** Restricted access to specific ports (80, 443, 21); [cite_start]Allowed SSH to DMZ only[cite: 55, 56].
    * [cite_start]**DMZ:** Isolated zone with specific routing permissions[cite: 60].

**Evidence:**
* [Screenshot: pfSense Interface Status](docs/02_pfsense_interfaces.png)
* [Screenshot: LAN2 Firewall Rules](docs/03_firewall_rules_lan2.png)

---

## 🕵️ 3. Web Proxy & Traffic Shaping

[cite_start]To enforce corporate usage policies, a transparent proxy server was implemented using **Squid** and **SquidGuard**[cite: 22].

* [cite_start]**Content Filtering:** Configured Shalla List blacklists to block specific categories (e.g., social media, adult content)[cite: 89, 90].
* [cite_start]**Traffic Analysis:** Implemented **LightSquid** to generate daily usage reports per IP[cite: 68].
* [cite_start]**Bandwidth Management:** Applied Traffic Shapers (Limiters) to restrict LAN2 clients to **160Kbit/s** Up/Down[cite: 93].

**Evidence:**
* [Screenshot: SquidGuard ACL Configuration](docs/squidguard_config.png)
* [Screenshot: LightSquid Usage Report](docs/04_squid_proxy_report.png)
* [Screenshot: Bandwidth Speed Test Verification](docs/05_bandwidth_limiter.png)

---

## ⚖️ 4. High Availability Load Balancing

[cite_start]To optimize web resource utilization, a **Weighted Round-Robin** load balancer was deployed using **Nginx**[cite: 102].

* **Scenario:** Distributed traffic across three backend servers with varying capacities.
* **Algorithm:**
    * [cite_start]**Server A:** 50% traffic (Weight: 5) [cite: 110]
    * [cite_start]**Server B:** 30% traffic (Weight: 3) [cite: 111]
    * [cite_start]**Server C:** 20% traffic (Weight: 2) [cite: 112]

**Configuration Snippet (`nginx.conf`):**
```nginx
upstream backend_servers {
    server 10.0.0.1 weight=5;
    server 10.0.0.2 weight=3;
    server 10.0.0.3 weight=2;
}
