# MindPhaser34_infra
Студент: Брыкин Артём (MindPhaser34)

Список ДЗ к занятиям:
- [Занятие 5: Знакомство с облачной инфраструктурой и облачными сервисами](https://github.com/otus-devops-2019-05/MindPhaser34_infra/blob/cloud-testapp/README.md#%D0%B7%D0%B0%D0%BD%D1%8F%D1%82%D0%B8%D0%B5-5-%D0%B7%D0%BD%D0%B0%D0%BA%D0%BE%D0%BC%D1%81%D1%82%D0%B2%D0%BE-%D1%81-%D0%BE%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D0%BE%D0%B9-%D0%B8%D0%BD%D1%84%D1%80%D0%B0%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%82%D1%83%D1%80%D0%BE%D0%B9-%D0%B8-%D0%BE%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D1%8B%D0%BC%D0%B8-%D1%81%D0%B5%D1%80%D0%B2%D0%B8%D1%81%D0%B0%D0%BC%D0%B8)
- [Занятие 6: Основные сервисы Google Cloud Platform (GCP)](https://github.com/otus-devops-2019-05/MindPhaser34_infra/blob/cloud-testapp/README.md#%D0%B7%D0%B0%D0%BD%D1%8F%D1%82%D0%B8%D0%B5-6-%D0%BE%D1%81%D0%BD%D0%BE%D0%B2%D0%BD%D1%8B%D0%B5-%D1%81%D0%B5%D1%80%D0%B2%D0%B8%D1%81%D1%8B-google-cloud-platform-gcp " Занятие 6: Основные сервисы Google Cloud Platform (GCP)")
- [Занятие 7: Модели управления инфраструктурой](https://github.com/otus-devops-2019-05/MindPhaser34_infra/tree/packer-base#%D0%B7%D0%B0%D0%BD%D1%8F%D1%82%D0%B8%D0%B5-7-%D0%BC%D0%BE%D0%B4%D0%B5%D0%BB%D0%B8-%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D1%8F-%D0%B8%D0%BD%D1%84%D1%80%D0%B0%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%82%D1%83%D1%80%D0%BE%D0%B9)
- [Занятие 8: Практика Infrastructure as a Code (IaC)](https://github.com/otus-devops-2019-05/MindPhaser34_infra/tree/terraform-1#%D0%B7%D0%B0%D0%BD%D1%8F%D1%82%D0%B8%D0%B5-8-%D0%BF%D1%80%D0%B0%D0%BA%D1%82%D0%B8%D0%BA%D0%B0-infrastructure-as-a-code-iac)

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
gcloud compute --project=mindphaser34-infra firewall-rules create default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server
```

### Занятие 7: Модели управления инфраструктурой.
В рамках самостоятельной работы был создан шаблон для packer 
**ubuntu16.json**  - основной шаблон packer с указанием дополнительных параметров (Описание образа, Размер и тип диска,  Название сети, Теги)
**variables.json** - отдальные пользовательские переменные, файл помещён в .gitignore
**variables.json.example** - копия variables.json, но с изменёнными данными
чтобы запустить сборку образа с нашим шаблоном необходимо выполнить команду:
```shell
packer build -var-file=variables.json template.json
```
**Задание со звёздочкой 1**
Создан шаблон immutable.json, папка files, куда скопирован файл startup.sh из прошлого задания, а так же создана служба для запуска Puma Server:
```shell
[Unit]
Description=Puma-Server
After=network.target

[Service]
Type=simple

WorkingDirectory=/home/appuser/reddit
ExecStart=/usr/local/bin/pumactl start &>> /dev/null
Restart=always

[Install]
WantedBy=multi-user.target
```
Данный файл копируется при создании обараз в домашнюю папку пользователя, затем переносится в /etc/systemd/system и включается в качестве сервиса системы.

При запуске 
```shell
packer build immutable.json
```
формируется образ, который мы вставляем в при создании инстанса в GUI. Дополнительно необходимо указать название инстанса и тэги сети.

**Задание со звёздочкой 2**
```shell
gcloud compute instances create reddit-full --image reddit-full-1561831493 --machine-type=g1-small --tags puma-server
```
работу инстанса можно проверить по адресу: 34.76.99.213:9292


### Занятие 8: Практика Infrastructure as a Code (IaC)
1. Самостоятельное задание.

**main.ft**
```
resource "google_compute_instance" "app" {
  ...
  zone         = "${var.zone}"
  ...
 connection {
  ...
  private_key = "${file(var.private_key_path)}"
```

**terraform.tfvars**
```
project = "mindphaser34-infra"
public_key_path = "~/.ssh/appuser.pub"
private_key_path="~/.ssh/appuser"
zone="europe-west1-b"
disk_image = "reddit-base"
```

**variables.tf**
```
...
variable private_key_path {
  description = "Path to the private key used for ssh access"
}
variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}
```

2. Задание co *.

Чтобы добавить несколько пользователей, необходимо в main.tf изменить следующее
```
  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}\nappuser1:${file(var.public_key_path)}\nappuser2:${file(var.public_key_path)}"
  }
```
Чтобы добавить ключ пользователя appuser_web в веб-интерфейс, необходимо сначала его сгенерировать
```shell
ssh-keygen -C appuser_web -f ~/.ssh/appuser_web -t rsa -b 2048
```
И после вставить в веб-интерфейс. При добавлении данного ключа в конфиг terraform и выполнении команды apply - невозможно зайти под данным пользователем на инстанс, так как по-умолчанию проектные ключи не распространяются на инстансы. ЧТобы это исправить, необходимо через curl вызвать следующую команду:
```shell
POST https://www.googleapis.com/compute/v1/projects/[PROJECT_ID]/zones/[ZONE]/instances/[INSTANCE_NAME]/setMetadata

 {
 "items": [
  {
   "key": "block-project-ssh-keys",
   "value": FALSE
  }
 ]
 "fingerprint": "[FINGERPRINT]"
 }
```
либо подкидывать файл ключа вручную
```shell
ssh -i ~/.ssh/appuser_web appuser_web@ip
```

3. Задание с **.

В рамках задания был создан файл с lb.tf, в котором разворачивался балансировщик с группами инстансов в нужном количестве. В файл с переменными (**variables.tf**) была добавлена переменная **count**, в которой задано описание и значение по-умолчанию (**default**) равное 1. Чтобы изменить количество разворачиваемых инстансов в группе инстансов достаточно поменять значение данной переменной.
Так же были подправлены выходные данные в файле **outputs.tf**
```shell
output "app_external_ip" {
  value = "${google_compute_instance.app.*.network_interface.0.access_config.0.nat_ip}"

}
output "load-balancer-ip" {
  value = "${google_compute_global_forwarding_rule.lb-fwd.ip_address}"
}
```

