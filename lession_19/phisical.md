## Создаю кластер для мастера:
```
sudo pg_createcluster 16 master -p 5432
```

## Запуск кластера:
```
sudo pg_ctlcluster 16 master start
```

## Задать пароль для пользователя postgres:
```
sudo -u postgres psql -p 5432 -c "\password postgres"
```

## Создаю кластер для реплики:
```
sudo pg_createcluster 16 replica -p 5433
```


## Настройки мастера:

```
sudo nano /etc/postgresql/16/master/postgresql.conf 
```
>Указываю список ip адресов на который postgreSQL будет слушать входящие подключения. Так как у меня 2 локальных кластера, просто раскоментирую значение по умолчанию, то есть listen_addresses = 'localhost'

```
sudo nano /etc/postgresql/16/master/pg_hba.conf
```
> В этом файле ничего не меняю, настройки по умолчанию позволят настроить репликацию

## Перезагружаю мастер кластер:
```
sudo pg_ctlcluster 16 master restart; 
```

## Захожу в кластер:
```
sudo -u postgres psql -p 5432
```
## Создаю базу replica:
```
CREATE DATABASE replica;
```
## Создаю таблицу:
```
CREATE TABLE t (t int);
```
## Заполняю тестовой информацией:
```
INSERT INTO t values(0);
```
## Проверяем:
```
SELECT * FROM t;
```
## Создаю слот реплкации:
```
SELECT pg_create_physical_replication_slot('replica_slot');
```

## Настройки реплики

### Остановить реплику если она еще не остановлена

```
sudo pg_ctlcluster 16 replica stop
```
### Удаляю всю базу
```
sudo rm -rf /var/lib/postgresql/16/replica/
```
### Делаем бэкап
```
sudo -u postgres pg_basebackup -h 127.0.0.1 -p 5432 -R -D /var/lib/postgresql/16/replica -U postgres -W
```
### Запускаем кластер реплики
```
sudo pg_ctlcluster 16 replica start
```

## Сделаем так чтобы реплика отставала от мастера на 5 минут
```
sudo nano /var/lib/postgresql/16/replica/postgresql.conf
```
> вставляем в конец файла:
```
recovery_min_apply_delay = 5min
```
перезапускаем кластер
```
sudo pg_ctlcluster 16 replica restart
```

## Проверка работы:

### Захожу на мастер кластер
```
sudo -u postgres psql -p 5432
```
### Подключаюсь к базе
```
\c replica
```
### Создаю запись в базу
```
INSERT INTO t values(6);
```
### захожу на реплику
```
sudo -u postgres psql -p 5433
```
### Подключаюсь к базе
```
\c replica
```
### проверяю записи:
```
select * from t;
```
