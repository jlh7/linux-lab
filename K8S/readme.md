# Container Orchestration Engine (COE) - K8S

## I. Định nghĩa

Container Orchestration Engine là một hệ thống tự động hóa việc triển khai, quản lý, nhân rộng và kết nối mạng của các container. Nó giúp các nhà phát triển và quản trị hệ thống có thể triển khai ứng dụng trên quy mô lớn mà không cần lo lắng về cơ sở hạ tầng cơ bản.

Ví dụ thực tế về việc sử dụng Container Orchestration Engine có thể kể đến **Kubernetes** (hay K8S), một nền tảng mã nguồn mở phổ biến cho việc quản lý container. Kubernetes giúp tự động hóa việc quản lý, mở rộng quy mô và triển khai ứng dụng dưới dạng container, loại bỏ nhiều quy trình thủ công liên quan đến việc triển khai và mở rộng các ứng dụng container hóa. Nó cho phép xây dựng các dịch vụ ứng dụng mở rộng qua nhiều container, lên lịch các container trên một cụm, mở rộng các container và quản lý tình trạng của chúng theo thời gian.

## II. Tính năng

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

## III. K8S

### 1. Concept

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

### 2. Components

Kubernetes, thường được gọi là K8s, là một hệ thống điều phối container mạnh mẽ giúp tự động hóa việc triển khai, mở rộng và quản lý các ứng dụng container hóa. Dưới đây là giải thích và phân tích các thành phần chính của Kubernetes:

#### A. Control Plane Components

Control Plane là bộ não của cụm Kubernetes, quản lý trạng thái toàn cục của cụm.

- **kube-apiserver**: Là cổng giao tiếp API của Kubernetes, nơi tiếp nhận và xử lý tất cả các yêu cầu API từ người dùng và các thành phần nội bộ.
- **etcd**: Là cơ sở dữ liệu key-value phân tán, lưu trữ tất cả dữ liệu cấu hình và trạng thái của cụm, đóng vai trò như 'bộ nhớ' cho cụm.
- **kube-scheduler**: Theo dõi các Pods mới được tạo mà chưa được gán node và chọn node phù hợp để chạy các Pods đó.
- **kube-controller-manager**: Chạy các quy trình điều khiển, quản lý các bộ điều khiển như ReplicationController, EndpointsController, và các bộ điều khiển khác.
- **cloud-controller-manager**: Cho phép liên kết cụm với các API của nhà cung cấp dịch vụ đám mây và tách biệt các thành phần quản lý cụm khỏi các thành phần tương tác với nền tảng đám mây.

#### B. Node Components

Node Components chạy trên mỗi node, duy trì các Pods đang chạy và cung cấp môi trường runtime cho Kubernetes.

- **kubelet**: Đảm bảo rằng các Pods và Container đang chạy trên một node.
- **kube-proxy**: Duy trì các quy tắc mạng trên node để cho phép giao tiếp giữa các dịch vụ trong cụm.
- **Container Runtime**: Phần mềm chịu trách nhiệm chạy container, như Docker hoặc rkt.

#### C. Addons

Addons sử dụng các tài nguyên Kubernetes để cung cấp các tính năng mở rộng.

- **DNS**: Tất cả các cụm Kubernetes đều nên có DNS cụm, là một dịch vụ DNS tự động ánh xạ tên miền cho IP của các dịch vụ.
- **Web UI (Dashboard)**: Cung cấp giao diện người dùng dựa trên web để quản lý và giám sát các ứng dụng container hóa trong cụm.
- **Container Resource Monitoring**: Ghi lại các thông số hiệu suất cơ bản của container trong cụm và cung cấp giao diện người dùng để duyệt dữ liệu này.
- **Cluster-level Logging**: Chịu trách nhiệm ghi lại log từ các container trong cụm và cung cấp cơ chế để lưu trữ và truy vấn các log này.

### 2. Kind

Trong Kubernetes (K8s), "Kind" chỉ loại tài nguyên mà bạn muốn K8s quản lý. Mỗi Kind đại diện cho một loại đối tượng cụ thể trong K8s và có một bộ thuộc tính và hành vi riêng. Dưới đây là định nghĩa, phân tích và ví dụ thực tế cho một số Kind phổ biến:

