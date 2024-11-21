## containerization_orchestration

### Project Overview

This repository contains four laboratory works related to containerization and orchestration, each in a separate branch.

### Branches:

- **Lab 1**: `lab1` [branch lab1 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab1)
- **Lab 2**: `lab2` [branch lab2 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab2)
- **Lab 3**: `lab3` [branch lab3 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab3)
- **Lab 4**: `lab4` [branch lab4 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab4)

#### Ход выполнения

1. Запускаем `minikube`

```bash
minikube start
```

2. Собираем кастомный образ `my-jupyter-notebook` на основе инструкций, указанных в Dockerfile, который находится в текущем каталоге (обозначенном точкой .).

```bash
minikube image build -t my-jupyter-notebook .
```

3. Запускаем сервис  
Применение конфигураций в Kubernetes:   

```bash
kubectl apply -f config-map.yaml
kubectl apply -f postgres-secret.yaml
kubectl apply -f postgres-pvc.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f jupyter-deployment.yaml
kubectl apply -f jupyter-service.yaml
```  

Проверка статуса подов:  
kubectl get pods  

Проверка логов подов:   
kubectl logs <имя_пода>  

Проверка конфигураций:    
kubectl get configmaps    
kubectl get secrets   

4. Туннелирование трафика между нодой minikube и upyter-notebook-service, тестирование доступа к сервису:  

```bash
minikube service jupyter-notebook-service --url 
```


## Проверяем статусы   


Проверка логов init-контейнера:    

kubectl logs <имя_пода> -c wait-for-postgres  


![logs](img/get_logs_new.png)   

Получение списка всех подов с метками:    
kubectl get pods --show-labels    

Получение меток конкретного пода
kubectl get pod <имя_пода> --show-labels

![pods](img/show_labels.png)

## Проверяем сервис

![hw](img/hallo_world.png)

<!-- ## полный листинк команд для запуска

```bash
minikube start
minikube image build -t my-jupyter-notebook .
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f init-deployment.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f app-deployment.yaml
kubectl apply -f service.yaml
``` -->

### Описания сервисов

```yaml
# config-map.yaml
# ✅ Использование `ConfigMap`
apiVersion: v1
kind: ConfigMap
metadata:
  name: jupyter-postgres-config
  labels:
    app: jupyter-notebook
    tier: frontend
    environment: production
    version: v1.0
    owner: dev-team
data:
  JUPYTER_ENABLE_LAB: "yes"
```

```yaml
# secrete.yaml
# ✅ Использование `Secret`
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  labels: # Указываем метки для идентификации и организации ресурса
    app: postgres # Название приложения, к которому относится секрет
    tier: database # Уровень приложения (база данных)
    environment: production # Среда развертывания (продакшн)
    owner: dev-team # Команда, ответственная за секрет
    version: v1.0 # Версия секрета (например, версия конфигурации)
    purpose: credentials # Цель секрета (например, учетные данные для доступа к базе данных)
type: Opaque  # тип секрета
data:
  POSTGRES_DB: bXlkYXRhYmFzZQ== # base64
  POSTGRES_USER: bXl1c2Vy # base64
  POSTGRES_PASSWORD: bXlwYXNzd29yZA== # base64
```

