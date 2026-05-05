# FluxCD Auto-Deploy Project

Dự án này sử dụng **FluxCD** để tự động deploy ứng dụng từ Git repository.

## Cấu trúc dự án

```
.
├── clusters/              # Cấu hình cho các cluster khác nhau
│   └── dev/
│       └── flux-system/  # Flux system configuration
├── apps/                  # Các ứng dụng để deploy
│   ├── nginx-example/
│   └── kustomization.yaml
├── infrastructure/        # Cấu hình hạ tầng (Helm repos, etc.)
└── README.md
```

## Yêu cầu

- Kubernetes cluster (1.19+)
- `kubectl` đã cấu hình
- `flux` CLI (tuỳ chọn, nhưng hữu ích)

## Cài đặt Flux trên cluster

```bash
# 1. Kiểm tra xem Flux đã cài chưa
flux check --pre

# 2. Cài đặt Flux
flux install --components=source-controller,kustomize-controller,helm-controller

# 3. Tạo GitRepository source
flux create source git fluxcd-test \
  --url=https://github.com/nguyenhainam9122003/fluxCD-test.git \
  --branch=main \
  --interval=30s

# 4. Tạo Kustomization để deploy
flux create kustomization apps \
  --source=fluxcd-test \
  --path=./apps \
  --prune=true \
  --interval=30s
```

## Cách hoạt động

1. **GitRepository**: Flux theo dõi thay đổi từ Git repo
2. **Kustomization**: Định nghĩa cách apply các manifests Kubernetes
3. **Auto-reconciliation**: Mỗi 30 giây (hoặc khi có push), Flux tự động update cluster

## Thêm ứng dụng mới

1. Tạo folder trong `apps/` với Kubernetes manifests
2. Cập nhật `apps/kustomization.yaml` để include folder mới
3. Commit và push lên GitHub
4. Flux sẽ tự động deploy!

## Xem status

```bash
# Kiểm tra Flux system
flux get all --all-namespaces

# Xem logs
flux logs -f
```

## Tài liệu

- [FluxCD Docs](https://fluxcd.io/)
- [GitOps Workflow](https://fluxcd.io/docs/get-started/)