#### A. Pod

- **Định nghĩa**: Pod là đơn vị cơ bản nhất của K8s, chứa một hoặc nhiều container chạy cùng nhau.
- **Phân tích**: Pods là nơi container được triển khai và chạy. Chúng chia sẻ cùng một namespace mạng, có thể chứa nhiều container liên quan đến nhau.
- **Ví dụ thực tế**: Một ứng dụng web và cơ sở dữ liệu cache của nó có thể được đặt trong cùng một Pod để tối ưu hóa việc giao tiếp.

#### B. Service

- **Định nghĩa**: Service là một cách để truy cập các ứng dụng chạy trên một tập hợp các Pods.
- **Phân tích**: Service cung cấp một địa chỉ IP cố định và một DNS name để các Pods có thể giao tiếp với nhau hoặc với bên ngoài cụm.
- **Ví dụ thực tế**: Một Service có thể được sử dụng để cân bằng tải giữa các Pods chạy cùng một ứng dụng web.

#### C. Deployment

- **Định nghĩa**: Deployment quản lý việc triển khai và cập nhật các ứng dụng trên cụm K8s.
- **Phân tích**: Deployment cho phép bạn mô tả trạng thái mong muốn của ứng dụng, K8s sẽ tự động thay đổi trạng thái hiện tại để phù hợp với trạng thái đó.
- **Ví dụ thực tế**: Triển khai một ứng dụng mới hoặc cập nhật phiên bản mới cho ứng dụng mà không gây gián đoạn dịch vụ.

#### D. StatefulSet

- **Định nghĩa**: StatefulSet là dành cho các ứng dụng cần duy trì trạng thái, như cơ sở dữ liệu.
- **Phân tích**: StatefulSet quản lý việc triển khai và mở rộng quy mô cho các ứng dụng có trạng thái, đảm bảo thứ tự và tính duy nhất của các Pods.
- **Ví dụ thực tế**: Quản lý một cụm cơ sở dữ liệu MongoDB với việc đảm bảo thứ tự khởi động và dữ liệu đồng bộ giữa các bản sao.

#### F. DaemonSet

- **Định nghĩa**: DaemonSet đảm bảo rằng mỗi node trong cụm sẽ chạy một bản sao của một Pod nhất định.
- **Phân tích**: DaemonSet thường được sử dụng cho các dịch vụ cấp hệ thống như log collectors hoặc monitoring agents.
- **Ví dụ thực tế**: Triển khai một agent giám sát trên mỗi node để thu thập thông tin về hiệu suất và sử dụng tài nguyên.

#### G. Job

- **Định nghĩa**: Job tạo ra một hoặc nhiều Pods và đảm bảo rằng một số lượng nhất định của chúng chạy thành công đến hoàn tất.
- **Phân tích**: Job thích hợp cho các tác vụ xử lý theo lô hoặc các tác vụ cần chạy đến hoàn tất.
- **Ví dụ thực tế**: Xử lý hàng loạt dữ liệu hoặc thực hiện một tác vụ tính toán một lần.

#### H. ConfigMap

- **Định nghĩa**: ConfigMap cho phép bạn lưu trữ dữ liệu cấu hình không mật mã dưới dạng cặp key-value⁸.
- **Phân tích**: ConfigMap được sử dụng để tách biệt cấu hình môi trường cụ thể khỏi các image container, giúp ứng dụng dễ dàng di chuyển giữa các môi trường⁹.
- **Ví dụ thực tế**: Một ConfigMap có thể chứa thông tin cấu hình như tên host cơ sở dữ liệu, được các Pods sử dụng qua biến môi trường hoặc tệp cấu hình[^10^].

#### I. Secrets

- **Định nghĩa**: Secrets chứa dữ liệu nhạy cảm như mật khẩu, token, hoặc khóa bí mật⁵.
- **Phân tích**: Sử dụng Secrets giúp bạn không cần phải bao gồm dữ liệu mật trong mã ứng dụng và giảm nguy cơ tiết lộ thông tin khi tạo, xem và chỉnh sửa Pods⁶.
- **Ví dụ thực tế**: Một Secret có thể chứa thông tin đăng nhập cần thiết để Pods truy cập vào một dịch vụ như cơ sở dữ liệu.

