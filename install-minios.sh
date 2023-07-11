#!/bin/bash

set -x

# Path to MiniOS live CD
PATH_MINIOS_LIVE_CD="/run/initramfs/memory/data"

check_root() {
    # Check if you are running as root
    if [[ $(id -u) -eq 0 ]]; then
        # If you are running as root, run the main menu directly
        check_language_system
    else
        # If you are not running as root, request root authentication using pkexec and then run the main menu
        if pkexec true; then
            # Root authentication successful, run main menu
            check_language_system
        else
            # Root authentication failed, show error message and exit
            echo "Failed to authenticate as root. The script will exit"
            exit 1
        fi
    fi

}

# Function for Spanish installation
spanish_translate() {
    # Localization strings for Spanish
    EFI_TEXT_YES="Estás iniciando con EFI"
    EFI_TEXT_NO="Estás iniciando sin EFI"
    TITLE_MAIN="Menú de opciones"
    TITLE_MAIN_TEXT="Seleccione las opciones de instalación"
    BUTTON_TEXT_INSTALL="Instalar"
    BUTTON_TEXT_CANCEL="Cancelar"
    BUTTON_TEXT_RELOAD_DISKS="Recargar Discos"
    MAIN_SELECT_DEVICE_INSTALL="Seleccionar dispositivo"
    MAIN_SELECT_FILESYSTEM="Seleccionar sistema de archivos"

    TEXT_FORMAT_0_10="Formateando el disco /dev/$disk con tabla de partición MBR y sistema de archivos Ext4..."
    TEXT_FORMAT_30_40="# Creando el directorio /mnt/${disk}1..."
    TEXT_FORMAT_60_70="# Montando el disco en /mnt/${disk}1..."
    TEXT_FORMAT_80_90="# Copiando los archivos de instalación de MiniOS a /mnt/${disk}1..."
    TEXT_FORMAT_100="# Ejecutando el script de instalación de MiniOS..."
    TITLE_INSTALLING="Instalando MiniOS"
    TITLE_TEXT_INSTALLING="Iniciando la instalación de MiniOS en el disco /dev/$disk..."
    TITLE_FINISH="Instalación completa"
    TITLE_TEXT_FINISH1="La instalación de MiniOS en el disco"
    TITLE_TEXT_FINISH2="se ha completado correctamente."
    TITLE_ERROR="Error"
    TITLE_TEXT_ERROR="Se produjo un error durante la instalación de MiniOS en el disco"

    MESSAGE_NOT_FOUND_FILESYSTEM="Sistema de archivo no encontrado o no valido"
    MESSAGE_FORMAT_DISK="Formateo exitoso!"
    check_efi_run
    main_menu
}

# Function for Enlgish installation
english_translate() {
    # Localization strings for English

    EFI_TEXT_YES="You are booting with EFI"
    EFI_TEXT_NO="You are booting without EFI"
    TITLE_MAIN="Options Menu"
    TITLE_MAIN_TEXT="Select installation options"
    BUTTON_TEXT_INSTALL="Install"
    BUTTON_TEXT_CANCEL="Cancel"
    BUTTON_TEXT_RELOAD_DISKS="Reload Disks"
    MAIN_SELECT_DEVICE_INSTALL="Select device"
    MAIN_SELECT_FILESYSTEM="Select filesystem"

    TEXT_FORMAT_0_10="Formatting disk /dev/$disk with MBR partition table and Ext4 file system..."
    TEXT_FORMAT_30_40="# Creating directory /mnt/${disk}1..."
    TEXT_FORMAT_60_70="# Mounting the disk to /mnt/${disk}1..."
    TEXT_FORMAT_80_90="# Copying MiniOS installation files to /mnt/${disk}1..."
    TEXT_FORMAT_100="# Running MiniOS installation script..."
    TITLE_INSTALLING="Installing MiniOS"
    TITLE_TEXT_INSTALLING="Starting installation of MiniOS on disk /dev/$disk..."
    TITLE_FINISH="Installation Complete"
    TITLE_TEXT_FINISH1="Installation of MiniOS on disk"
    TITLE_TEXT_FINISH2="has been completed successfully."
    TITLE_ERROR="Error"
    TITLE_TEXT_ERROR="An error occurred during the installation of MiniOS on disk"

    check_efi_run
    main_menu
}

