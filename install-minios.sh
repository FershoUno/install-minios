#!/bin/bash

# variables
PATH_MINIOS_LIVE_CD="/run/initramfs/memory/data"


# Función para mostrar el menú principal
show_main_menu() {
    CHOICE=$(zenity --list --title="Menú principal" --column="Opción" --text="Seleccione una opción" \
                    "Seleccionar disco e instalar MiniOS" "Salir")

    case $CHOICE in
        "Seleccionar disco e instalar MiniOS")
            select_disk_and_install
            ;;
        "Salir")
            exit 0
            ;;
        *)
            show_main_menu
            ;;
    esac
}

# Función para seleccionar un disco y realizar la instalación de MiniOS
select_disk_and_install() {
    DISKS=$(lsblk -o NAME,SIZE -n -d -e 7,11 | awk '{print $1 "(" $2 ")"}')

    SELECTED_DISK=$(zenity --list --title="Seleccionar disco" --column="Disco" --text="Seleccione un disco" ${DISKS})

    if [ -z "$SELECTED_DISK" ]; then
        show_main_menu
    else

        zenity --question --title="Advertencia" --text="Desea instalar MiniOS en el disco /dev/$SELECTED_DISK?\n\nAdvertencia: Se formateará y se perderán todos los datos en el disco." --no-wrap
        SELECTED_DISK=$(echo $SELECTED_DISK | cut -d "(" -f 1)
        case $? in
            0)
                
                format_and_install_minios "$SELECTED_DISK"
                ;;
            1)
                show_main_menu
                ;;
        esac
    fi
}

# Función para formatear el disco seleccionado e instalar MiniOS
format_and_install_minios() {
    local disk=$1
    echo $disk


    (
        echo "0" # Valor inicial de la barra de progreso
        echo "# Formateando el disco /dev/$disk con tabla de partición MBR y sistema de archivos Ext4..."
        echo "10"

        # Formatear el disco con tabla de partición MBR y sistema de archivos Ext4
        echo -e "o\nn\np\n1\n\n\nt\n83\nw" | fdisk /dev/$disk
        mkfs.ext4 /dev/${disk}1 -L "MiniOS System"

        echo "30"
        echo "# Creando el directorio /media/sda..."
        echo "40"

        # Crear el directorio /media/sda
        mkdir -p /media/sda

        echo "60"
        echo "# Montando el disco en /media/sda..."
        echo "70"

        # Montar el disco en /media/sda
        mount /dev/${disk}1 /media/sda

        echo "80"
        echo "# Copiando los archivos de instalación de MiniOS a /media/sda..."
        echo "90"

        # Copiar los archivos de instalación de MiniOS a /media/sda
        cp -R $PATH_MINIOS_LIVE_CD/ /media/sda/

        echo "100"
        echo "# Ejecutando el script de instalación de MiniOS..."
        $PATH_MINIOS_LIVE_CD/minios/boot/bootinstall.sh
    ) | zenity --progress --title="Instalando MiniOS" --text="Iniciando la instalación de MiniOS en el disco /dev/$disk..." --auto-close --auto-kill

    if [ $? -eq 0 ]; then
        zenity --info --title="Instalación completa" --text="La instalación de MiniOS en el disco /dev/$disk se ha completado correctamente." --no-wrap
    else
        zenity --error --title="Error" --text="Se produjo un error durante la instalación de MiniOS en el disco /dev/$disk."
    fi

    show_main_menu
}

# Mostrar el menú principal
show_main_menu
