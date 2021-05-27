apiVersion: apps/v1
kind: Deployment
metadata:
  name: grpc-server
spec:
  replicas: 4
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: grpc-server
  template:
    metadata:
      labels:
        app: grpc-server
    spec:
      containers:
        - name: grpc-server
          image: gcr.io/PROJECT_ID/app:COMMIT_SHA
          command: ["/grpc-server"]
          imagePullPolicy: Always
          resources:
            limits:
              cpu: 500m
              memory: 1000Mi
            requests:
              cpu: 200m
              memory: 500Mi
          ports:
            - containerPort: 8080
          envFrom:
            - secretRef:
                name: secret
          readinessProbe:
            exec:
              command: ["/bin/grpc_health_probe", "-addr=:8080"]
            initialDelaySeconds: 1
          livenessProbe:
            exec:
              command: ["/bin/grpc_health_probe", "-addr=:8080"]
            initialDelaySeconds: 1
        - name: envoy-proxy
          image: envoyproxy/envoy-alpine:v1.18.3
          command: ["/bin/sh", "-c", "/usr/local/bin/envoy -c /etc/envoy/envoy.yaml"]
          resources:
            limits:
              cpu: 500m
              memory: 500Mi
            requests:
              cpu: 100m
              memory: 100Mi
          ports:
            - name: app
              containerPort: 10000
            - name: envoy-admin
              containerPort: 8001
          volumeMounts:
            - name: envoy-volume
              mountPath: /etc/envoy
          readinessProbe:
            httpGet:
              scheme: HTTP
              path: /healthz
              httpHeaders:
                - name: x-envoy-livenessprobe
                  value: healthz
              port: 10000
            initialDelaySeconds: 3
          livenessProbe:
            httpGet:
              scheme: HTTP
              path: /healthz
              httpHeaders:
                - name: x-envoy-livenessprobe
                  value: healthz
              port: 10000
            initialDelaySeconds: 10
        - name: cloud-sql-proxy
          image: gcr.io/cloudsql-docker/gce-proxy:1.19.1
          command:
            - "/cloud_sql_proxy"
            - "-instances=kubernetes-sample1:us-central1:kubernetes-sample1=tcp:3306"
            - "-credential_file=/secrets/service-account.json"
          securityContext:
            runAsNonRoot: true
          volumeMounts:
          - name: secret
            mountPath: /secrets/
            readOnly: true
      volumes:
        - name: envoy-volume
          configMap:
            name: envoy-gitops-sample-server-config