#### J. Volumes

- **Định nghĩa**: Volumes là một phần của Pod và được sử dụng để lưu trữ dữ liệu trên đĩa, giúp dữ liệu tồn tại qua các lần khởi động lại container⁴.
- **Phân tích**: Volumes có thể là ephemeral, tồn tại cùng với lifecycle của Pod, hoặc là persistent, tồn tại độc lập với Pod⁵.
- **Ví dụ thực tế**: Một Volume kiểu `emptyDir` có thể được sử dụng để chia sẻ dữ liệu tạm thời giữa các container trong cùng một Pod⁶.

#### K. Namespace

- **Định nghĩa**: Namespace cung cấp cơ chế để phân lập nhóm tài nguyên trong một cluster. Tên của tài nguyên cần phải duy nhất trong một Namespace nhưng không cần phải duy nhất giữa các Namespace.
- **Phân tích**: Namespace thường được sử dụng trong môi trường có nhiều người dùng, đội ngũ hoặc dự án khác nhau để chia sẻ cluster.
- **Ví dụ thực tế**: Bạn có thể tạo Namespace `development` cho môi trường phát triển và `production` cho môi trường sản xuất, giúp quản lý tài nguyên và phân quyền truy cập một cách hiệu quả.

### 3. Namespace

Namespace trong Kubernetes (K8s) là một cơ chế cung cấp khả năng phân lập tài nguyên giữa các nhóm khác nhau trong cùng một cụm. Dưới đây là phân tích chi tiết về Namespace:

#### A. Khái Niệm Namespace

- **Giải thích**: Namespace là một phạm vi logic được sử dụng để nhóm và phân lập các đối tượng trong K8s, như Pods, Services, và Deployments.
- **Mục đích**: Namespace giúp quản lý tài nguyên trong các môi trường có nhiều người dùng, dự án hoặc đội ngũ, bằng cách cung cấp phạm vi tên và quyền truy cập riêng biệt.

#### B. Quản Lý Namespace

- **Tạo và Xóa**: Bạn có thể tạo hoặc xóa Namespace bằng cách sử dụng `kubectl`.
- **Phân Quyền**: Namespace cho phép bạn áp dụng các chính sách RBAC (Role-Based Access Control) để kiểm soát quyền truy cập vào tài nguyên.

#### C. Sử Dụng Namespace

- **Phân Biệt Môi Trường**: Các tổ chức thường sử dụng Namespace để phân biệt giữa các môi trường như phát triển (dev), kiểm thử (qa), và sản xuất (prod)⁵.
- **Quản Lý Tài Nguyên**: Namespace giúp áp dụng các giới hạn tài nguyên (resource quota) để quản lý việc sử dụng CPU, bộ nhớ, và lưu trữ.

#### D. Lưu Ý Khi Sử Dụng Namespace

- **Không Dùng Cho Tất Cả Đối Tượng**: Một số đối tượng trong K8s là toàn cụm (cluster-wide), như StorageClass hoặc Nodes, và không được phân lập bởi Namespace.
- **Tên Đối Tượng Duy Nhất**: Tên của các đối tượng cần phải duy nhất trong một Namespace, nhưng có thể giống nhau giữa các Namespace khác nhau.

