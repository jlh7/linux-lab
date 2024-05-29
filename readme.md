# Làm việc với Persistent Volume

## Tạo 2 persistent volume, type là host path

- Bước 1: Tạo thư mục liên kết trên Node worker-5

  ```bash
  sudo mkdir -p /k8s-data/pv-work3r-5
  ```

- Bước 2: Tạo thư mục liên kết trên Node worker-6

  ```bash
  sudo mkdir -p /k8s-data/pv-work3r-6
  ```

- Bước 3: Tạo tệp YAML - `pv-work3r-5.yaml` cho Persistent Volume trên Node worker-5

  ```yaml
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: pv-work3r-5
  spec:
    capacity:
      storage: 500Mi
    accessModes:
      - ReadWriteOnce
    hostPath:
      path: "/k8s-data/pv-work3r-5"
    nodeAffinity:
      required:
        nodeSelectorTerms:
          - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                  - "worker-5"
  ```

- Bước 3: Tạo tệp YAML - `pv-work3r-6.yaml` cho Persistent Volume trên Node worker-6

  Tương tự như trên, nhưng thay đổi `name` thành `pv-work3r-6` và `path` thành `"/k8s-data/pv-work3r-6"`, và thay `"worker-5"` bằng `"worker-6"`.

- Bước 4: Áp dụng các tệp YAML từ máy của bạn hoặc từ master node:

   ```bash
   kubectl apply -f pv-work3r-5.yaml
   kubectl apply -f pv-work3r-6.yaml
   ```

- Bước 5: Kiểm tra Persistent Volumes:

   ```bash
   kubectl get pv
   ```

## Tạo 2 Persistent Volume Claim, gắn nó với 2 PV đã tạo ở trên

- Bước 1: Tạo tệp YAML cho Persistent Volume Claim trên Node worker-5

  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: pvc-work3r-5
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 500Mi
    volumeName: pv-work3r-5
  ```

- Bước 2: Tạo tệp YAML cho Persistent Volume Claim trên Node C

  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: pvc-work3r-6
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 500Mi
    selector:
      matchLabels:
        name: pv-work3r-6
  ```

- Bước 3: Áp dụng các tệp YAML

  ```bash
  kubectl apply -f pvc-node-b.yaml
  kubectl apply -f pvc-node-c.yaml
  ```

- Bước 4: Kiểm tra Persistent Volume Claims

  ```bash
  kubectl get pvc
  ```

## Tạo 1 statefulset với image nginx, có 2 pod, cấu hình cho mỗi pod gắn với 1 PVC đã tạo ở trên, mount volume sao cho log của nginx được ghi ra PV

- Bước 1: Tạo ConfigMap cho cấu hình Nginx:

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

- Bước 2: Tạo tệp YAML cho StatefulSet:

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
            name: nginx-test
          volumeMounts:
          - name: nginx-logs
            mountPath: /var/log/nginx
        volumes:
        - name: nginx-log
          persistentVolumeClaim:
            claimName: pvc-work3r-5
  ```

- Bước 3: Áp dụng ConfigMap và StatefulSet:

  ```bash
  kubectl apply -f nginx-config.yaml
  kubectl apply -f nginx-statefulset.yaml
  ```

- Bước 5: Kiểm tra:

  - Kiểm tra trạng thái của StatefulSet:

    ```bash
    kubectl get pods
    ```

  - Kiểm tra log của Nginx:

    ```bash
    kubectl logs <pod name> -c nginx
    ```

## Tạo 1 service để expose statefullset trên (tên service là nginx-service)

- Bước 1: Tạo tệp YAML cho Service\

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
       - port: 80
         targetPort: 80
         nodePort: 8080
   ```

- Bước 2: Áp dụng tệp YAML

   ```bash
   kubectl apply -f service.yaml
   ```

- Bước 3: Kiểm tra Service

   ```bash
   kubectl get service nginx-service
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
   curl http://<service ip address>:8080
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
