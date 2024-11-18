## containerization_orchestration

### Project Overview

This repository contains four laboratory works related to containerization and orchestration, each in a separate branch.

### Branches

- **Lab 1**: `lab1`
- **Lab 2**: `lab2`
- **Lab 3**: `lab3`
- **Lab 4**: `lab4`

#### Ход выполнения

1. Запускаем `minikube`

```bash
minikube start
```

2. Собираем кастомный образ `my-jupyter-notebook`

```bash
minikube image build -t my-jupyter-notebook .
```

3. Запускаем сервис

```bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f init-deployment.yaml
kubectl apply -f app-deployment.yaml
kubectl apply -f service.yaml
```

4. Получаем адрес сервиса

```bash
minikube service app-service --url
```
![minikube service url](img/url.png)


## Проверяем статусы

![minikube service url](img/get_pods.png)

![minikube service url](img/get_logs.png)

## Проверяем сервис

![minikube service url](img/hello_world.png)

## полный листинк команд для запуска

```bash
minikube start
minikube image build -t my-jupyter-notebook .
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f init-deployment.yaml
kubectl apply -f app-deployment.yaml
kubectl apply -f service.yaml
```

### Описания сервисов

!TODO: расписать сервисы и явно показать где выполнены требования лабы