#### E. Ví dụ Cấu Hình Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace
```

- **Giải thích**: Trong ví dụ này, một Namespace mới có tên `my-namespace` được tạo ra. Namespace này có thể được sử dụng để nhóm các tài nguyên liên quan đến một dự án hoặc đội ngũ cụ thể.

### 4. Pod

Pods trong Kubernetes (K8s) là các đơn vị cơ bản nhất mà bạn có thể tạo và quản lý trong một cụm K8s. Dưới đây là phân tích chi tiết về Pods:

#### A. Khái Niệm Pod

- **Giải thích**: Pod là một nhóm gồm một hoặc nhiều container ứng dụng, cùng với lưu trữ được chia sẻ, địa chỉ IP, và thông tin về cách chạy từng container.
- **Đặc điểm**: Các container trong một Pod chia sẻ một địa chỉ IP và port space, chúng luôn được đặt cùng vị trí, cùng lên lịch trình, và chạy trong ngữ cảnh được chia sẻ trên cùng một Node.

#### B. Thành Phần và Cấu Trúc của Pod

- **Metadata**: Chứa thông tin như tên, nhãn, và namespace mà Pod thuộc về.
- **Spec**: Chứa thông tin cấu hình của Pod và các container bên trong, bao gồm image container, ports, và volumes.
- **Status**: Cung cấp thông tin về trạng thái hiện tại của Pod, bao gồm trạng thái của các container, địa chỉ IP, và thông tin về lần khởi động cuối cùng.

#### C. Tầm Quan Trọng của Pod

- **Mô phỏng "máy chủ logic"**: Mỗi Pod hoạt động như một máy chủ riêng biệt, có thể chứa các ứng dụng container khác nhau được liên kết chặt chẽ.
- **Đơn vị nhân bản**: Kubernetes có thể nhân bản ra nhiều Pod có chức năng giống nhau để tránh quá tải và đảm bảo tính sẵn sàng.

#### D. Ví dụ Thực Tế về Pod

- **Ứng dụng Web và Cơ sở dữ liệu**: Một Pod có thể chứa cả container với ứng dụng web Node.js và một container khác cung cấp dữ liệu cho webserver của Node.js.
- **Giám sát và Logging**: Một Pod có thể chứa một ứng dụng chính cùng với các container hỗ trợ như log collector hoặc monitoring agent.

### 5. ConfigMap

ConfigMap trong Kubernetes (K8s) là một API object được sử dụng để lưu trữ dữ liệu cấu hình không mật mã dưới dạng cặp key-value. Pods có thể tiêu thụ ConfigMaps như là biến môi trường, đối số dòng lệnh, hoặc như các tệp cấu hình trong một volume.

#### A. Đặc Điểm của ConfigMap

- **Lưu Trữ Dữ Liệu Cấu Hình**: ConfigMap cho phép bạn lưu trữ cấu hình dưới dạng cặp key-value, giúp bạn tách biệt cấu hình môi trường cụ thể khỏi các image container.
- **Khả Năng Tiêu Thụ Linh Hoạt**: Các ứng dụng có thể sử dụng ConfigMap thông qua biến môi trường, đối số khi chạy container, hoặc thông qua volume để đọc cấu hình dưới dạng tệp.
- **Dễ Dàng Cập Nhật**: ConfigMap cho phép bạn cập nhật cấu hình mà không cần phải xây dựng lại hoặc triển khai lại image container.

#### B. Cách Sử Dụng ConfigMap

- **Tạo ConfigMap**: Bạn có thể tạo ConfigMap từ tệp cấu hình, từ các giá trị literal, hoặc từ các cặp key-value.
- **Áp Dụng ConfigMap**: Áp dụng ConfigMap vào Pods bằng cách tham chiếu đến nó trong định nghĩa Pod hoặc sử dụng nó trong Deployment, StatefulSet, hoặc các workload khác.

#### C. Ví dụ Cấu Hình ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-configmap
data:
  # Các cặp key-value
  database_url: db.example.com
  database_user: user
```

- **Giải thích**: Trong ví dụ này, một ConfigMap có tên `example-configmap` được tạo ra với hai cặp key-value, lưu trữ thông tin cấu hình cho một cơ sở dữ liệu.

#### D. Lưu Ý Khi Sử Dụng ConfigMap

- **Không Dùng Cho Dữ Liệu Mật**: ConfigMap không cung cấp tính bảo mật hoặc mã hóa. Nếu bạn cần lưu trữ dữ liệu mật, bạn nên sử dụng Secret thay vì ConfigMap.
- **Giới Hạn Dung Lượng**: Dữ liệu lưu trữ trong ConfigMap không được vượt quá 1 MiB. Nếu bạn cần lưu trữ cấu hình lớn hơn giới hạn này, bạn có thể cần xem xét việc sử dụng volume hoặc dịch vụ lưu trữ tệp riêng biệt.

### 6. Secret

