# Hướng dẫn Setup Flux trên Minikube

## 🎯 Mục đích
Khi bạn thay đổi file YAML và push lên GitHub → Minikube **tự động cập nhật** trong 10-30 giây.

---

## 📋 Bước 1: Chuẩn bị

### Yêu cầu:
- Minikube đã cài
- Git đã cài
- Kubectl đã cài
- Repo GitHub của bạn: https://github.com/nguyenhainam9122003/fluxCD-test

### Khởi động Minikube:
```bash
minikube start --cpus 4 --memory 4096
minikube status  # Kiểm tra xem đã chạy chưa
```

---

## 📦 Bước 2: Cài Flux CLI

```bash
curl -s https://fluxcd.io/install.sh | sudo bash

# Kiểm tra cài thành công
flux version
```

---

## ✅ Bước 3: Kiểm tra điều kiện tiên quyết

```bash
flux check --pre
```

**Kết quả mong đợi:** Tất cả bắt đầu với ✓

---

## 🚀 Bước 4: Cài FluxCD trên Minikube

```bash
flux install --components=source-controller,kustomize-controller,helm-controller
```

**Kiểm tra:**
```bash
kubectl get pods -n flux-system
# Bạn sẽ thấy các pod: source-controller, kustomize-controller, helm-controller
```

---

## 🔗 Bước 5: Kết nối GitHub Repository

```bash
flux create source git fluxcd-test \
  --url=https://github.com/nguyenhainam9122003/fluxCD-test.git \
  --branch=main \
  --interval=10s \
  --namespace=flux-system
```

**Kiểm tra:**
```bash
flux get sources git -A
```

---

## 📦 Bước 6: Tạo Kustomization

```bash
flux create kustomization apps \
  --source=fluxcd-test \
  --path=./apps \
  --prune=true \
  --wait=true \
  --interval=10s \
  --namespace=flux-system
```

**Kiểm tra:**
```bash
flux get kustomizations -A
```

---

## 🎉 Bước 7: Xác minh Setup thành công

### Kiểm tra status:
```bash
flux get all -A
```

### Kiểm tra xem Nginx đã deploy chưa:
```bash
kubectl get deployment -A
kubectl get pods -A
```

Bạn sẽ thấy `nginx-example` deployment được tạo!

---

## 🔄 Cách sử dụng - Tự động cập nhật

### Quy trình:
1. **Sửa file YAML** trong `apps/` (ví dụ: thay đổi replica từ 2 → 3)
2. **Commit & Push** lên GitHub:
   ```bash
   git add .
   git commit -m "Update nginx replicas"
   git push
   ```
3. **Flux tự động detect** (trong 10 giây)
4. **Minikube tự động apply** những thay đổi

### Xem logs để kiểm tra:
```bash
flux logs -f
```

---

## 📊 Ví dụ thực tế

### Thay đổi số lượng Nginx replicas:

1. **Sửa file:**
   ```bash
   # Mở: apps/nginx-example/deployment.yaml
   # Sửa: replicas: 2 → replicas: 3
   ```

2. **Commit & Push:**
   ```bash
   git add apps/nginx-example/deployment.yaml
   git commit -m "Scale nginx to 3 replicas"
   git push
   ```

3. **Kiểm tra trong Minikube:**
   ```bash
   # Chờ ~10 giây
   kubectl get pods
   # Bạn sẽ thấy 3 nginx pods thay vì 2
   ```

---

## 🛠️ Các lệnh hữu ích

```bash
# Xem status tất cả Flux resources
flux get all -A

# Xem logs realtime
flux logs -f

# Xem chi tiết GitRepository
flux get sources git -A

# Xem chi tiết Kustomization
flux get kustomizations -A

# Force reconciliation (không cần chờ 10 giây)
flux reconcile source git fluxcd-test -n flux-system
flux reconcile kustomization apps -n flux-system

# Xem deployment trên Minikube
kubectl get deployment -A
kubectl get pods -A

# Port-forward để test Nginx
kubectl port-forward svc/nginx-example 8080:80
# Sau đó mở browser: http://localhost:8080
```

---

## ⚠️ Troubleshooting

### Flux không update?
```bash
# Check logs
flux logs -f

# Check GitRepository status
kubectl describe gitrepository fluxcd-test -n flux-system

# Manual force sync
flux reconcile source git fluxcd-test -n flux-system
```

### Pod không chạy?
```bash
# Check pod logs
kubectl logs deployment/nginx-example

# Check events
kubectl describe pod <pod-name>
```

---

## 🎓 Nó hoạt động như thế nào?

```
Your Computer (Local)
    ↓ (Edit YAML files)
    ↓ (Git push)
    ↓
GitHub Repository
    ↓ (Flux polls every 10s)
    ↓
Minikube (Flux-system)
    ↓ (Apply changes)
    ↓
Your Cluster (Pods updated!)
```

---

## 📝 Thêm ứng dụng mới

1. Tạo folder mới trong `apps/`:
   ```bash
   mkdir apps/my-app
   ```

2. Thêm Kubernetes manifests
3. Update `apps/kustomization.yaml`:
   ```yaml
   resources:
     - nginx-example
     - my-app  # Thêm dòng này
   ```

4. Push lên GitHub
5. Flux tự động deploy!

---

## 🎉 Bạn đã setup xong!

Bây giờ mỗi khi bạn push lên GitHub, Minikube sẽ **tự động cập nhật** trong vòng 10 giây.

Thử ngay:
```bash
# Thay đổi replicas
sed -i 's/replicas: 2/replicas: 3/' apps/nginx-example/deployment.yaml
git add .
git commit -m "Scale nginx"
git push

# Kiểm tra
kubectl get pods
```
