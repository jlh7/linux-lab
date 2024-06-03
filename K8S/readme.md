# Container Orchestration Engine (COE) - K8S

## Định nghĩa

Container Orchestration Engine là một hệ thống tự động hóa việc triển khai, quản lý, nhân rộng và kết nối mạng của các container. Nó giúp các nhà phát triển và quản trị hệ thống có thể triển khai ứng dụng trên quy mô lớn mà không cần lo lắng về cơ sở hạ tầng cơ bản.

Ví dụ thực tế về việc sử dụng Container Orchestration Engine có thể kể đến **Kubernetes** (hay K8S), một nền tảng mã nguồn mở phổ biến cho việc quản lý container. Kubernetes giúp tự động hóa việc quản lý, mở rộng quy mô và triển khai ứng dụng dưới dạng container, loại bỏ nhiều quy trình thủ công liên quan đến việc triển khai và mở rộng các ứng dụng container hóa. Nó cho phép xây dựng các dịch vụ ứng dụng mở rộng qua nhiều container, lên lịch các container trên một cụm, mở rộng các container và quản lý tình trạng của chúng theo thời gian.

## Tính năng

Container Orchestration Engine cung cấp nhiều tính năng quan trọng để quản lý các container trong môi trường sản xuất, dưới đây là một số tính năng cơ bản:

1. **Khởi động và dừng container**:

   - Tự động hóa việc khởi tạo và ngừng hoạt động của các container.
   - **Ví dụ**: Kubernetes sử dụng các `Pods` để khởi động container. Khi một `Pod` không còn cần thiết, Kubernetes sẽ tự động dừng và xóa `Pod` đó.

2. **Lập lịch**:

   - Xác định thời gian chạy cụ thể cho từng container.
   - **Ví dụ**: Kubernetes có một bộ lập lịch (`Scheduler`) để quyết định container nào sẽ chạy trên node nào dựa trên tài nguyên có sẵn và yêu cầu của container.

3. **Quản lý tài nguyên**:

   - Phân phối và giới hạn tài nguyên như CPU, bộ nhớ, và dung lượng lưu trữ cho các container.
   - **Ví dụ**: Kubernetes cho phép định nghĩa `Requests` và `Limits` cho tài nguyên để đảm bảo rằng các container có đủ tài nguyên cần thiết và không sử dụng quá mức cho phép.

4. **Tính sẵn có và khả năng phục hồi**:

   - Đảm bảo ứng dụng vẫn hoạt động ngay cả khi có sự cố với container hoặc máy chủ.
   - **Ví dụ**: Kubernetes sử dụng `ReplicaSets` để duy trì số lượng bản sao của container. Nếu một container gặp sự cố, `ReplicaSet` sẽ tự động khởi động một container mới để thay thế.

5. **Mở rộng quy mô**:

   - Tăng hoặc giảm số lượng container dựa trên nhu cầu thực tế và khối lượng công việc.
   - **Ví dụ**: Kubernetes có khả năng `auto-scaling` thông qua `Horizontal Pod Autoscaler`, điều chỉnh số lượng `Pods` dựa trên sử dụng CPU hoặc các chỉ số khác.

6. **Cân bằng tải và định tuyến lưu lượng**:

   - Phân phối lưu lượng mạng đến các container một cách hiệu quả.
   - **Ví dụ**: Kubernetes sử dụng `Services` và `Ingress` để quản lý lưu lượng mạng và cân bằng tải giữa các `Pods`.

7. **Giám sát và bảo mật**:

   - Theo dõi tình trạng hoạt động và đảm bảo an ninh cho các container.
   - **Ví dụ**: Kubernetes tích hợp với các công cụ như `Prometheus` để giám sát và `Network Policies` để kiểm soát lưu lượng mạng giữa các `Pods`, tăng cường bảo mật.

## K8S

### Concept