Secrets trong Kubernetes (K8s) là một API object được thiết kế để lưu trữ và quản lý thông tin nhạy cảm, như mật khẩu, token OAuth, và khóa SSH. Dưới đây là phân tích chi tiết về Secrets:

#### A. Đặc Điểm của Secrets

- **Bảo Mật Thông Tin**: Secrets giúp bạn quản lý thông tin nhạy cảm mà không cần phải đặt chúng trực tiếp trong định nghĩa Pod hoặc image container.
- **Mã Hóa**: Mặc dù Secrets được mã hóa dưới dạng chuỗi base64 và lưu trữ không mã hóa theo mặc định, bạn có thể cấu hình để mã hóa Secrets tại nơi lưu trữ (at rest).

#### B. Cách Sử Dụng Secrets

- **Tạo Secrets**: Bạn có thể tạo Secrets từ tệp cấu hình, từ các giá trị literal, hoặc từ các cặp key-value⁴.
- **Tiêu Thụ Secrets**: Pods có thể sử dụng Secrets thông qua biến môi trường, đối số dòng lệnh, hoặc như các tệp cấu hình trong một volume.

#### C. Quản Lý Secrets

- **Cập Nhật và Quản Lý**: Secrets có thể được cập nhật và quản lý mà không cần phải tái tạo hoặc triển khai lại Pods sử dụng chúng⁵.
- **RBAC và Quyền Truy Cập**: Nên sử dụng Role-based Access Control (RBAC) để kiểm soát quyền truy cập vào Secrets, đảm bảo rằng chỉ những người dùng hoặc quy trình cần thiết mới có thể truy cập.

#### D. Lưu Ý Khi Sử Dụng Secrets

- **Lưu Trữ An Toàn**: Mặc dù Secrets được lưu trữ trong etcd, bạn nên cấu hình mã hóa tại nơi lưu trữ để tăng cường bảo mật.
- **Tránh Lộ Lọt Thông Tin**: Cẩn thận khi cấp quyền truy cập vào Secrets, vì việc lộ lọt có thể dẫn đến rủi ro bảo mật.

#### E. Ví dụ Cấu Hình Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```

- **Giải thích**: Trong ví dụ này, một Secret có tên `my-secret` được tạo ra với username và password được mã hóa base64. Loại `Opaque` cho biết đây là một Secret chứa thông tin tùy ý.

### 7. Service

Trong Kubernetes (K8s), Service là một tài nguyên quan trọng giúp định nghĩa cách thức truy cập mạng đến một nhóm các Pods, thường là để cung cấp một dịch vụ cụ thể. Dưới đây là phân tích chi tiết về Service trong K8s:

#### A. Khái Niệm Service

- **Giải thích**: Service cho phép bạn truy cập các ứng dụng mạng chạy trên một hoặc nhiều Pods trong cụm của bạn.
- **Mục Tiêu**: Mục tiêu của Service trong K8s là bạn không cần phải sửa đổi ứng dụng hiện có của mình để sử dụng cơ chế khám phá dịch vụ không quen thuộc.

#### B. Các Loại Service

- **ClusterIP**: Đây là loại Service mặc định, cung cấp một địa chỉ IP nội bộ trong cụm, cho phép truy cập Service từ bên trong cụm.
- **NodePort**: Mở một cổng cụ thể (NodePort) trên tất cả các Node (máy chủ), và bất kỳ yêu cầu nào đến cổng này sẽ được chuyển tiếp đến Service.
- **LoadBalancer**: Tích hợp với các bộ cân bằng tải của nhà cung cấp dịch vụ đám mây để phân phối lưu lượng đến Service.
- **ExternalName**: Ánh xạ Service đến một tên DNS bên ngoài cụm, thường được sử dụng khi bạn muốn truy cập một dịch vụ nằm ngoài cụm K8s của mình.

#### C. Cách Hoạt Động của Service

- **Selector**: Service thường xác định nhóm Pods mục tiêu thông qua selector, cho phép Service biết cách chuyển tiếp yêu cầu đến Pods.
- **Endpoints**: Service tạo ra một tập hợp các Endpoints, tức là địa chỉ IP của các Pods, và quản lý việc truy cập đến các Pods này.
- **Session Affinity**: Có thể cấu hình để duy trì phiên người dùng, đảm bảo rằng tất cả các yêu cầu từ một người dùng cụ thể được chuyển đến cùng một Pod.

