#!/bin/bash

# Path to MiniOS live CD
PATH_MINIOS_LIVE_CD="/run/initramfs/memory/data"

# Function to handle force exit (Ctrl + C)
force_exit() {
    zenity --info --title="$INFO" --text="$MESSAGE_TEXT_FORCE_EXIT" --no-wrap
    exit 0
}

# Trap signals to call force_exit function
trap force_exit SIGINT SIGTERM

# Function for Spanish installation
spanish_install() {
    # Localization strings for Spanish
    MAIN_MENU="Menú principal"
    MAIN_OPTION_COLUMN="Opción"
    MAIN_TEXT="Seleccione una opción"
    MAIN_OPTION_ONE="Seleccionar disco e instalar MiniOS"
    EXIT="Salir"
    SELECT_DISK_TITLE="Seleccionar disco"
    COLUMN_DISK="Disco"
    SELECT_DISK_TEXT="Seleccione un disco"
    TITLE_WARNING="Advertencia"
    TEXT_WARNING1="Desea instalar MiniOS en el disco ->"
    TEXT_WARNING2="?\n\nAdvertencia: Se formateará y se perderán todos los datos en el disco."
    TEXT_FORMAT_0_10="Formateando el disco /dev/$disk con tabla de partición MBR y sistema de archivos Ext4..."
    TEXT_FORMAT_30_40="# Creando el directorio /media/sda1..."
    TEXT_FORMAT_60_70="# Montando el disco en /media/sda1..."
    TEXT_FORMAT_80_90="# Copiando los archivos de instalación de MiniOS a /media/sda1..."
    TEXT_FORMAT_100="# Ejecutando el script de instalación de MiniOS..."
    TITLE_INSTALLING="Instalando MiniOS"
    TITLE_TEXT_INSTALLING="Iniciando la instalación de MiniOS en el disco /dev/$disk..."
    TITLE_FINISH="Instalación completa"
    TITLE_TEXT_FINISH1="La instalación de MiniOS en el disco"
    TITLE_TEXT_FINISH2="se ha completado correctamente."
    TITLE_ERROR="Error"
    TITLE_TEXT_ERROR="Se produjo un error durante la instalación de MiniOS en el disco"
    MESSAGE_TEXT_FORCE_EXIT="Gracias por utilizar el instalador de MiniOS. ¡Hasta luego!"
    INFO="Información"
    show_main_menu
}

# Function for English installation
english_install() {
    # Localization strings for English
    MAIN_MENU="Main Menu"
    MAIN_OPTION_COLUMN="Option"
    MAIN_TEXT="Please select an option"
    MAIN_OPTION_ONE="Select disk and install MiniOS"
    EXIT="Exit"
    SELECT_DISK_TITLE="Select Disk"
    COLUMN_DISK="Disk"
    SELECT_DISK_TEXT="Please select a disk"
    TITLE_WARNING="Warning"
    TEXT_WARNING1="Do you want to install MiniOS on disk ->"
    TEXT_WARNING2="?\n\nWarning: This will format the disk and all data on it will be lost."
    TEXT_FORMAT_0_10="Formatting disk /dev/$disk with MBR partition table and Ext4 file system..."
    TEXT_FORMAT_30_40="# Creating directory /media/sda1..."
    TEXT_FORMAT_60_70="# Mounting disk to /media/sda1..."
    TEXT_FORMAT_80_90="# Copying MiniOS installation files to /media/sda1..."
    TEXT_FORMAT_100="# Running MiniOS installation script..."
    TITLE_INSTALLING="Installing MiniOS"
    TITLE_TEXT_INSTALLING="Starting installation of MiniOS on disk /dev/$disk..."
    TITLE_FINISH="Installation Complete"
    TITLE_TEXT_FINISH1="Installation of MiniOS on disk"
    TITLE_TEXT_FINISH2="has been completed successfully."
    TITLE_ERROR="Error"
    TITLE_TEXT_ERROR="An error occurred during the installation of MiniOS on disk"
    MESSAGE_TEXT_FORCE_EXIT="Thank you for using the MiniOS installer. Goodbye!"
    INFO="Information"
    show_main_menu
}