# Function for Russian installation
russian_translate() {
    # Localization strings for Russian

    EFI_TEXT_YES="Вы загружаетесь с EFI"
    EFI_TEXT_NO="Вы загружаетесь без EFI"
    TITLE_MAIN="Меню опций"
    TITLE_MAIN_TEXT="Выберите опции установки"
    BUTTON_TEXT_INSTALL="Установить"
    BUTTON_TEXT_CANCEL="Отмена"
    BUTTON_TEXT_RELOAD_DISKS="Перезагрузить диски"
    MAIN_SELECT_DEVICE_INSTALL="Выберите устройство"
    MAIN_SELECT_FILESYSTEM="Выберите файловую систему"

    TEXT_FORMAT_0_10="Форматирование диска /dev/$disk с таблицей разделов MBR и файловой системой Ext4..."
    TEXT_FORMAT_30_40="# Создание каталога /mnt/${disk}1..."
    TEXT_FORMAT_60_70="# Монтирование диска в /mnt/${disk}1..."
    TEXT_FORMAT_80_90="# Копирование файлов установки MiniOS в /mnt/${disk}1..."
    TEXT_FORMAT_100="# Запуск скрипта установки MiniOS..."
    TITLE_INSTALLING="Установка MiniOS"
    TITLE_TEXT_INSTALLING="Начало установки MiniOS на диск /dev/$disk..."
    TITLE_FINISH="Установка завершена"
    TITLE_TEXT_FINISH1="Установка MiniOS на диск"
    TITLE_TEXT_FINISH2="была успешно завершена."
    TITLE_ERROR="Ошибка"
    TITLE_TEXT_ERROR="Во время установки MiniOS на диск произошла ошибка"

    check_efi_run
    main_menu
}

# Get the system language
check_language_system() {

    language_code=${LANG}
    language_code=$(echo $language_code | cut -d "_" -f 1)

    # Check the language and display the corresponding welcome message.
    if [[ $language_code == "es" ]]; then
        spanish_translate
    elif [[ $language_code == "en" ]]; then
        english_translate
    elif [[ $language_code == "ru" ]]; then
        russian_translate
    else
        exit 0
    fi

}

check_efi_run() {

    if [ -d "/sys/firmware/efi" ]; then
        MESSAGE_EFI="$EFI_TEXT_YES"
    else
        MESSAGE_EFI="$EFI_TEXT_NO"
    fi

}

list_disks() {

    # Retreive the list of hard disk devices
    devices_disk=$(lsblk -o NAME,SIZE -n -d -I 8,259,252 | awk '{print $1 "(" $2 ")"}')
    devices_disk=$(echo $devices_disk | tr ' ' '!')
    filesystem="Ext4!Fat32!btrfs!xfs"
    #device_bootloader=$(lsblk -o NAME -n -d -I 8,259,252 | awk '{print $1}')
    #device_bootloader=$(echo $device_bootloader | tr ' ' '!')

}
###################################################################################3

partition_disk() {
    local disk="$1"
    disk=$(echo $disk | cut -d "(" -f 1)
    echo $disk
    echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk /dev/"$disk"
}

force_delete_partiton_disk(){
    local disk="$1"
    disk=$(echo $disk | cut -d "(" -f 1)
    echo $disk
    echo -e "d\nw" | sudo fdisk /dev/$disk
}


format_partition() {
    local disk="$1"
    disk=$(echo $disk | cut -d "(" -f 1)
    echo $disk

    local partition="/dev/${disk}1"
    local filesystem="$2"
    local label="MiniOS System"

    if [ "$filesystem" = "Ext4" ]; then
        sudo mkfs.ext4 -L "$label" "$partition"
    elif [ "$filesystem" = "Fat32" ]; then
        sudo mkfs.mkfs.fat -F32 -n "$label" "$partition"
    elif [ "$filesystem" = "btrfs" ]; then
        sudo mkfs.mkfs.btrfs -L "$label" "$partition"
    elif [ "$filesystem" = "xfs" ]; then
        sudo mkfs.xfs -L "$label" "$partition"
    else
        echo "$MESSAGE_NOT_FOUND_FILESYSTEM: $filesystem"
    fi
}