#### D. Ví dụ Thực Tế về Service

- **Ứng dụng Web**: Một Service có thể được sử dụng để cân bằng tải giữa các Pods chạy một ứng dụng web, đảm bảo rằng lưu lượng người dùng được phân phối đều.
- **Cơ sở dữ liệu**: Service có thể được cấu hình để chỉ chuyển tiếp yêu cầu đến các Pods chạy cơ sở dữ liệu, giúp cô lập và bảo vệ dữ liệu quan trọng.

### 8. Volumes

Volumes trong Kubernetes (K8s) là một thành phần cốt lõi giúp quản lý lưu trữ dữ liệu trong các Pods. Dưới đây là phân tích chi tiết về Volumes:

#### A. Khái Niệm Volumes

- **Giải thích**: Volume trong K8s là một thư mục có thể chứa dữ liệu, và thư mục này có thể được truy cập bởi các container trong cùng một Pod.
- **Mục đích**: Volume giải quyết vấn đề lưu trữ dữ liệu khi container trong Pod bị khởi động lại hoặc bị xóa, và cung cấp khả năng chia sẻ dữ liệu giữa các container.

#### B. Loại Volumes

K8s hỗ trợ nhiều loại Volumes khác nhau, mỗi loại phục vụ cho các mục đích cụ thể:

- **Ephemeral Volumes**: Có vòng đời ngắn, tồn tại cùng với Pod và bị xóa khi Pod không còn tồn tại.
- **Persistent Volumes**: Tồn tại độc lập với Pod, giúp dữ liệu vẫn còn nguyên vẹn ngay cả khi Pod bị xóa.

#### C. Cách Sử Dụng Volumes

- **Định nghĩa Volumes**: Trong định nghĩa Pod, bạn cần chỉ định các Volumes mà Pod sẽ sử dụng trong `.spec.volumes`.
- **Mount Volumes vào Containers**: Trong mỗi container, bạn cần chỉ định nơi mount Volume thông qua `.spec.containers[*].volumeMounts`.

#### D. Ví dụ Cấu Hình Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
        - mountPath: "/var/www/html"
          name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
```

- **Giải thích**: Trong ví dụ này, Pod `mypod` có một container `myfrontend` sử dụng image `nginx`. Container này mount một PersistentVolumeClaim có tên `myclaim` vào đường dẫn `/var/www/html`.

#### E. Lưu Ý Khi Sử Dụng Volumes

- **Quản lý lưu trữ**: Quản lý Volumes và PersistentVolumeClaims cẩn thận để đảm bảo dữ liệu không bị mất và tài nguyên lưu trữ được sử dụng hiệu quả.
- **Bảo mật**: Cần phải đảm bảo rằng chỉ những Pods và Users có quyền mới có thể truy cập vào Volumes nhạy cảm.

### 9. Deployment

Trong Kubernetes (K8s), Deployment là một tài nguyên quan trọng giúp quản lý việc triển khai và cập nhật các Pods và ReplicaSets một cách khai báo. Dưới đây là phân tích chi tiết về Deployments trong K8s:

#### A. Khái Niệm Deployment

- **Giải thích**: Deployment cho phép bạn mô tả trạng thái mong muốn cho các Pods và ReplicaSets, và Deployment Controller sẽ thay đổi trạng thái thực tế để phù hợp với trạng thái mong muốn ở một tốc độ được kiểm soát.

#### B. Các Chức Năng Chính của Deployment

- **Triển khai Ứng Dụng**: Tạo một Deployment để triển khai một ReplicaSet, ReplicaSet này sẽ tạo ra các Pods ở nền.
- **Cập Nhật Ứng Dụng**: Khai báo trạng thái mới của các Pods bằng cách cập nhật PodTemplateSpec của Deployment. Một ReplicaSet mới được tạo và Deployment quản lý việc di chuyển Pods từ ReplicaSet cũ sang ReplicaSet mới.
- **Rollback**: Quay trở lại phiên bản Deployment trước nếu trạng thái hiện tại của Deployment không ổn định.
- **Scale Up**: Tăng số lượng Pods trong Deployment để xử lý nhiều tải công việc hơn.
- **Pause và Resume**: Tạm dừng triển khai của Deployment để áp dụng nhiều bản sửa lỗi cho PodTemplateSpec và sau đó tiếp tục để bắt đầu một triển khai mới.

#### C. Ví dụ Cấu Hình Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
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
          image: nginx:1.14.2
          ports:
            - containerPort: 80
```

