### Создаем базу данных MySQL в докере

Что было сделано:

1. Клонировал репозиторий из https://github.com/aeuge/otus-mysql-docker
2. Провел дополнительную настройку файлов:

>docker-compose.yml

![alt text](image.png)
    
    
>init.sql

![alt text](image-1.png)

>my.cnf 

![alt text](image-2.png)

3. Развернул контейнер
4. Проверил что настройки конфигурационного файла действуют

![alt text](image-3.png)
![alt text](image-4.png)
