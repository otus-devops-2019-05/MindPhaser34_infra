# MindPhaser34_infra
Студент: Брыкин Артём (MindPhaser34)

[TOC]

### Занятие 5: Знакомство с облачной инфраструктурой и облачными сервисами.
Для выполнения задания были заведены 2 ВМ
```shell
bastion_IP = 34.77.189.138
someinternalhost_IP =10.132.0.3
```

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


### Занятие 6: Основные сервисы Google Cloud Platform (GCP).

Для выполнения ДЗ было создано 4 скрипта
1) install_ruby.sh
```bash
#! /bin/bash
sudo apt update && sudo apt install -y ruby-full ruby-bundler build-essential
```
2) install_mongodb.sh
```bash
#!/bin/bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
```

3) deploy.sh
```bash
#!/bin/bash
git clone -b monolith https://github.com/express42/reddit.git && cd reddit && bundle install && puma -d
```

4) startup.sh
```bash 
#! /bin/bash
sudo apt update && sudo apt install -y ruby-full ruby-bundler build-essential
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update && sudo apt install -y mongodb-org && sudo systemctl start mongod && sudo systemctl enable mongod
cd ~/ && git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install && puma -d
echo 'Job is Finished'
```

Для решения доп задания был создал инстанс следующей командой:
```shell
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=startup.sh
```
Машинка поднялась со следующими параметрами:

```shell 
testapp_IP = 34.77.207.115
testapp_port = 9292
```

Отдельно поигрался с backet. Создал otus-backet, скопировал туда скрипт и расшарил его.
```shell 
gsutil mb gs://otus-backet/
gsutil cp startup.sh gs://otus-backet/
gsutil acl ch -u AllUsers:R gs://otus-backet/startup.sh
```
Чтобы создать новую VM с запуском скрипта из backet необходиом запустить следующую команду:
```shell 
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url=gs://otus-backet/startup.sh
```

Создания правила брандмауэра из консоли gloud:
```shell 
gcloud compute --project=mindphaser34-infra firewall-rules create default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/24 --target-tags=puma-server
```