- **Giải thích**: Trong ví dụ này, một Deployment tên là `nginx-deployment` được tạo ra. Deployment này tạo ra một ReplicaSet để triển khai ba Pods, mỗi Pod chạy một container từ image `nginx:1.14.2`.

#### D. Quản Lý Deployment

- **Cập Nhật Deployment**: Bạn có thể cập nhật một Deployment bằng cách thay đổi template của Pod. Khi template được cập nhật, Deployment tự động triển khai các Pod mới.
- **Rollback Deployment**: Nếu cập nhật không thành công, bạn có thể sử dụng lệnh `kubectl rollout undo` để quay trở lại phiên bản trước của Deployment.
- **Scale Deployment**: Để thay đổi số lượng Pods, bạn có thể sử dụng lệnh `kubectl scale` hoặc cấu hình tự động scale dựa trên sử dụng CPU hoặc các chỉ số khác.

### 10. StatefulSet

StatefulSet trong Kubernetes (K8s) là một API quan trọng được sử dụng để quản lý các ứng dụng có trạng thái (stateful). Dưới đây là phân tích chi tiết về StatefulSet:

#### A. Khái Niệm StatefulSet

- **Giải thích**: StatefulSet là một workload API object dùng để quản lý các ứng dụng có trạng thái. Nó quản lý việc triển khai và mở rộng quy mô của một tập hợp các Pods, đồng thời cung cấp đảm bảo về thứ tự và tính duy nhất của các Pods này.

#### B. Đặc Điểm của StatefulSet

- **Danh tính duy nhất**: Mỗi Pod trong StatefulSet có một danh tính duy nhất, bao gồm tên và số thứ tự cố định, không thay đổi ngay cả khi Pod được lập lịch lại trên một Node khác.
- **Lưu trữ liên tục**: StatefulSet cho phép Pods truy cập vào cùng một volume lưu trữ, ngay cả khi chúng được khởi động lại hoặc di chuyển giữa các Nodes⁵.
- **Quản lý trạng thái**: StatefulSet thích hợp cho các ứng dụng cần quản lý trạng thái, như cơ sở dữ liệu hoặc các hệ thống lưu trữ dữ liệu phân tán.

#### C. Cách Hoạt Động của StatefulSet

- **Quản lý Pod**: StatefulSet tạo và quản lý một tập hợp các Pod dựa trên cùng một định nghĩa container, nhưng mỗi Pod có một danh tính riêng biệt và không thể thay thế lẫn nhau.
- **Lưu trữ**: Khi sử dụng StatefulSet, bạn có thể định nghĩa các PersistentVolumeClaim để cung cấp lưu trữ liên tục cho mỗi Pod.
- **Cập nhật và Rollback**: StatefulSet hỗ trợ cập nhật tự động và có thể rollback về phiên bản trước đó nếu cần.

#### D. Ví dụ Cấu Hình StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
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
          image: nginx:1.14.2
          ports:
            - containerPort: 80
  volumeClaimTemplates:
    - metadata:
        name: www
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: "my-storage-class"
        resources:
          requests:
            storage: 1Gi
