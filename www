import logging
import subprocess

# Настройка логирования
logging.basicConfig(filename='script.log', level=logging.INFO, format='%(asctime)s:%(levelname)s:%(message)s')

# Результат выполнения команды
def run_command(command):
    print('Выполнение команды ' + command)
    process = 'успешно'
    try:
        output = subprocess.check_output(command, stderr=subprocess.STDOUT, shell=True, universal_newlines=True)
        logging.info(f"Команда '{command}' выполнена успешно. Вывод:\n{output}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Ошибка при выполнении команды '{command}'. Код ошибки {e.returncode}. Вывод:\n{e.output}")
        print('с ошибкой, информация об ошибке доступна в файле script.log')
        return None
    finally:
        print('Запуск команды ' + command + ' завершен ' + process)
    return output

# Предустановка
def preconfigure():
    run_command('sudo apt update')
    run_command('sudo apt upgrade')
    print("Предустановка завершена.")

# Чтение и замена строк
def modify_file(file_path, replacements):
    with open(file_path, 'r') as f:
        content = f.read()

    # Проходим по каждой паре (старая строка, новая строка)
    for old_string, new_string in replacements.items():
        # Заменяем все вхождения старой строки на новую строку
        content = content.replace(old_string, new_string)

    with open(file_path, 'w') as f:
        f.write(content)

# Добавление строк
def append_to_file(file_path, content):
    with open(file_path, 'a') as f:
        f.write(content)

# Добавление строк в конкретное место
def insert_between(file_path, line1, line2, content):
    with open(file_path, 'r') as f:
        lines = f.readlines()

    with open(file_path, 'w') as f:
        for line in lines:
            f.write(line)
            if line.strip() == line1:
                f.write(content)
            elif line.strip() == line2:
                f.write(content)

# SSH
def configure_ssh():
    file_path = '/etc/ssh/sshd_config'
    replacements = {
        '#Port 22': 'Port 22',
        '#PermitRootLogin prohibit-password': 'PermitRootLogin yes',
        '#PasswordAuthentication no': 'PasswordAuthentication yes'
    }
    modify_file(file_path, replacements)

    run_command('sudo apt install openssh-server -y')
    run_command('systemctl start ssh')
    run_command('systemctl enable ssh')
    run_command('sudo systemctl restart ssh')
    run_command('ufw enable')
    run_command('sudo ufw default allow outgoing')
    run_command('sudo ufw allow 22/tcp')

# DNS
def configure_dns():
    run_command('sudo apt install bind9 -y')
    run_command('sudo apt install dnsutils')
    run_command('sudo service bind9 start')
    
    file_path = "/etc/bind/named.conf.options"
    new_content = """
    options {
        dnssec-validation auto;
        auth-nxdomain no;
        directory "/var/cache/bind";
        recursion no; # запрещаем рекурсивные запросы на сервер имён
    
        listen-on {
            172.16.0.0/16; 
            127.0.0.0/8;
        };
    
        forwarders { 
            172.16.0.1;
            8.8.8.8;  
        };
    };
    """
    
    with open(file_path, 'w') as file:
        file.write(new_content)

# DHCP
def configure_dhcp():
    run_command('sudo apt install isc-dhcp-server -y')
    
    file_path = "/etc/dhcp/dhcpd.conf"
    new_content = """
    subnet 192.168.0.0 netmask 255.255.255.0 {
      range 192.168.0.100 192.168.0.200;
      option domain-name-servers 192.168.0.10, 192.168.0.11;
      option domain-name "dmosk.local";
      option routers 192.168.0.1;
      option broadcast-address 192.168.0.255;
      default-lease-time 600;
      max-lease-time 7200;
    }
    """
    
    with open(file_path, 'w') as file:
        file.write(new_content)
    
    run_command('sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf')
    run_command('sudo systemctl enable isc-dhcp-server')
    run_command('sudo systemctl restart isc-dhcp-server')
    run_command('sudo iptables -I INPUT -p udp --dport 67 -j ACCEPT')
    run_command('sudo iptables-save')