```yaml
# jupyter-deployment.yaml
# ✅ Использование `labels`
# ✅ Использование `initContainer`
# ✅ Использование `readinessProbe`
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jupyter-notebook-deployment
  labels: # задаем метки
    app: jupyter-notebook # Лейбл, указывающий на название приложения
    tier: frontend # Лейбл, указывающий на уровень приложения (фронтенд)
    environment: production # Среда развертывания (продакшн)
    version: v1.0 # Версия приложения
    owner: dev-team # Команда, ответственная за приложение
spec:
  replicas: 1 # количество реплик
  selector:
    matchLabels:
      app: jupyter-notebook
  template:
    metadata:
      labels:
        app: jupyter-notebook # Лейбл, который будет применен к создаваемым подам
        tier: frontend
        environment: production # Среда развертывания для подов
        version: v1.0 # Версия приложения для подов
        owner: dev-team # Команда, ответственная за приложение
    spec:
      containers:
      - name: jupyter-notebook # имя контейнера
        image: my-jupyter-notebook # имя собранного образа Docker для Jupyter Notebook
        imagePullPolicy: Never # явно указываем, что образ не будет загружаться из реестра, а используется локально
        ports:
        - containerPort: 8888 # порт, на котором контейнер будет слушать входящие запросы (стандартный порт для Jupyter Notebook)
        env: # переменные окружения
        - name: JUPYTER_ENABLE_LAB # Добавляем переменную окружения из ConfigMap
          valueFrom:
            configMapKeyRef: # ссылка на конфиг-мап
              name: jupyter-postgres-config # Используем созданный ConfigMap
              key: JUPYTER_ENABLE_LAB # ключ в конфиг-мапе
        - name: DATABASE_URL # Формируем URL подключения к базе данных
          value: "postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@postgres-service:5432/$(POSTGRES_DB)"
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_PASSWORD
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_DB
        readinessProbe:
          httpGet:
            path: /  # Путь для проверки готовности Jupyter Notebook.
            port: 8888     # Порт, на котором работает Jupyter Notebook.
          initialDelaySeconds: 30 # Задержка перед первой проверкой готовности (в секундах).
          periodSeconds: 10       # Интервал между проверками готовности (в секундах).
          timeoutSeconds: 5       # Время ожидания ответа от проверки (по умолчанию 1 секунда).
          failureThreshold: 8      # Количество неудачных проверок перед тем, как контейнер будет считаться неготовым.
      initContainers: # контейнеры-инициализаторы
      - name: wait-for-postgres # Инициализирующий контейнер для ожидания PostgreSQL
        image: busybox
        command: ['sh', '-c', 'for i in {1..30}; do nc -z postgres-service 5432 && echo \
        "Initialization complete: PostgreSQL database is operational." && exit 0; echo waiting for postgres; \
        sleep 5; done; echo "PostgreSQL did not start in time!"; exit 1']

```

```yaml
# jupyter-service.yaml
# ✅ Использование `Service` для `Deployment`
apiVersion: v1
kind: Service
metadata:
  name: jupyter-notebook-service 
  labels:
    app: jupyter-notebook  
    tier: frontend
    environment: production
    version: v1.0
    owner: dev-team
spec:
  type: NodePort # тип сервиса
  ports:
  - port: 8888 # порт, на котором сервис будет доступен внутри кластера
    targetPort: 8888  # порт, на который будет перенаправлен трафик к контейнеру
    nodePort: 30000 # порт на узле, по которому сервис будет доступен извне
  selector:
    app: jupyter-notebook # селектор, который связывает сервис с подами, имеющими метку app=jupyter-notebook
```

```yaml
# postgres-deployment.yaml
# ✅ Использование `volume`
# ✅ Использование `readinessProbe`
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-deployment
  labels: # указываем метки
    app: postgres # Название приложения
    tier: database # Уровень приложения (база данных)
    environment: production # Среда развертывания (продакшн)
    version: v1.0 # Версия приложения
    owner: dev-team # Команда, ответственная за приложение
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
        tier: database
    spec:
      containers:
      - name: postgres
        image: postgres:latest
        env:
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_DB
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_PASSWORD
        ports:
        - containerPort: 5432
        volumeMounts: # ✅ Использование `volume`
        - mountPath: /var/lib/postgresql/data
          name: postgres-storage
        readinessProbe: # ✅ Использование `readinessProbe`
          exec:
            command:
            - sh
            - -c
            - "PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER -d $POSTGRES_DB -c 'SELECT 1;'"
          initialDelaySeconds: 5
          periodSeconds: 10

      volumes: # создаем volume
      - name: postgres-storage
        persistentVolumeClaim: # ссылка на PVC
          claimName: postgres-pvc
```

```yaml
# postgres-service.yaml
# ✅ Использование `Service` для `Deployment`
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  labels:
    app: postgres
    tier: database
    environment: production 
    owner: dev-team 
spec:
  type: ClusterIP
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: postgres
``
