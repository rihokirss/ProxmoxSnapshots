#!/bin/bash

# Kontrolli, kas kõik vajalikud argumendid on antud ja korrektsed
if [ $# -ne 4 ]; then
    echo "Kasutamine: $0 <VMID> <BASE_SNAPSHOT_NAME> <SNAPSHOT_RETENTION_HOURS> <WEEKLY_RETENTION_COUNT>"
    exit 1
fi

VMID=$1
BASE_SNAPSHOT_NAME=$2
SNAPSHOT_RETENTION_HOURS=$3
WEEKLY_RETENTION_COUNT=$4

# Kontrolli, kas SNAPSHOT_RETENTION_HOURS ja WEEKLY_RETENTION_COUNT on positiivsed täisarvud
if ! [[ $SNAPSHOT_RETENTION_HOURS =~ ^[0-9]+$ ]] || ! [[ $WEEKLY_RETENTION_COUNT =~ ^[0-9]+$ ]]; then
    echo "SNAPSHOT_RETENTION_HOURS ja WEEKLY_RETENTION_COUNT peavad olema positiivsed täisarvud."
    exit 1
fi

# Funktsioon snapshot'i loomiseks
create_snapshot() {
    local snapshot_name="${BASE_SNAPSHOT_NAME}-$(date +%Y%m%d-%H%M)"
    # Loo snapshot (näide QEMU VM-ile)
    pvesh create /nodes/$(hostname)/qemu/${VMID}/snapshot -snapname ${snapshot_name}
    echo "Snapshot ${snapshot_name} for VM ID ${VMID} created."
}

# Funktsioon vanade snapshot'ide kustutamiseks
cleanup_snapshots() {
    local current_time=$(date +%s)

    # Eeldame, et pvesh käsk tagastab korrektse JSON-i
    local snapshots_json=$(pvesh get /nodes/$(hostname)/qemu/${VMID}/snapshot --output-format json-pretty)

    # Töötle iga snapshot
    echo "$snapshots_json" | jq -r '.[] | select(.name | startswith("'"$BASE_SNAPSHOT_NAME"'-")) | [.name, .snaptime] | @tsv' | while IFS=$'\t' read -r snap_name snap_time; do

        # Arvuta vanus tundides
        local age_hours=$(( ($current_time - $snap_time) / 3600 ))

        # Kustuta snapshot'id, mis on vanemad kui SNAPSHOT_RETENTION_HOURS, välja arvatud nädala esimesed vastavalt WEEKLY_RETENTION_COUNT'ile
        if [ $age_hours -gt $SNAPSHOT_RETENTION_HOURS ]; then
            local snap_year_week=$(date -d "@$snap_time" +%Y-%V)
            local current_year_week=$(date +%Y-%V)
            local week_diff=$(( $(date -d $current_year_week +%s) - $(date -d $snap_year_week +%s) ))
            week_diff=$(( week_diff / (3600 * 24 * 7) ))

            if [ $week_diff -ge $WEEKLY_RETENTION_COUNT ]; then
                # Kustuta snapshot
                pvesh delete /nodes/$(hostname)/qemu/${VMID}/snapshot/${snap_name}
                echo "Snapshot ${snap_name} for VM ID ${VMID} deleted."
            fi
        fi
    done
}
# Loo uus snapshot
create_snapshot

# Korista vanad snapshot'id
cleanup_snapshots