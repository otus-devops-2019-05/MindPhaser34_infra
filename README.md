# Wellcome to MindPhaser34_infra
Студент: Брыкин Артём (MindPhaser34)

[TOC]

## Занятие 5: Знакомство с облачной инфраструктурой и облачными сервисами.
Для выполнения задания были заведены 2 ВМ

bastion_IP = 34.77.189.138
someinternalhost_IP =10.132.0.3

Был создан и подключен общий пользователь mindphaser33, путём генерации пары ключей SSH на локальном хосте и добавления публичного ключа в проект GCP

**Самостоятельная работа:**
1. Способ подключения к someinternalhost в одну команду из рабочего устройства:
```bash
eval "$(ssh-agent)" && ssh-add ~/.ssh/id_rsa && ssh -A mindphaser33@34.77.189.138 -t ssh 10.132.0.3
```
для удобства можно добавить алиас и автозапуск через переменные среды, добавив в файл **~/.bashrc** команды запуска. Например:


    echo "alias someinternalhost="ssh -A mindphaser33@34.77.189.138 -t ssh 10.132.0.3"" >> ~/.bashrc
    echo "eval "$(ssh-agent)" && ssh-add ~/.ssh/id_rsa" >> ~/.bashrc

после чего запускать подключение комндой **someinternalhost**.

2. Вариант решения для подключения из консоли при помощи команды вида ssh someinternalhost из локальной консоли рабочего устройства, чтобы подключение выполнялось по алиасу someinternalhost:
Создаём файл **~/.ssh/config** со следующим содержимым:

```shell
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
```

после чего будут созданы 2 ssh алиаса **bastion** и **somelocalhost**. Если мы захотим подключиться к **someinternalhost**, то необходимо выполнить

    ssh somelocalhost

Далее, на VM bastion, был развёрнут VPN сервер Pretunl с портом **udp:10855.** 
С помощью сервиса sslip.io было сгенерировано DNS-имя **https://34-77-189-138.sslip.io/**, которое было задействовано в настройках VPN-сервера, в поле Let's Encrypt  для автоматической генерации сертификата.