Khi khởi tạo một cụm Kubernetes sử dụng `kubeadm`, nó sẽ tự động pull một loạt các image container cần thiết để thiết lập và chạy cụm. Dưới đây là phân tích của các image mà `kubeadm` thường pull về:

1. **kube-apiserver**:

   - Đây là server API của Kubernetes, nơi mà tất cả các yêu cầu RESTful được xử lý. Nó cung cấp giao diện cho người dùng, các dịch vụ nội bộ và các thành phần khác của cụm.
   - Là điểm trung tâm của cụm Kubernetes, nơi tiếp nhận và xử lý tất cả các yêu cầu API. Nó cần thiết để cung cấp giao diện cho người dùng và các thành phần khác của cụm.
   - **Ví dụ**: Khi chạy lệnh `kubectl get pods`, lệnh này sẽ gửi yêu cầu đến `kube-apiserver` để truy xuất thông tin về các Pods.

2. **kube-controller-manager**:

   - Chứa các bộ điều khiển mà theo dõi trạng thái của cụm và thực hiện các thay đổi để đạt được trạng thái mong muốn.
   - **Ví dụ**: `ReplicaSet` đảm bảo số lượng Pods mong muốn luôn được duy trì. Nếu một Pod bị hỏng, `kube-controller-manager` sẽ tạo một Pod mới để thay thế.

3. **kube-scheduler**:

   - Xác định node nào sẽ chạy Pod dựa trên các yêu cầu tài nguyên và các ràng buộc khác.
   - Quyết định Pod nào sẽ chạy trên node nào dựa trên tài nguyên có sẵn và yêu cầu của Pod.
   - **Ví dụ**: Khi một Pod mới được tạo, `kube-scheduler` sẽ chọn một node phù hợp để chạy Pod đó, dựa trên các yêu cầu tài nguyên và sự sẵn có của node.

4. **kube-proxy**:

   - Là một proxy mạng chạy trên mỗi node trong cụm, giúp duy trì các quy tắc mạng và cho phép giao tiếp giữa các dịch vụ.
   - Duy trì các quy tắc mạng trên mỗi node, cho phép giao tiếp giữa các dịch vụ trong cụm.
   - **Ví dụ**: `kube-proxy` có thể cân bằng tải lưu lượng mạng đến các Pods của một dịch vụ, đảm bảo rằng không có Pod nào bị quá tải.

5. **pause**:

   - Image này được sử dụng để tạo ra một container cơ bản mà các container khác trong cùng Pod có thể chia sẻ mạng và tài nguyên lưu trữ.
   - Image này được sử dụng làm container cơ bản cho mỗi Pod, nơi các container khác trong Pod có thể chia sẻ mạng và tài nguyên lưu trữ.
   - **Ví dụ**: Container `pause` hoạt động như một điểm neo cho các container khác trong cùng Pod, giữ cho chúng cùng một namespace mạng.

6. **etcd**:

   - Là cơ sở dữ liệu phân tán được sử dụng để lưu trữ tất cả dữ liệu cấu hình và trạng thái của cụm.
   - Là cơ sở dữ liệu phân tán lưu trữ tất cả dữ liệu cấu hình và trạng thái của cụm, đóng vai trò là 'bộ nhớ' cho cụm.
   - **Ví dụ**: Khi thay đổi cấu hình của một dịch vụ, thông tin này được lưu trữ trong `etcd`, và `kube-apiserver` sẽ truy vấn `etcd` để lấy thông tin cấu hình mới.

7. **coredns**:

   - Là một DNS server có thể được sử dụng trong cụm Kubernetes để cung cấp tên miền cho các dịch vụ và Pod.
   - Cung cấp dịch vụ phân giải tên miền trong cụm, cho phép các dịch vụ và Pods giao tiếp với nhau thông qua tên miền.
   - **Ví dụ**: Khi một Pod cần giao tiếp với dịch vụ khác, `coredns` sẽ giúp chuyển đổi tên dịch vụ thành địa chỉ IP tương ứng để giao tiếp có thể diễn ra.