```

- **Giải thích**: Trong ví dụ này, StatefulSet có tên `web` được tạo ra với ba replicas. Mỗi Pod sẽ chạy một container từ image `nginx:1.14.2` và sử dụng một PersistentVolumeClaim với dung lượng 1Gi.

### 11. DaemonSet

DaemonSet trong Kubernetes (K8s) là một API quan trọng dùng để đảm bảo rằng mỗi Node (hoặc một số Node cụ thể) trong cụm chạy một bản sao của Pod. Khi Node mới được thêm vào cụm, Pod từ DaemonSet sẽ tự động được triển khai trên Node đó. Đây là cách lý tưởng để chạy các dịch vụ như hệ thống giám sát Node, agent thu thập log, hoặc proxy mạng trên mỗi Node.

#### A. Đặc Điểm của DaemonSet

- **Phân phối tự động**: Khi có Node mới được thêm vào cụm, DaemonSet sẽ tự động triển khai Pod tương ứng lên Node đó.
- **Duy trì dịch vụ**: DaemonSet đảm bảo rằng các dịch vụ cần thiết luôn chạy trên tất cả các Node, điều này rất quan trọng cho việc giám sát và logging.
- **Tolerations**: DaemonSet thường có các tolerations mặc định cho phép chúng được lên lịch trên các Node mà có thể không chấp nhận Pods khác do các ràng buộc tài nguyên hoặc các vấn đề khác.

#### B. Cách Hoạt Động của DaemonSet

DaemonSet sử dụng một bộ lọc selector để xác định các Node mà nó sẽ triển khai Pods. Bạn có thể cấu hình DaemonSet để chỉ chạy trên một tập hợp con của các Node hoặc trên tất cả các Node. Khi một Node bị loại bỏ khỏi cụm, Pod tương ứng được triển khai bởi DaemonSet cũng sẽ bị thu hồi.

#### C. Ví dụ Cấu Hình DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-elasticsearch
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      containers:
        - name: fluentd-elasticsearch
          image: quay.io/fluentd_elasticsearch/fluentd:v2.5.2
          resources:
            limits:
              memory: 200Mi
            requests:
              cpu: 100m
              memory: 200Mi
          volumeMounts:
            - name: varlog
              mountPath: /var/log
      volumes:
        - name: varlog
          hostPath:
            path: /var/log
```

- **Giải thích**: Trong ví dụ này, DaemonSet có tên `fluentd-elasticsearch` được tạo ra để chạy trên mỗi Node trong cụm. Mỗi Pod sẽ chạy một container từ image `fluentd_elasticsearch/fluentd:v2.5.2` và sử dụng một volume để gắn kết `/var/log` từ host vào container.

### 12. Job

Trong Kubernetes (K8s), Job là một API quan trọng dùng để quản lý các tác vụ batch, tức là các tác vụ ngắn hạn, một lần, cần được chạy đến hoàn thành. Dưới đây là phân tích chi tiết về Job trong K8s:

#### A. Khái Niệm Job

- **Giải thích**: Job tạo ra một hoặc nhiều Pods và sẽ tiếp tục thử nghiệm thực hiện các Pods cho đến khi một số lượng xác định của chúng kết thúc thành công.
- **Mục đích**: Job được sử dụng để thực hiện các tác vụ từ đầu đến cuối, như xử lý hàng loạt dữ liệu hoặc thực hiện một tác vụ tính toán.

#### B. Đặc Điểm của Job

- **Quản lý Pods**: Job quản lý việc tạo và theo dõi Pods. Nếu một Pod thất bại, Job có thể tạo Pod mới để thay thế, tùy thuộc vào chính sách thất bại được định nghĩa.
- **Đảm bảo hoàn thành**: Job đảm bảo rằng số lượng Pods cần thiết phải hoàn thành công việc trước khi coi Job là hoàn thành.
- **Parallelism và Completions**: Có thể định nghĩa số lượng Pods chạy song song (`parallelism`) và số lượng Pods cần hoàn thành công việc (`completions`).

#### C. Cách Hoạt Động của Job

- **Tạo Pods**: Khi một Job được tạo, nó sẽ tạo ra các Pods dựa trên định nghĩa trong `spec.template` của Job.
- **Theo dõi tiến trình**: Job theo dõi tiến trình của các Pods thông qua `status` và cập nhật thông tin về số lượng Pods đã hoàn thành.

#### D. Ví dụ Cấu Hình Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
        - name: pi
          image: perl:5.34.0
          command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

- **Giải thích**: Trong ví dụ này, một Job có tên `pi` được tạo ra để tính toán số Pi đến 2000 chữ số và in ra. Job này sẽ không thử khởi động lại Pod nếu nó thất bại, và sẽ thử tối đa 4 lần trước khi dừng lại.
