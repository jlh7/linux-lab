# Làm việc với Persistent Volume

## Tạo 2 persistent volume, type là host path

- Bước 1: Tạo tệp YAML - [`pv.yaml`](./YAML/pv.yaml) để tạo Persistent Volume

  ```yaml
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: pv-1
  spec:
    capacity:
      storage: 500Mi
    accessModes:
      - ReadWriteOnce
    hostPath:
      path: "/k8s-data/pv-1"
  ---
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: pv-2
  spec:
    capacity:
      storage: 500Mi
    accessModes:
      - ReadWriteOnce
    hostPath:
      path: "/k8s-data/pv-2"
  ```

- Bước 2: Áp dụng các tệp YAML từ máy của bạn hoặc từ master node:

   ```bash
   kubectl apply -f pv.yaml
   ```

- Bước 3: Kiểm tra Persistent Volumes:

   ```bash
   kubectl get pv -o wide
   ```

## Tạo 2 Persistent Volume Claim, gắn nó với 2 PV đã tạo ở trên

- Bước 1: Tạo tệp YAML - [`pvc.yaml`](./YAML/pvc.yaml) cho Persistent Volume Claim

  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: pvc-1
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 500Mi
    volumeName: pv-1
  ---
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: pvc-2
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 500Mi
    volumeName: pv-2
  ```

- Bước 3: Áp dụng các tệp YAML

  ```bash
  kubectl apply -f pvc.yaml
  ```

- Bước 4: Kiểm tra Persistent Volume Claims

  ```bash
  kubectl get pvc -o wide
  ```

## Tạo 1 statefulset với image nginx, có 2 pod, cấu hình cho mỗi pod gắn với 1 PVC đã tạo ở trên, mount volume sao cho log của nginx được ghi ra PV

- Bước 1: Tạo ConfigMap - [`nginx-config`](./YAML/nginx-config.yaml) cho cấu hình Nginx:

  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: nginx-config
  data:
    nginx.conf: |
      error_log /var/log/nginx/error.log info;
      access_log /var/log/nginx/access.log main;
  ```

- Bước 2: Áp dụng ConfigMap:

  ```bash
  kubectl apply -f nginx-config.yaml
  ```

- Bước 3: Tạo tệp YAML - [`nginx-statefulset`](./YAML/nginx-statefulset.yaml) cho StatefulSet:

  ```yaml
  apiVersion: apps/v1
  kind: StatefulSet
  metadata:
    name: nginx-statefulset
  spec:
    serviceName: "nginx"
    replicas: 2
    selector:
      matchLabels:
        app: nginx
    template:
      metadata:
        labels:
          app: nginx
      spec:
        containers:
        - name: nginx
          image: nginx
          ports:
          - containerPort: 80
          volumeMounts:
          - name: nginx-logs
            mountPath: /var/log/nginx
        volumes:
        - name: nginx-log
          configMap:
            name: nginx-config
          persistentVolumeClaim:
            claimName: pvc-work3r-5
  ```

- Bước 4: Áp dụng StatefulSet:

  ```bash
  kubectl apply -f nginx-config.yaml
  ```

- Bước 5: Kiểm tra:

  - Kiểm tra trạng thái của StatefulSet:

    ```bash
    kubectl get statefulset -o wide
    ```

  - Kiểm tra log của Nginx:

    ```bash
    kubectl logs <pod name> -c nginx
    ```

## Tạo 1 service để expose statefullset trên (tên service là nginx-service)

- Bước 1: Tạo tệp YAML - [`nginx-portservice`](./YAML/nginx-portservice.yaml) cho Service

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: nginx-service
   spec:
     type: NodePort
     selector:
       app: nginx
     ports:
       - port: 8080
         targetPort: 80
         nodePort: 30808
   ```

- Bước 2: Áp dụng tệp YAML

   ```bash
   kubectl apply -f service.yaml
   ```

- Bước 3: Kiểm tra Service

   ```bash
   kubectl get service -o wide
   ```

## Tạo một tệp index.html trong nginx và in ra mà hình chữ "hello exam" khi curl tới nó

- Bước 1: Tạo tệp index.html

  1. Truy cập vào một trong các pods của StatefulSet `nginx-statefulset` mà bạn đã tạo.
  2. Sử dụng lệnh `kubectl exec` để mở một shell bên trong pod:

     ```bash
     kubectl exec -it <pod name> -- /bin/bash
     ```

- Bước 2: Thêm nội dung vào tệp index.html

   ```bash
   echo "hello exam" > /usr/share/nginx/html/index.html
   ```

- Bước 3: Thoát khỏi shell của pod

- Bước 4: Kiểm tra bằng cách sử dụng curl

   ```bash
   curl <pod ip address>:30808
   ```

   Hoặc

   ```bash
   curl <cluster ip address>:8080
   ```

## Kiểm tra access log của nginx pod 0

- Bước 1: Xác định tên của các pods nginx

   ```bash
   kubectl get pods -l app=nginx
   ```

- Bước 2: Kiểm tra access log của nginx

   ```bash
   kubectl logs <tên-pod-nginx>
   ```

  Nếu bạn muốn theo dõi log trong thời gian thực, bạn có thể thêm cờ `-f` vào lệnh:

    ```bash
    kubectl logs -f <tên-pod-nginx>
    ```

## Xóa nginx pod 0 rồi kiểm tra xem pod có tạo lại và có còn dữ liệu access log cũ không?

- Bước 1: Xóa StatefulSet

   ```bash
   kubectl delete statefulset nginx-statefulset
   ```

- Bước 2: Kiểm tra xem pods có được tạo lại không

   ```bash
   kubectl get pods -l app=nginx
   ```

- Bước 3: Kiểm tra dữ liệu access log cũ

  Để kiểm tra xem dữ liệu access log cũ có còn tồn tại sau khi pods được tạo lại không, có thể sử dụng lệnh `kubectl logs` với cờ `--previous` để xem logs từ lần chạy trước của pod:
  
   ```bash
   kubectl logs <tên-pod-nginx> --previous
   ```
