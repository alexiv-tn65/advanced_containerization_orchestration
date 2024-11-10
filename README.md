## containerization_orchestration

### Project Overview

This repository contains laboratory works related to containerization and orchestration, each in a separate branch.

### Branches:

- **Lab 1**: `lab1` [branch lab1 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab1)
- **Lab 2**: `lab2` [branch lab2 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab2)
- **Lab 3**: `lab3` [branch lab3 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab3)
- **Lab 4**: `lab4` [branch lab4 ](https://github.com/alexiv-tn65/containerization_orchestration/tree/lab4)



#### Ход выполнения 

Проверить, что все успешно установилось:

![-](images/2.png)

kubectl config view (должен отобразиться конфиг созданного кластера):

![-](images/3.png)

Проверить, что все ресурсы успешно создались:

![-](images/4.png)

Посмотреть конкретный ресурс:

![-](images/5.png)

![-](images/6.png)


Для  nextcloud:

![-](images/7.png)

![-](images/8.png)

![-](images/9.png)
![-](images/10.png)


Проверка:

![-](images/11.png)

Экземпляр Nextcloud был успешно установлен:

![-](images/12.png)


kubectl expose deployment nextcloud --type=NodePort --port=80

![-](images/13.png)


Туннелирование трафика между нодой minikube и Сервисом с помощью команды:  
minikube service nextcloud

![-](images/14.png)

Получить доступ к  приложению Nextcloud:   
minikube service nextcloud --url   
http://127.0.0.1:59549


![-](images/15.png)


Установка Dashboard     
minikube dashboard --url

![-](images/16.png)

#### Вопрос: важен ли порядок выполнения этих манифестов? Почему?


Да, порядок выполнения манифестов важен по следующим причинам:

- **Зависимости**: 
  - `ConfigMap` (`pg_configmap.yml`) должен быть создан первым, так как он содержит конфигурационные данные для deployment PostgreSQL. Если `pg_deployment.yml` будет создан до этого, deployment не найдет необходимые переменные окружения.

- **Сервисы**: 
  - Сервис (`pg_service.yml`) следует создавать после `ConfigMap` и перед deployment, чтобы обеспечить доступ к подам PostgreSQL.

- **Рекомендуемый порядок**:
  - Сначала создайть `ConfigMap`, затем service, а затем deployment.


#### Вопрос: что (и почему) произойдет, если отскейлить количество реплик postgres-deployment в 0, затем обратно в 1, после чего попробовать снова зайти на Nextcloud?

Снижение количества реплик до 0:   
kubectl scale deployment postgres-deployment --replicas=0    

![-](images/17.png)

Возвращение количества реплик обратно на 1:           
kubectl scale deployment postgres-deployment --replicas=1

Посмотреть логи    
kubectl logs nextcloud-d8d8c874f-jffzs



Если  отскейлить количество реплик postgres-deployment до 0 то:    
сначала  PostgreSQL будет остановлен, и Nextcloud не сможет подключиться к базе данных.  
Когда вернуть количество реплик обратно на 1, Kubernetes создаст новый под с экземпляром PostgreSQL.   
После того как новый под будет запущен и готов к работе, база данных снова станет доступной.  
После этого Nextcloud снова сможет подключаться к базе данных.   
Но видимо Nextcloud не пытается заново подключиться базе, поэтому он не будет корректно работать.

![-](images/18.png)

Если удалить под Nextcloud:    
kubectl delete pod nextcloud-d8d8c874f-jffzs     
Это приведет к тому, что Kubernetes автоматически создаст новый под Nextcloud: 

![-](images/19.png)

![-](images/20.png)

В моем случае по адресу http://127.0.0.1:51778 cнова можно получить доступ к Nextcloud, который будет работать.    

![-](images/21.png)      

Т.е. вероятно  Nextcloud не пытался подключиться к  БД после того как был создан новый под с экземпляром PostgreSQL, после того как пересоздали под Nextcloud он подключился и все заработало.


#### Осуществить махинации над манифестами из примера    

Удалить старые поды, деплойменты и т.д.:      
kubectl delete pod --all   
kubectl delete deployment --all    
kubectl delete service --all   

Примените новые манифесты   
kubectl apply -f pg_secret.yml   
kubectl apply -f pg_configmap.yml     
kubectl apply -f pg_service.yml   
kubectl apply -f pg_deployment.yml   
kubectl apply -f nextcloud_configmap.yml   
kubectl apply -f nextcloud.yml     

Проверить статус подов   
kubectl get pods   

kubectl logs <имя_пода_nextcloud>    
kubectl logs <имя_пода_postgres>   

![-](images/23.png)   


kubectl expose deployment nextcloud --type=NodePort --port=80     
minikube service nextcloud    

![-](images/24.png)  

