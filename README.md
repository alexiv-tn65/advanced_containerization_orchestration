## containerization_orchestration

### Project Overview

This repository contains laboratory works related to containerization and orchestration, each in a separate branch.

### Branches:

- **Lab 1**: `lab1` [branch lab1 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab1)
- **Lab 2**: `lab2` [branch lab2 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab2)
- **Lab 3**: `lab3` [branch lab3 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab3)
- **Lab 4**: `lab4` [branch lab4 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab4)


Этот проект использует Docker Compose для развертывания многосервисного приложения, состоящего из инициализационного сервиса, основного приложения (Jupyter Notebook) и базы данных PostgreSQL. 

### Содержание

- [Описание сервисов](#описание-сервисов)
  - [Инициализационный сервис](#инициализационный-сервис)
  - [Основной сервис приложения](#основной-сервис-приложения)
  - [Сервис базы данных](#сервис-базы-данных)
- [Переменные окружения](#переменные-окружения)
- [Сети и тома](#сети-и-тома)
- [Запуск проекта](#запуск-проекта)


### Описание сервисов

Проект включает три основных сервиса:

1. **Инициализационный сервис**: Выполняет начальную настройку.
2. **Основной сервис (Jupyter Notebook)**: Предоставляет интерфейс для работы с Jupyter Notebook.
3. **Сервис базы данных (PostgreSQL)**: Хранит данные приложения.

#### Инициализационный сервис

```yaml
  init_service:  # Инициализационный сервис
    build:
      context: .  # Контекст сборки - текущая директория
      dockerfile: Dockerfile  # Используем Dockerfile из текущей директории
    container_name: my_init_service  # Явное имя контейнера
    command: ["sh", "-c", "echo 'Initialization complete'"]  # Команда для выполнения (инициализация)
    networks:
      - my_network  # Подключаем к сети my_network
```

#### Основной сервис приложения
```yaml
 app_service:  # Основной сервис приложения
    build:
      context: .  # Контекст сборки - текущая директория
      dockerfile: Dockerfile  # Используем тот же Dockerfile
    container_name: my_app_service  # Явное имя контейнера
    ports:
      - "8888:8888"  # Прокидываем порт 8888 наружу для доступа к Jupyter Notebook
    volumes:
      - app_data:/data  # Монтируем volume для хранения данных приложения
    depends_on:
      - init_service  # Зависит от init_service, который должен быть запущен первым
    networks:
      - my_network  # Подключаем к сети my_network
    healthcheck:  # Проверка состояния контейнера
      test: ["CMD", "curl", "-f", "http://localhost:8888"]  # Проверяем доступность Jupyter Notebook
      interval: 30s  # Интервал между проверками
      timeout: 10s   # Таймаут для каждой проверки
      retries: 5     # Количество неудачных попыток перед пометкой как unhealthy

```

#### Сервис базы данных
```yaml
  db_service:  # Сервис базы данных PostgreSQL
    image: postgres:13  # Используем официальный образ PostgreSQL версии 13
    container_name: my_db_service  # Явное имя контейнера
    environment:  # Переменные окружения для настройки базы данных
      POSTGRES_USER: ${DB_USER}       # Имя пользователя базы данных из .env файла
      POSTGRES_PASSWORD: ${DB_PASSWORD} # Пароль пользователя базы данных из .env файла
      POSTGRES_DB: ${DB_NAME}           # Имя базы данных из .env файла
    volumes:
      - db_data:/var/lib/postgresql/data  # Монтируем volume для хранения данных PostgreSQL
    networks:
      - my_network  # Подключаем к сети my_network

```

#### Переменные окружения

Переменные окружения для сервиса базы данных должны быть определены в файле .env, который должен находиться рядом с файлом docker-compose.yml. Пример содержимого файла .env:

```env
DB_USER=myuser1
DB_PASSWORD=mypassword@jdsd23
DB_NAME=myexperimentdatabase
```

#### Сети и тома
```yaml
volumes:
  app_data:   # Объявляем volume для приложения
  db_data:    # Объявляем volume для базы данных

networks:
  my_network:   # Объявляем сеть, к которой будут подключены все сервисы
```

#### Запуск проекта

Соберите и запустите контейнеры с помощью следующей команды:
```
docker-compose up --build

```
Параметр --build заставляет Docker пересобрать образы, если они были изменены.


Запуск в фоновом режиме

```
docker-compose up -d

```

Остановка и удаление контейнеров
```
docker-compose down

```


#### Зайти в контейнер базы данных с помощью команды:
```
docker-compose exec db_service bash

```

#### Доступ к приложению

Откройте браузер и перейдите по адресу:
```
http://localhost:8888
```

#### Можно ли ограничивать ресурсы (например, память или CPU) для сервисов в docker-compose.yml? Если нет, то почему, если да, то как?

Да, в docker-compose.yml можно ограничивать ресурсы для сервисов, таких как память и CPU. Это делается с помощью параметров, которые доступны в разных версиях Docker Compose.

В версиях 2.x вы можете использовать следующие параметры для ограничения ресурсов:

    mem_limit: Устанавливает жесткий лимит на использование памяти.
    mem_reservation: Устанавливает мягкий лимит на использование памяти.
    cpus: Устанавливает лимит на использование CPU.


```yaml
version: '2.4'

services:
  my_service:
    image: my_image
    mem_limit: 512m          # Ограничение на использование памяти (512 мегабайт)
    mem_reservation: 256m    # Мягкое ограничение на использование памяти (256 мегабайт)
    cpus: 0.5                # Ограничение на использование CPU (50% одного ядра)

```

Для версий 3.x и выше
В версиях 3.x и выше параметры для ограничения ресурсов могут быть указаны в разделе deploy, но они будут работать только в контексте Docker Swarm. Для обычного использования Docker Compose без Swarm, вы можете использовать параметры непосредственно в разделе сервиса.

```yaml
version: '3.8'

services:
  my_service:
    image: my_image
    deploy:
      resources:
        limits:
          memory: 512M       # Жесткое ограничение на использование памяти
          cpus: '0.50'       # Жесткое ограничение на использование CPU
        reservations:
          memory: 256M       # Мягкое ограничение на использование памяти
          cpus: '0.25'       # Мягкое ограничение на использование CPU

```
##### Проверка использования ресурсов
```
docker stats
```

#### Как можно запустить только определенный сервис из docker-compose.yml, не запуская остальные?

Чтобы запустить только один сервис, выполните следующую команду в терминале:

```
docker-compose up <название_сервиса>

```

Дополнительные параметры

Фоновый режим: Если вы хотите запустить сервис в фоновом режиме (detached mode), добавьте флаг -d:
```
docker-compose up -d <название_сервиса>
```

Логи: Чтобы просмотреть логи конкретного сервиса, используйте команду:

```
docker-compose logs <название_сервиса>
```