mount_device(){
    local disk="$1"
    disk=$(echo $disk | cut -d "(" -f 1)
    echo $disk
    sudo mkdir -p /mnt/${disk}1
    sudo mount /dev/${disk}1 /mnt/${disk}1

}

copy_minios() {
    local disk="$1"
    disk=$(echo $disk | cut -d "(" -f 1)
    echo $disk
    sudo cp -R $PATH_MINIOS_LIVE_CD/* /mnt/${disk}1/

}

run_script_bootinst() {
    local disk="$1"
    disk=$(echo $disk | cut -d "(" -f 1)
    echo $disk
    sudo sh /mnt/${disk}1/minios/boot/bootinst.sh
}

# Function disabled
process_install_minios() {
    local disk=$1

    disk=$(echo $disk | cut -d "(" -f 1)

    echo $disk
    (
        echo "0" # Initial value of the progress bar
        echo "$TEXT_FORMAT_0_10"
        echo "10"

        # Format the disk with MBR partition table and Ext4 file system
        echo -e "o\nn\np\n1\n\n\nt\n83\nw" | fdisk /dev/$disk
        mkfs.$FORMAT_FILESYSTEM /dev/${disk}1 -L "MiniOS System"

        echo "30"
        echo "$TEXT_FORMAT_30_40"
        echo "40"

        # Create the /mnt/${disk}1 directory
        mkdir -p /mnt/${disk}1

        echo "60"
        echo "$TEXT_FORMAT_60_70"
        echo "70"

        # Mount the disk to /mnt/${disk}1
        mount /dev/${disk}1 /mnt/${disk}1

        echo "80"
        echo "$TEXT_FORMAT_80_90"
        echo "90"

        # Copy MiniOS installation files to /mnt/${disk}
        cp -R $PATH_MINIOS_LIVE_CD/* /mnt/${disk}1/

        echo "100"
        echo "$TEXT_FORMAT_100"
        sh /mnt/${disk}1/minios/boot/bootinst.sh
    ) | yad --progress --title="$TITLE_INSTALLING" --text="$TITLE_TEXT_INSTALLING" --auto-close --auto-kill

    if [ $? -eq 0 ]; then
        yad --info --title="$TITLE_FINISH" --text="$TITLE_TEXT_FINISH1 /dev/$disk $TITLE_TEXT_FINISH2" --no-wrap
        force_exit
    else
        yad --error --title="$TITLE_ERROR" --text="$TITLE_TEXT_ERROR /dev/$disk ."
    fi

    main_menu
}

##############################################################################################

# Main Menu
main_menu() {
    list_disks
    selection=$(yad --form \
        --title="$TITLE_MAIN" \
        --text="$TITLE_MAIN_TEXT:\n${MESSAGE_EFI}" \
        --width=300 --height=200 \
        --buttons-layout="center" \
        --on-top \
        --form \
        --field="$MAIN_SELECT_DEVICE_INSTALL:CB" "${devices_disk}" \
        --field="$MAIN_SELECT_FILESYSTEM:CB" "${filesystem}" \
        --button="$BUTTON_TEXT_INSTALL":0 \
        --button="$BUTTON_TEXT_CANCEL":1 \
        --button="$BUTTON_TEXT_RELOAD_DISKS":2 )

    # Retrieve the selected values
    selected_device_disk=$(echo "$selection" | cut -d"|" -f1)
    selected_filesystem=$(echo "$selection" | cut -d"|" -f2)
    function_button "$selection"
}

function_button() {

    local button_selected=$?
    case $button_selected in
    0)
        echo $selected_device_disk
        partition_disk "$selected_device_disk"
        format_partition "$selected_device_disk" "$selected_filesystem"
        mount_device "$selected_device_disk"
        copy_minios "$selected_device_disk"
        run_script_bootinst "$selected_device_disk"
        ;;
    1)

        exit 0
        ;;
    2)

        main_menu
        ;;
    esac
}

check_root
