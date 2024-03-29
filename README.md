# VM Snapshot Management Script

## Overview

This Bash script automates the management of virtual machine (VM) snapshots on a Proxmox VE (PVE) environment. It facilitates creating new snapshots for specified VMs and cleaning up old snapshots according to defined retention policies. The script operates with four parameters: VM ID, base snapshot name, snapshot retention hours, and weekly retention count.

## Prerequisites

- Proxmox VE (PVE) environment
- A VM set up in your PVE
- `jq` installed for JSON parsing
- Access to the PVE's command line interface

## Installation

1. **Download the Script**  
   Download the script to your Proxmox server. You can place it in a directory of your choice, for example, `/usr/local/bin`.

    ```bash
    wget -O /usr/local/bin/vm_snapshot_manager.sh https://github.com/rihokirss/ProxmoxSnapshots/raw/master/proxmox_snapshot.sh
    chmod +x /usr/local/bin/vm_snapshot_manager.sh
    ```

2. **Ensure Script Permissions**  
   Make sure the script is executable.

    ```bash
    chmod +x /usr/local/bin/vm_snapshot_manager.sh
    ```

## Usage

Run the script with the following parameters:

```bash
/usr/local/bin/vm_snapshot_manager.sh <VMID> <BASE_SNAPSHOT_NAME> <SNAPSHOT_RETENTION_HOURS> <WEEKLY_RETENTION_COUNT>
```
- `<VMID>`: The ID of the VM for which to manage snapshots.
- `<BASE_SNAPSHOT_NAME>`: A base name for the snapshots. The script will append the date and time to this base name for each snapshot.
- `<SNAPSHOT_RETENTION_HOURS>`: The number of hours to keep a snapshot before it's considered for deletion.
- `<WEEKLY_RETENTION_COUNT>`: The number of weeks during which the first snapshot of the week is kept.

## Adding to Crontab

To automate the running of this script, you can add it to your server's crontab. This allows you to schedule the script to run at regular intervals.

1. **Open Crontab**: Open your server's crontab for editing.

    ```bash
    crontab -e
    ```

2. **Add a Cron Job**: Add a line to the crontab file to schedule the script. For example, to run the script every day at 1 AM, you would add:

    ```bash
    0 1 * * * /usr/local/bin/vm_snapshot_manager.sh 101 "vm101-daily" 168 4
    ```

    This line schedules the script to run daily at 1 AM for VM with ID 101, using "vm101-daily" as the base snapshot name, retaining snapshots for 168 hours (7 days), and keeping the first snapshot of the week for 4 weeks.

3. **Save and Close**: Save the crontab file and exit the editor. The cron job is now scheduled.

## Notes

- Ensure that your Proxmox environment has sufficient storage space for snapshots according to your retention policies.
- Review the snapshots and retention policies periodically to adjust as needed based on storage availability and VM importance.

## Support

For issues or questions regarding the script, please refer to the [GitHub Issues](#) page for this project.

