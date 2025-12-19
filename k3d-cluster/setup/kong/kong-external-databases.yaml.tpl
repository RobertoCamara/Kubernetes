apiVersion: v1
kind: Service
metadata:
  name: mongo-external
  namespace: kong
spec:
  ports:
    - port: 27017
---
apiVersion: v1
kind: Endpoints
metadata:
  name: mongo-external
  namespace: kong
subsets:
  - addresses:
      - ip: ${WSL_GATEWAY_IP}
    ports:
      - port: 27017
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-external
  namespace: kong
spec:
  ports:
    - port: 5432
---
apiVersion: v1
kind: Endpoints
metadata:
  name: postgres-external
  namespace: kong
subsets:
  - addresses:
      - ip: ${WSL_GATEWAY_IP}
    ports:
      - port: 5432
