# Wellcome to MindPhaser34_infra
Студент: Брыкин Артём (MindPhaser34)

Занятие 5: Знакомство с облачной инфраструктурой и облачными сервисами.
Сделано:
Для выполнения задания были заведены 2 ВМ

VM #1: bastion
Внутренний IP: 10.132.0.2
Внешний IP: 34.77.189.138

VM #2: someintarnalhost
нутренний IP: 10.132.0.3

Был создан и подключен общий пользователь mindphaser33, путём пары ключей генерации SSH на локальном хосте и добавления публичного ключа в проект GCP

Самостоятельная работа:
1. Способ подключения к someinternalhost в одну команду из рабочего устройства:
eval "$(ssh-agent)" && ssh-add ~/.ssh/id_rsa && ssh -A mindphaser33@34.77.189.138 -t ssh 10.132.0.3

для удобства можно добавить алиас и автозапуск через переменные среды, добавив в файл ~/.bashrc команды запуска. Например:
echo 'alias someinternalhost="ssh -A mindphaser33@34.77.189.138 -t ssh 10.132.0.3"' >> ~/.bashrc
echo 'eval "$(ssh-agent)" && ssh-add ~/.ssh/id_rsa' >> ~/.bashrc

после чего запускать подключение комндой someinternalhost.

2. вариант решения для подключения из консоли при помощи команды вида ssh someinternalhost из локальной консоли рабочего устройства, чтобы подключение выполнялось по
алиасу someinternalhost:
создаём файл ~/.ssh/config со следующим содержимым:
Host bastion
  HostName 34.77.189.138
  User mindphaser33
  IdentityFile ~/.ssh/id_rsa
  AddKeysToAgent yes
  ForwardAgent yes
  ProxyCommand none

Host someinternalhost
  HostName 10.132.0.3
  User mindphaser33
  ProxyCommand ssh -W %h:%p bastion
  IdentityFile ~/.ssh/id_rsa
  ForwardAgent yes

после чего будут созданы 2 алиаса bastion и somelocalhost. Если мы захотим подключиться к VM #2, то необходимо выполнить
ssh somelocalhost
