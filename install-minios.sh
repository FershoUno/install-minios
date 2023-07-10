#!/bin/bash

#set -x

check_root(){
# Verificar si se está ejecutando como root
if [[ $(id -u) -eq 0 ]]; then
    # Si se está ejecutando como root, ejecutar el menú principal directament
	check_language_system
else
    # Si no se está ejecutando como root, solicitar autenticación de root usando pkexec y luego ejecutar el menú principal
    if pkexec true; then
        # Autenticación de root exitosa, ejecutar el menú principal
        check_language_system
    else
        # Autenticación de root fallida, mostrar mensaje de error y salir
        echo "No se pudo autenticar como root. El script se cerrará."
        exit 1
    fi
fi

}

# Function for Spanish installation
spanish_translate(){
	# Localization strings for Spanish
echo $welcome_es
	check_efi_run
	main_menu
}

# Function for Enlgish installation
english_translate(){
	# Localization strings for English
echo $welcome_en
	check_efi_run
	main_menu
}

# Function for Russian installation
russian_translate(){
	# Localization strings for Russian
echo $welcome_ru
	check_efi_run
	main_menu
}


# Get the system language
check_language_system(){

language_code=${LANG}
language_code=$(echo $language_code | cut -d "_" -f 1)
welcome_es="¡Bienvenido!"
welcome_en="Welcome!"
welcome_ru="Добро пожаловать!"

# Check the language and display the corresponding welcome message.
if [[ $language_code == "es" ]]; then
    spanish_translate
    echo $welcome_es
elif [[ $language_code == "en" ]]; then
    echo $welcome_en
    english_translate
elif [[ $language_code == "ru" ]]; then
    echo $welcome_ru
    russian_translate
else
    exit 0
fi


}


check_efi_run(){

if [ -d "/sys/firmware/efi" ]; then
  mensaje_efi="Estás iniciando con EFI"
else
  mensaje_efi="Estás iniciando sin EFI"
fi

}

list_disks(){

# Retreive the list of hard disk devices
devices_disk=$(lsblk -o NAME,SIZE -n -d -e 7,11 | awk '{print $1 "(" $2 ")"}')
devices_disk=$(echo $devices_disk | tr ' ' '!')
filesystem="Ext4!Fat32"
device_bootloader=$(lsblk -o NAME -n -d -e 7,11 | awk '{print $1}')
device_bootloader=$(echo $device_bootloader | tr ' ' '!')

}
###################################################################################3

format_and_install_minios() {
    local disk=$1
#    echo $disk
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

    show_main_menu
}

##############################################################################################

# Main Menu
main_menu() {
    list_disks
    selection=$(yad --form \
        --title="Menú de opciones" \
        --text="Seleccione las opciones de instalación:\n${mensaje_efi}" \
        --width=300 --height=200 \
       --buttons-layout="center" \
        --on-top \
        --form \
        --field="Seleccionar dispositivo:CB" "${devices_disk}" \
        --field="Seleccionar sistema de archivos:CB" "${filesystem}" \
        --button="Instalar":0 \
	--button="Cancel":1 \
	--button="Refresh Disks":2 )

function_button "$selection"
    # Retrieve the selected values
    selected_device_disk=$(echo "$selection" | cut -d"|" -f1)
    selected_filesystem=$(echo "$selection" | cut -d"|" -f2)

function_button "$selection"
}

function_button(){

local button_selected=$?
case $button_selected in
	0)
	echo $selected_device_disk
	echo $selected_filesystem
	;;
	1)
	echo "cancelar"
	exit 0
	;;
	2)
	echo "Refresh disk"
	main_menu
	;;
esac
}

check_root