# Function for Russian installation
russian_install() {
    # Localization strings for Russian
    MAIN_MENU="Главное меню"
    MAIN_OPTION_COLUMN="Опция"
    MAIN_TEXT="Пожалуйста, выберите опцию"
    MAIN_OPTION_ONE="Выбрать диск и установить MiniOS"
    EXIT="Выход"
    SELECT_DISK_TITLE="Выбрать диск"
    COLUMN_DISK="Диск"
    SELECT_DISK_TEXT="Пожалуйста, выберите диск"
    TITLE_WARNING="Предупреждение"
    TEXT_WARNING1="Хотите установить MiniOS на диск ->"
    TEXT_WARNING2="?\n\nПредупреждение: Диск будет отформатирован, и все данные на нем будут потеряны."
    TEXT_FORMAT_0_10="Форматирование диска /dev/$disk с таблицей разделов MBR и файловой системой Ext4..."
    TEXT_FORMAT_30_40="# Создание каталога /media/sda1..."
    TEXT_FORMAT_60_70="# Монтирование диска в /media/sda1..."
    TEXT_FORMAT_80_90="# Копирование файлов установки MiniOS в /media/sda1..."
    TEXT_FORMAT_100="# Запуск скрипта установки MiniOS..."
    TITLE_INSTALLING="Установка MiniOS"
    TITLE_TEXT_INSTALLING="Начало установки MiniOS на диск /dev/$disk..."
    TITLE_FINISH="Установка завершена"
    TITLE_TEXT_FINISH1="Установка MiniOS на диск"
    TITLE_TEXT_FINISH2="завершена успешно."
    TITLE_ERROR="Ошибка"
    TITLE_TEXT_ERROR="Во время установки MiniOS на диск произошла ошибка"
    MESSAGE_TEXT_FORCE_EXIT="Спасибо за использование установщика MiniOS. До свидания!"
    INFO="Информация"
    show_main_menu
}

language_select() {

    # Language selection dialog
    language=$(zenity --list --title="MiniOS Installer" --text="Select the installer language:" --column="Language" "Español" "English" --height=200 --width=250)

    # Execute function based on language selection
    case $language in
    "Español")
        spanish_install
        ;;
    "English")
        english_install
        ;;
    *)
        force_exit
        #zenity --error --text="Invalid option. Please select a valid language."
        #language_select
        ;;
    esac

}

# Function to display the main menu
show_main_menu() {
    CHOICE=$(zenity --list --title="$MAIN_MENU" --column="$MAIN_OPTION_COLUMN" --text="$MAIN_TEXT" \
        "$MAIN_OPTION_ONE" "$EXIT")

    case $CHOICE in
    "$MAIN_OPTION_ONE")
        select_disk_and_install
        ;;
    "$EXIT")
        force_exit
        ;;
    *)
        show_main_menu
        ;;
    esac
}

# Function to select a disk and perform MiniOS installation
select_disk_and_install() {
    DISKS=$(lsblk -o NAME,SIZE -n -d -e 7,11 | awk '{print $1 "(" $2 ")"}')

    SELECTED_DISK=$(zenity --list --title="$SELECT_DISK_TITLE" --column="$COLUMN_DISK" --text="$SELECT_DISK_TEXT" ${DISKS})

    if [ -z "$SELECTED_DISK" ]; then
        show_main_menu
    else

        zenity --question --title="$TITLE_WARNING" --text="$TEXT_WARNING1 /dev/$SELECTED_DISK $TEXT_WARNING2" --no-wrap
        SELECTED_DISK=$(echo $SELECTED_DISK | cut -d "(" -f 1)
        case $? in
        0)

            format_and_install_minios "$SELECTED_DISK"
            ;;
        1)
            show_main_menu
            ;;
        3)
        trap force_exit SIGINT SIGTERM
            
        esac
    fi
}

# Function to format the selected disk and install MiniOS
format_and_install_minios() {
    local disk=$1
    echo $disk

    (
        echo "0" # Initial value of the progress bar
        echo "$TEXT_FORMAT_0_10"
        echo "10"

        # Format the disk with MBR partition table and Ext4 file system
        echo -e "o\nn\np\n1\n\n\nt\n83\nw" | fdisk /dev/$disk
        mkfs.ext4 /dev/${disk}1 -L "MiniOS System"

        echo "30"
        echo "$TEXT_FORMAT_30_40"
        echo "40"

        # Create the /media/sda1 directory
        mkdir -p /media/sda1

        echo "60"
        echo "$TEXT_FORMAT_60_70"
        echo "70"

        # Mount the disk to /media/sda1
        mount /dev/${disk}1 /media/sda1

        echo "80"
        echo "$TEXT_FORMAT_80_90"
        echo "90"

        # Copy MiniOS installation files to /media/sda
        cp -R $PATH_MINIOS_LIVE_CD/* /media/sda1/

        echo "100"
        echo "$TEXT_FORMAT_100"
        sh /media/sda1/minios/boot/bootinst.sh
    ) | zenity --progress --title="$TITLE_INSTALLING" --text="$TITLE_TEXT_INSTALLING" --auto-close --auto-kill

    if [ $? -eq 0 ]; then
        zenity --info --title="$TITLE_FINISH" --text="$TITLE_TEXT_FINISH1 /dev/$disk $TITLE_TEXT_FINISH2" --no-wrap
    else
        zenity --error --title="$TITLE_ERROR" --text="$TITLE_TEXT_ERROR /dev/$disk ."
    fi

    show_main_menu
}

# Language menu
language_select

# Display the main menu
show_main_menu
