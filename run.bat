minikube start
minikube image build -t my-jupyter-notebook . 
kubectl apply -f config-map.yaml
kubectl apply -f postgres-secret.yaml
kubectl apply -f postgres-pvc.yaml
kubectl apply -f jupyter-deployment.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f jupyter-service.yaml
kubectl get pods --show-labels
kubectl get services --show-labels
kubectl describe pvc postgres-pvc
