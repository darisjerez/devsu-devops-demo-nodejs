# Demo Devops NodeJs

This is a simple application to be used in the technical test of DevOps.

## Getting Started

### Prerequisites

- Node.js 18.15.0

### Installation

Clone this repo.

```bash
git clone https://bitbucket.org/devsu/demo-devops-nodejs.git
```

Install dependencies.

```bash
npm i
```

### Database

The database is generated as a file in the main path when the project is first run, and its name is `dev.sqlite`.

Consider giving access permissions to the file for proper functioning.

## Usage

To run tests you can use this command.

```bash
npm run test
```

To run locally the project you can use this command.

```bash
npm run start
```

Open http://localhost:8000/api/users with your browser to see the result.

### Features

These services can perform,

#### Create User

To create a user, the endpoint **/api/users** must be consumed with the following parameters:

```bash
  Method: POST
```

```json
{
    "dni": "dni",
    "name": "name"
}
```

If the response is successful, the service will return an HTTP Status 200 and a message with the following structure:

```json
{
    "id": 1,
    "dni": "dni",
    "name": "name"
}
```

If the response is unsuccessful, we will receive status 400 and the following message:

```json
{
    "error": "error"
}
```

#### Get Users

To get all users, the endpoint **/api/users** must be consumed with the following parameters:

```bash
  Method: GET
```

If the response is successful, the service will return an HTTP Status 200 and a message with the following structure:

```json
[
    {
        "id": 1,
        "dni": "dni",
        "name": "name"
    }
]
```

#### Get User

To get an user, the endpoint **/api/users/<id>** must be consumed with the following parameters:

```bash
  Method: GET
```

If the response is successful, the service will return an HTTP Status 200 and a message with the following structure:

```json
{
    "id": 1,
    "dni": "dni",
    "name": "name"
}
```

If the user id does not exist, we will receive status 404 and the following message:

```json
{
    "error": "User not found: <id>"
}
```

If the response is unsuccessful, we will receive status 400 and the following message:

```json
{
    "errors": [
        "error"
    ]
}
```

## License

Copyright © 2023 Devsu. All rights reserved.

--------------------------------------------------------------------------------------------------------------------------------------------------

## Resumen de arquitectura

Este proyecto despliega una aplicación en nodejs hacia EKS (Kubernetes) usando Azure DevOps y ECR con infrastructura como codigo con terraform.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                    AWS                                      │
│                                                                             │
│  ┌────────────────────────────────VPC────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   ┌──────────────────┐          ┌──────────────────────────────────┐  │  │
│  │   │   Public Subnet  │          │         Private Subnets          │  │  │
│  │   │                  │          │                                  │  │  │
│  │   │  ┌────────────┐  │          │  ┌────────────────────────────┐  │  │  │
│  │   │  │ EC2 Agent  │  │          │  │           EKS              │  │  │  │
│  │   │  │            │  │          │  │                            │  │  │  │
│  │   │  │ - Docker   │  │   ───>   │  │  ┌─────┐  ┌─────┐          │  │  │  │
│  │   │  │ - Node.js  │  │          │  │  │ Pod │  │ Pod │          │  │  │  │
│  │   │  │ - kubectl  │  │          │  │  └─────┘  └─────┘          │  │  │  │
│  │   │  │ - Azure    │  │          │  │                            │  │  │  │
│  │   │  │   Agent    │  │          │  │  LoadBalancer Service      │  │  │  │
│  │   │  └────────────┘  │          │  └────────────────────────────┘  │  │  │
│  │   │                  │          │                                  │  │  │
│  │   └──────────────────┘          └──────────────────────────────────┘  │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌─────────────┐                                                            │
│  │     ECR     │  <──  Push imagen de docker al registry                    │
│  └─────────────┘                                                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

        ^
        │
        │  Pipeline triggers
        │