# Mysql
def configure_mysql():
    run_command('sudo apt install mysql-server -y')
    run_command('sudo service mysql restart')
    run_command('sudo /sbin/iptables -A INPUT -p tcp --dport 1433 -j ACCEPT')
    run_command('sudo /sbin/iptables -A OUTPUT -p tcp --dport 1433 -j ACCEPT')
    run_command('sudo /sbin/iptables -A INPUT -p udp --dport 6000:6007 -j ACCEPT')
    run_command('sudo /sbin/iptables -A OUTPUT -p udp --dport 6000:6007 -j ACCEPT')

# FTP
def configure_ftp():
    run_command('sudo apt install vsftpd -y')
    run_command('anonymous_enable=YES')
    run_command('sudo mkdir -p /srv/files/ftp')
    run_command('sudo usermod -d /srv/files/ftp ftp')
    run_command('sudo systemctl restart vsftpd.service')
    run_command('write_enable=YES')
    run_command('sudo systemctl restart vsftpd.service')
    run_command('chroot_local_user=YES')
    run_command('chroot_list_enable=YES')
    run_command('chroot_list_file=/etc/vsftpd.chroot_list')
    run_command('sudo systemctl restart vsftpd.service')

# Samba
def configure_samba():
    run_command('sudo apt install samba -y')
    run_command('sudo mkdir -p /home/sharing')

    file_path = '/etc/samba/smb.conf'
    replacements = {
        'interfaces = 127.0.0.0/8 eth0': 'interfaces = lo enp0s3',
        'listen_ipv6=YES': 'listen_ipv6=NO',
    }
    modify_file(file_path, replacements)

    file_path = '/etc/samba/smb.conf'
    content_to_append = '''
    [sharing]
    comment = Samba share directory
    path = /home/sharing
    read only = no
    writable = yes
    browseable = yes
    guest ok = no
    valid users = @saraz @new_user
    '''
    append_to_file(file_path, content_to_append)

    run_command('ufw allow samba')
    run_command('systemctl restart smbd')

# OpenVPN
def download_and_execute_script():
    run_command('wget https://raw.githubusercontent.com/MdNor/digital-ocean-openvpn/master/ubuntu')
    run_command('sh ubuntu -y')

# Вывод списка процессов
def get_process_list():
    return run_command("ps -ef")

# Вывод информации о свободном пространстве на дисках
def get_disk_space():
    return run_command("df -h")

if __name__ == "__main__":
    print("Выберите действие:")
    print("1. Предустановка")
    print("2. Настройка SSH")
    print("3. Настройка DNS")
    print("4. Настройка DHCP")
    print("5. Настройка MySQL")
    print("6. Настройка FTP")
    print("7. Настройка Samba")
    print("8. Установка OpenVPN и выполнение скрипта")
    print("9. Вывести список процессов")
    print("10. Вывести информацию о свободном пространстве на дисках")
    print("11. Настроить все")

    choice = input("Введите номер действия: ")

    if choice == "1":
        preconfigure()
    elif choice == "2":
        configure_ssh()
    elif choice == "3":
        configure_dns()
    elif choice == "4":
        configure_dhcp()
    elif choice == "5":
        configure_mysql()
    elif choice == "6":
        configure_ftp()
    elif choice == "7":
        configure_samba()
    elif choice == "8":
        download_and_execute_script()
    elif choice == "9":
        print("Список процессов:")
        print(get_process_list())
    elif choice == "10":
        print("Информация о свободном пространстве на дисках:")
        print(get_disk_space())
    elif choice == "11":
        preconfigure()
        configure_ssh()
        configure_dns()
        configure_dhcp()
        configure_mysql()
        configure_ftp()
        configure_samba()
        download_and_execute_script()
        print("Настройка всех опций завершена.")
    else:
        print("Неверный выбор.")
