# Monitoring commands
--- This runbook lists common Linux commands to monitor system performance, including CPU, memory, disk, and network usage.
--- The goal is to help you quickly check server health and identify bottlenecks from the command line.

# Overview
--- The main monitoring areas are:

--- CPU utilization: How much processor time is being used.

--- Memory utilization: How much RAM and swap are in use.

--- Disk utilization: Filesystem usage and disk I/O activity.

--- Network utilization: Incoming and outgoing traffic on interfaces.


1. Check overall system performance

---  These commands give a live or summary view of the whole system.

```
  bash
  top
  htop
  vmstat 2
  uptime
  Definitions:

--- top — Displays real-time system statistics such as CPU usage, memory usage, load average, and running processes.

--- htop — An improved interactive version of top with a cleaner display and easier process management.

--- vmstat 2 — Shows system performance data every 2 seconds, including processes, memory, swap, I/O, and CPU activity.

--- uptime — Shows how long the system has been running and the current load average.

```

2. Check CPU utilization

--- These commands help inspect processor usage in detail.

```
  bash
  top
  mpstat -P ALL 1
  sar -u 1 5
  lscpu

```
#  Definitions:

--- top — Shows CPU usage by process in real time.

--- mpstat -P ALL 1 — Displays CPU usage for all processor cores every 1 second.

--- sar -u 1 5 — Reports CPU utilization statistics every 1 second for 5 intervals.

--- lscpu — Prints CPU architecture details such as core count, threads, and model.

3. Check memory utilization

--- These commands help you inspect RAM and swap usage.

```
  free -h
  top -o %MEM
  vmstat 2
  cat /proc/meminfo

```
#  Definitions:

--- free -h — Shows total, used, free, shared, cache, and available memory in human-readable format.

--- top -o %MEM — Starts top sorted by memory usage so the highest memory-consuming processes appear first.

--- vmstat 2 — Helps detect memory pressure, swap activity, and system load.

--- cat /proc/meminfo — Prints detailed kernel-level memory information.

4. Check disk utilization

--- These commands are useful for both disk space and disk I/O monitoring.

```
  df -h
  du -sh /var/*
  iostat -xz 1
  sudo iotop
  lsblk

```

#  Definitions:

--- df -h — Shows disk space usage of mounted filesystems in human-readable format.

--- du -sh /var/* — Shows the size of directories under /var to help find large disk consumers.

--- iostat -xz 1 — Displays extended disk I/O statistics every 1 second.

--- iotop — Shows which processes are generating disk I/O in real time; usually requires sudo.

--- lsblk — Lists block devices such as disks and partitions.


5. Check network utilization

--- These commands help monitor traffic and interface activity.

```

  sar -n DEV 1 5
  ip -s link
  ss -tulnp
  nload

```
#  Definitions:

--- sar -n DEV 1 5 — Shows network interface statistics every 1 second for 5 intervals.

--- ip -s link — Displays packet and byte statistics for network interfaces.

--- ss -tulnp — Lists listening TCP/UDP ports and associated processes.

--- nload — Provides a simple live view of incoming and outgoing network traffic.

6. Install required tools

--- Some of these utilities are not installed by default on all Linux systems.

```

  sudo apt update
  sudo apt install htop sysstat iotop nload

```

# Definitions:

--- sudo apt update — Refreshes the package index from configured repositories.

--- sudo apt install htop sysstat iotop nload — Installs monitoring tools; sysstat provides iostat, mpstat, and sar.

#  Notes
--- Use sudo iotop if you get a permission or netlink error.

--- sysstat is important because it provides mpstat, iostat, and sar.

--- For quick checks, the most useful command set is:

```

  top
  free -h
  df -h
  iostat -xz 1
  sar -n DEV 1 5

```
