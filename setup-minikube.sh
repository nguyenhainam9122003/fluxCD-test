#!/bin/bash
set -e

echo "=== FluxCD Minikube Setup ==="
echo ""

# Step 1: Start Minikube
echo "1. Khởi động Minikube..."
minikube start --cpus 4 --memory 4096

echo "2. Cài đặt Flux CLI..."
curl -s https://fluxcd.io/install.sh | sudo bash

echo "3. Kiểm tra điều kiện tiên quyết..."
flux check --pre

echo "4. Cài Flux trên Minikube..."
flux install --components=source-controller,kustomize-controller,helm-controller

echo "5. Tạo GitRepository..."
flux create source git fluxcd-test \
  --url=https://github.com/nguyenhainam9122003/fluxCD-test.git \
  --branch=main \
  --interval=10s \
  --namespace=flux-system

echo "6. Tạo Kustomization..."
flux create kustomization apps \
  --source=fluxcd-test \
  --path=./apps \
  --prune=true \
  --wait=true \
  --interval=10s \
  --namespace=flux-system

echo ""
echo "=== Setup hoàn tất! ==="
echo ""
echo "Kiểm tra status:"
echo "  flux get all -A"
echo ""
echo "Xem logs:"
echo "  flux logs -f"
echo ""
echo "Khi bạn push lên GitHub, Minikube sẽ tự động cập nhật trong 10 giây!"
