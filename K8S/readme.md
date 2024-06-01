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
    volumeMode: Filesystem
    accessModes:
      - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    storageClassName: local-storage
    hostPath:
      path: "/k8s-data/pv1"
  ---
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: pv-2
  spec:
    capacity:
      storage: 500Mi
    volumeMode: Filesystem
    accessModes:
      - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    storageClassName: local-storage
    hostPath:
      path: "/k8s-data/pv2"
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
    storageClassName: local-storage
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
  ---
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: pvc-2
  spec:
    storageClassName: local-storage
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
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

- Bước 1: Tạo tệp YAML - [`nginx-statefulset`](./YAML/nginx-statefulset.yaml) cho StatefulSet:

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
    volumeClaimTemplates:
      - metadata:
          name: nginx-logs
        spec:
          accessModes: [ "ReadWriteOnce" ]
          storageClassName: "local-storage"
          resources:
            requests:
              storage: 500Mi
  ```

- Bước 2: Áp dụng StatefulSet:

  ```bash
  kubectl apply -f nginx-config.yaml
  ```

- Bước 3: Kiểm tra:

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

- Bước 1: Tạo tệp YAML - [`nginx-config.yaml`](./YAML/nginx-config.yaml) để confing tệp index.html

  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: nginx-index
  data:
    index.html: |
      <html>
      <body>
      <h1>hello exam</h1>
      </body>
      </html>
  ```

- Bước 2: Áp dụng tệp config

  ```bash
  kubectl apply -f nginx-config.yaml
  ```

- Bước 3: Sửa tệp YAML - [`nginx-statefulset`](./YAML/nginx-statefulset.yaml) như sau:

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
              - name: nginx-index
                mountPath: /usr/share/nginx/html
        volumes:
          - name: nginx-index
            configMap:
              name: nginx-index
    volumeClaimTemplates:
      - metadata:
          name: nginx-logs
        spec:
          accessModes: ["ReadWriteOnce"]
          storageClassName: "local-storage"
          resources:
            requests:
              storage: 500Mi
  ```

- Bước 4: Kiểm tra bằng cách sử dụng curl

   ```bash
   curl <pod ip address>:30808
   ```

   Hoặc

   ```bash
   curl <cluster ip address>:8080
   ```

## Tạo 1000 request đến nginx

  ```bash
  for i in {1..1000};
  do
    curl <pod ip address>:30808;
  done
  ```

## Kiểm tra access log của nginx pod 0

- Bước 1: Xác định tên của các pods nginx

   ```bash
   kubectl get pods -l app=nginx
   ```

- Bước 2: Kiểm tra access log của nginx

   ```bash
   kubectl exec <tên-pod-nginx> -- cat /var/log/nginx/access.log
   ```

   Hoặc xem "realtime"

   ```bash
   kubectl exec <tên-pod-nginx> -- less +F /var/log/nginx/access.log
   ```

## Xóa nginx pod 0 rồi kiểm tra xem pod có tạo lại và có còn dữ liệu access log cũ không?

- Bước 1: Xác định tên của các pods nginx

   ```bash
   kubectl get pods -l app=nginx
   ```

- Bước 2: Xóa các pod

   ```bash
   kubectl delete pod <tên-pod-nginx>
   ```

- Bước 3: Lặp lại bước 1 để xem các pod của nginx có được tạo lại?

- Bước 4: Kiểm tra dữ liệu access log cũ

   ```bash
   kubectl exec <tên-pod-nginx-vừa-tạo-lại> -- cat /var/log/nginx/access.log
   ```
