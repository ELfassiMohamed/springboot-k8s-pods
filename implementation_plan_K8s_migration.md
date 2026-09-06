# Local Kubernetes Migration Roadmap for Spring Boot

This document outlines a comprehensive, step-by-step plan for migrating your Spring Boot microservices (`Patient-Service`, `Provider-Service`, `Medicalrecord-Service`, and `Request-Service`) into a local Kubernetes environment. It covers what to study, how to set up your environment, and how to handle infrastructure like MongoDB and RabbitMQ.

## 📚 What to Study First (Kubernetes Core Concepts)

Before writing any configuration, familiarize yourself with these fundamental Kubernetes (K8s) objects. You don't need to be an expert, but you need to know what they do:

1. **Pod**: The smallest deployable unit in K8s. A pod wraps your Docker container. Your Spring Boot app runs *inside* a Pod.
2. **Deployment**: Manages the creation and scaling of Pods. If a Pod crashes, the Deployment spins up a new one. This is what you will use to deploy your microservices.
3. **Service**: The networking layer. Since Pods die and get new IP addresses constantly, a `Service` provides a stable internal IP address and DNS name for your Pods. **This replaces Eureka**. For example, `Patient-Service` will talk to `Provider-Service` simply by calling `http://provider-service:8080`.
4. **ConfigMap & Secret**: Used to inject configuration data and passwords into your Pods as environment variables. **This replaces your Spring Cloud Config Server.**
5. **StatefulSet & PersistentVolume (PV/PVC)**: Used for databases like MongoDB. While `Deployments` are stateless, `StatefulSets` ensure data isn't lost when a database pod restarts.

> [!TIP]
> **Recommended Resources**:
> - Official Kubernetes Documentation (Interactive Tutorials).
> - "Kubernetes in 5 Mins" videos on YouTube (e.g., TechWorld with Nana).

---

## 🚀 Step 1: Set Up Your Local K8s Environment

You need a way to run Kubernetes on your PC.

1. **Install a Local Cluster**:
   - **Docker Desktop**: (Recommended for Windows). Go to Docker Desktop Settings -> Kubernetes -> "Enable Kubernetes". It takes a few minutes, but gives you a fully working local cluster.
   - **Alternative (Minikube)**: If Docker Desktop is too heavy, install Minikube (`choco install minikube` on Windows).
2. **Install `kubectl`**: The command-line tool used to talk to your K8s cluster. (If you enable K8s via Docker Desktop, this is usually installed automatically).
3. **Install Lens or K9s (Optional but Highly Recommended)**: Lens is a graphical UI desktop app for Kubernetes. It makes seeing your Pods, logs, and errors 100x easier than typing commands in the terminal.

---

## 🧹 Step 2: Decouple Legacy Infrastructure (Code Cleanup)

As discussed previously, K8s makes older Spring Cloud tools obsolete. You need to strip them out.

1. **Delete `Config-server`**: You can safely delete or archive this directory.
2. **Remove Eureka/Config Dependencies**: In all your microservices (`Patient-Service`, `Provider-Service`, etc.), remove `spring-cloud-starter-netflix-eureka-client` and `spring-cloud-starter-config` from `pom.xml`.
3. **Update `application.properties`**: Remove Eureka registration URLs. Ensure each service runs independently via `mvn spring-boot:run` without crashing due to missing infrastructure.

---

## 🐳 Step 3: Containerization (Docker)

Kubernetes only runs containers. You must package your Java apps into Docker images.

1. Create a `Dockerfile` in the root of every microservice (if you haven't already).
   ```dockerfile
   FROM eclipse-temurin:17-jdk-alpine
   VOLUME /tmp
   COPY target/*.jar app.jar
   ENTRYPOINT ["java","-jar","/app.jar"]
   ```
2. Build the images locally:
   ```bash
   mvn clean package -DskipTests
   docker build -t patient-service:1.0 .
   ```

---

## 🗄️ Step 4: Deploying Stateful Infrastructure (MongoDB & RabbitMQ)

Before your microservices can start, they need databases and message brokers. In K8s, we deploy these using YAML files.

### Deploying MongoDB
You will create a file named `mongo.yaml`. For local development, a simple Deployment is usually fine, but using a PersistentVolumeClaim (PVC) ensures your data survives if the Mongo Pod crashes.
- **Components Needed**: A `PersistentVolumeClaim` (for storage), a `Deployment` (running the `mongo:latest` image), and a `Service` (to expose port 27017).

### Deploying RabbitMQ
You will create a file named `rabbitmq.yaml`.
- **Components Needed**: A `Deployment` running the `rabbitmq:3-management` image (which includes the UI dashboard), and a `Service` exposing port 5672 (for code) and 15672 (for the web UI dashboard).

> [!IMPORTANT]  
> Once deployed, your Spring Boot apps will connect to these using K8s DNS. For example, your Spring Mongo URI will become `mongodb://mongo-service:27017/db_name` instead of `localhost`.

---

## 📦 Step 5: Create Kubernetes Manifests for Microservices

For every microservice, you will create a `<service-name>.yaml` file. This file will tell K8s how to run your app.

1. **ConfigMap/Secret**: Define your environment variables (DB URLs, JWT secrets).
2. **Deployment**: Tell K8s to run 1 or 2 replicas of your `patient-service:1.0` Docker image. Link the environment variables from the ConfigMap.
3. **Service**: Create a `ClusterIP` Service exposing port 8080. This gives the microservice an internal network name.

---

## 🌐 Step 6: Exposing the Application

At this point, everything is running *inside* the K8s cluster, but you cannot access it from your Windows browser.

- **NodePort or Port-Forward**: The simplest way to test locally is using `kubectl port-forward service/patient-service 8080:8080`.
- **Ingress Controller (Advanced)**: To simulate production (like an API Gateway), you deploy an NGINX Ingress Controller. It acts as the single entry point, routing `http://localhost/api/patients` to the `Patient-Service` pod, and `http://localhost/api/providers` to the `Provider-Service` pod.

---

## Next Actions

If you approve of this roadmap, we can begin executing **Step 2 (Code Cleanup)** and **Step 3 (Containerization)** right away. I can help you create the Dockerfiles and strip out the legacy Spring Cloud dependencies. 

Should we proceed with cleaning up the `pom.xml` files for the microservices?
