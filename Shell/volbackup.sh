#!/bin/bash -e

main() {
    local base_dir="/mnt/f7a5c9cd-70c8-4f3c-9df9-bb13086437a2/backup/"
    local logfile="/var/log/volume_backup.log"
    local retentiondays="28"
    local resultfile="/home/dietpi/backup_results.log"

    if [ "$EUID" -ne 0 ]; then
      echo "Please run as root"
      exit 1
    fi

    if [ ! -d "$base_dir" ]; then
      echo "$(date +%Y-%m-%d-%H:%M:%S) - $base_dir is not accessible. Script is exiting." | tee -a "$logfile"
      exit 1
    fi

    echo "$(date +%Y-%m-%d-%H:%M:%S) - Starting Backup Script" | tee "$logfile"

    prune_backups() {
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Pruning Backups older than ${retentiondays} days" | tee -a "$logfile"
        echo "Files Identified for Deletion:" $(su root -c "find $base_dir -mtime +${retentiondays}" | wc -l) | tee -a "$logfile"
        su root -c "find $base_dir -mtime +${retentiondays} -delete" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Pruning Complete" | tee -a "$logfile"
    }

    start_adguard_bak() {
        local containername="adguard"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from adguard -v $base_dir/adguard:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-adguard_backup.tar /opt/adguardhome/conf" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    start_appdaemon_bak() {
        local containername="appdaemon"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from appdaemon -v $base_dir/appdaemon:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-appdaemon_backup.tar /conf/appdaemon.yaml /conf/apps" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    start_mqtt_bak() {
        local containername="mqtt"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from mqtt -v $base_dir/mqtt:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-mqtt_backup.tar /mosquitto/config" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    start_rtlamr2mqtt_bak() {
        local containername="rtlamr2mqtt"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from rtlamr2mqtt -v $base_dir/rtlamr2mqtt:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-rtlamr2mqtt_backup.tar /etc/rtlamr2mqtt.yaml" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    start_homeassistant_bak() {
        local containername="homeassistant"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from homeassistant -v $base_dir/homeassistant:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-homeassistant_backup.tar /config" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    start_bookstack_bak() {
        local containername="bookstack"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop ${containername}_db" &>> "$logfile"
        su root -c "docker stop $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from bookstack_db -v $base_dir/bookstack_db:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-bookstack_db_backup.tar /config" &>> "$logfile"
        su root -c "docker run --rm --volumes-from bookstack -v $base_dir/bookstack:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-bookstack_backup.tar /config" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start ${containername}_db" &>> "$logfile"
        su root -c "docker start $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    start_homer_bak() {
        local containername="homer"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from homer -v $base_dir/homer:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-homer_backup.tar /www/assets" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    start_nodered_bak() {
        local containername="nodered"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from nodered -v $base_dir/nodered:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-nodered_backup.tar /data" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    start_swag_bak() {
        local containername="swag"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from swag -v $base_dir/swag:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-swag_backup.tar /config" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    start_phpipam_bak() {
        local containername="phpipam"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop ${containername}-mariadb" &>> "$logfile"
        su root -c "docker stop ${containername}-web" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from phpipam-mariadb -v $base_dir/phpipam-mariadb:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-phpipam-mariadb_backup.tar /var/lib/mysql" &>> "$logfile"
        su root -c "docker run --rm --volumes-from phpipam-web -v $base_dir/phpipam-web:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-phpipam-web_backup.tar /phpipam/css/images/logo" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start ${containername}-mariadb" &>> "$logfile"
        su root -c "docker start ${containername}-web" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    start_portainer_bak() {
        local containername="portainer"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Start Backup - $containername" | tee -a "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - Stopping $containername Container" | tee -a "$logfile"
        su root -c "docker stop $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container stopped. Starting backup" | tee -a "$logfile"
        su root -c "docker run --rm --volumes-from $containername -v $base_dir/$containername:/backup ubuntu tar cvf /backup/`date +%Y%m%d%H%M%S`-weekly-backup-${containername}_backup.tar /data" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername backup complete" | tee -a "$logfile"
        su root -c "docker start $containername" &>> "$logfile"
        echo "$(date +%Y-%m-%d-%H:%M:%S) - $containername container started" | tee -a "$logfile"
    }

    prune_backups
    start_adguard_bak
    start_appdaemon_bak
    start_mqtt_bak
    start_rtlamr2mqtt_bak
    start_homeassistant_bak
    start_bookstack_bak
    start_homer_bak
    start_nodered_bak
    start_phpipam_bak
    start_portainer_bak

    echo "$(date +%Y-%m-%d-%H:%M:%S) - Backup Script Complete" | tee -a "$logfile"
    echo "$(date +%Y-%m-%d-%H:%M:%S) - Backup Script Successfully Completed" | tee -a "$resultfile"
}
main