┌───────┴───────┐
│  Azure DevOps │
│    Pipeline   │
└───────────────┘
```

## Flujo del pipeline

```
┌─────────────┐     ┌─────────────────┐     ┌─────────────────┐
│     CI      │     │      Build      │     │     Deploy      │
│             │ ──> │                 │ ──> │                 │
│ - npm ci    │     │ - ECR Login     │     │ - kubectl       │
│ - npm test  │     │ - Docker build  │     │   configure     │
│ - coverage  │     │ - Docker push   │     │ - Apply k8s     │
│             │     │                 │     │   manifests     │
└─────────────┘     └─────────────────┘     └─────────────────┘
```

## Componentes

### Recursos de Terraform (carpeta: aws/)

| Archivo | Recurso |
|------|-----------|
| main.tf | AWS provider |
| variables.tf | Input variables |
| vpc.tf | VPC, subnets, NAT gateway |
| ecr.tf | Container registry |
| eks.tf | Kubernetes cluster |
| agent.tf | EC2 build agent + IAM role |
| outputs.tf | Output values |

### Kubernetes Manifests (carpeta: k8s/)

| Archivo | Proposito |
|------|---------|
| namespace.yaml | devsu namespace |
| configmap.yaml | Variables de ambiente |
| secret.yaml | Contraseña de la Database  |
| deployment.yaml | App deployment (2 replicas) |
| service.yaml | LoadBalancer service |


## Flujo de alto nivel

### Decisiones de arquitectura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Toma de Decisiones                                │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  ¿Dónde correr   │     │  ¿Dónde guardar  │     │  ¿Cómo orquestar │
│  el pipeline?    │     │  las imágenes?   │     │  contenedores?   │
└────────┬─────────┘     └────────┬─────────┘     └────────┬─────────┘
         │                        │                        │
         v                        v                        v
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   EC2 + Azure    │     │       ECR        │     │       EKS        │
│   DevOps Agent   │     │                  │     │                  │
└──────────────────┘     └──────────────────┘     └──────────────────┘
         │                        │                        │
         v                        v                        v
   Self-hosted para         Integración nativa       Kubernetes managed
   control total            con IAM y EKS            sin overhead operacional
```

### ¿Por que estas decisiones?

| Decisión | Alternativas | Razón de elección |
|----------|--------------|-------------------|
| EC2 como agente | Azure hosted agents | Control sobre dependencias, acceso directo a VPC, sin límites de minutos |
| ECR como registry | DockerHub, Nexus | Integración nativa con EKS via IAM, sin gestión de credenciales |
| EKS como orquestador | EC2 + Docker, ECS | Portabilidad de manifiestos YAML, escalabilidad, estandar de industria |
| Terraform como IaC | CloudFormation, Pulumi | Multi-cloud, estado declarativo, módulos reutilizables |
| LoadBalancer service | NodePort, Ingress | Simplicidad para exponer la app públicamente |

### Flujo de trabajo del desarrollador

```
     Desarrollador                    Pipeline                         AWS
         │                            │                              │
         │  1. git push main          │                              │
         │ ──────────────────────────>│                              │
         │                            │                              │
         │                            │  2. CI: npm test             │
         │                            │ ────────────────────┐        │
         │                            │ <───────────────────┘        │
         │                            │                              │
         │                            │  3. Build: docker build      │
         │                            │ ────────────────────┐        │
         │                            │ <───────────────────┘        │
         │                            │                              │
         │                            │  4. Push to ECR              │
         │                            │ ────────────────────────────>│
         │                            │                              │
         │                            │  5. kubectl apply            │
         │                            │ ────────────────────────────>│
         │                            │                              │
         │  6. App disponible         │                              │
         │ <─────────────────────────────────────────────────────────│
         │                            │                              │
```

### Seguridad implementada

| Capa | Implementación |
|------|----------------|
| Red | VPC con subnets publicas/privadas, NAT Gateway |
| IAM | Roles con permisos minimos para ECR y EKS |
| Kubernetes | Namespace aislado, Secrets para credenciales |
| Container | Imagen basada en alpine, usuario no-root |
| Pipeline | Credenciales via IAM Role, no hardcodeadas |

### Entregables
1. Repo publico: https://github.com/darisjerez/devsu-devops-demo-nodejs
2. Azure DevOps (Acceso publico): https://dev.azure.com/darisjerez/DevOps/_build
3. Archivos Terraform: aws/
4. Kubernetes manifiestos: k8s/
5. App URL: http://a2f1ee720b49a40a0a2a66f25a86de1a-1141336828.us-east-1.elb.amazonaws.com


