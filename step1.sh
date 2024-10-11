#!/bin/bash

#Определение алгоритма с наилучшим сжатием
sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
yum install -y epel-release kernel-devel zfs
yum-config-manager --disable zfs
yum-config-manager --enable zfs-kmod
yum install -y zfs
modprobe zfs
yum install -y wget mc
echo "Посмотрим диски"
lsblk
echo "Создаём пул из двух дисков в режиме RAID 1"
zpool create otus1 mirror /dev/sdb /dev/sdc
echo "Создадим ещё 3 пула"
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi
echo "Смотрим информацию о пулах"
zpool list
echo "Добавим разные алгоритмы сжатия в каждую файловую систему"
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4
echo "Проверим, что все файловые системы имеют разные методы сжатия"
zfs get all | grep compression
echo "Скачаем один и тот же текстовый файл"
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
echo "Проверим, что файл был скачан во все пулы"
ls -l /otus*
echo "Проверим, сколько места занимает файл и степень сжатия файлов"
zfs list
zfs get all | grep compressratio | grep -v ref

#Определение настроек пула
echo "Определение настроек пула"
echo "Скачиваем архив в домашний каталог"
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
echo "Разархивируем его"
tar -xzvf archive.tar.gz
echo "Проверим, возможно ли импортировать данный каталог в пул"
zpool import -d zpoolexport/
echo "Сделаем импорт данного пула к нам в ОС"
zpool import -d zpoolexport/ otus
echo "Посмотрим его статус"
zpool status
echo "Определяем настройки"
zpool get all otus
echo "Запрос сразу всех параметром файловой системы"
zfs get all otus

#Работа со снапшотом, поиск сообщения от преподавателя
echo "Работа со снапшотом, поиск сообщения от преподавателя"
echo "Скачаем файл, указанный в задании"
wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download
sleep 60
echo "Смортим, что скачалось"
ls -alh
echo "Восстановим файловую систему из снапшота"
zfs receive otus/test@today < otus_task2.file
echo "ищем в каталоге /otus/test файл с именем “secret_message”"
find /otus/test -name "secret_message"
echo "Смотрим содержимое найденного файла"
cat /otus/test/task1/file_mess/secret_message
