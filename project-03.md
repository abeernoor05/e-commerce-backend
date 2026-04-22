\documentclass[11pt,a4paper]{article}
\usepackage[margin=1in]{geometry}
\usepackage{enumitem}
\usepackage{titlesec}
\usepackage{parskip}
\usepackage{hyperref}

% Formatting to closely match the PDF style
\titleformat{\section}{\large\bfseries}{\thesection}{1em}{}
\titleformat{\subsection}{\normalsize\bfseries}{}{0em}{}

\setlist[enumerate]{label=\textbf{\arabic*.}, leftmargin=*, labelsep=1em}
\setlist[itemize]{label=$\bullet$, leftmargin=*, labelsep=0.5em}

\begin{document}

% Title (matches PDF header)
\begin{center}
    {\Large \bfseries Project 3: Automated Multi-Tier Application Deployment}
\end{center}
\vspace{1em}

\section{Overview}
In this project, you will be architecting a complete deployment pipeline. You are tasked with 
taking a microservices-based codebase and deploying it onto an AWS EC2 instance using 
industry-standard tools for Infrastructure as Code (IaC), configuration management, 
containerization, and Continuous Deployment (CD). 

\section{Project Goal}
The objective is to deploy a codebase on an Amazon EC2 instance such that the application is 
fully functional and accessible to external users. 

You can use any of your own projects or publicly available repositories for the codebase. 

\section{Required Artifacts \& Methodology}
Your submission must include the following components, organized by their role in the 
deployment flow: 

\begin{enumerate}
    \item \textbf{Containerization (Docker)}
    \begin{itemize}
        \item \textbf{Dockerfile:} You must write a unique Dockerfile for every microservice in the provided 
        codebase to enable automated image building. 
    \end{itemize}

    \item \textbf{Infrastructure as Code (Terraform)}
    \begin{itemize}
        \item \textbf{AWS Provisioning:} Use Terraform to set up the target EC2 instance within your AWS 
        account. 
        \item \textbf{Networking \& Security:} Include necessary supporting resources, such as a VPC and 
        Security Groups, to ensure secure connectivity. 
    \end{itemize}

    \item \textbf{Configuration as Code (Ansible)}
    \begin{itemize}
        \item \textbf{Node Setup:} Create Ansible playbooks to configure the provisioned EC2 instance. 
        \item \textbf{Cluster Initialization:} The configuration must prepare the machine to run a local 
        Kubernetes cluster (e.g., microk8s or kind). 
    \end{itemize}

    \item \textbf{Cluster (Kubernetes Manifests)}
    \begin{itemize}
        \item \textbf{Resource Definitions:} For every microservice, write Kubernetes Service and 
        Deployment manifests. 
        \item \textbf{Integration:} Ensure your deployment manifests are configured to utilize the Docker 
        images created in Step 1. 
    \end{itemize}

    \item \textbf{CI/CD Pipeline (GitHub Actions \& ArgoCD)}
    \begin{itemize}
        \item \textbf{CI Workflow:} Implement a GitHub Workflow that triggers on codebase changes to 
        rebuild Docker images and update the Kubernetes manifests with the new image tags. 
        \item \textbf{CD Synchronization:} Configure ArgoCD to monitor your repository and automatically 
        sync the Kubernetes cluster with the updated manifests. 
    \end{itemize}
\end{enumerate}

\section{Deliverables}
\begin{enumerate}
    \item \textbf{Source Code:} A repository containing all application code, Dockerfiles, and Kubernetes 
    YAML files. 
    \item \textbf{Infrastructure Code:} Your .tf (Terraform) and .yml (Ansible) files. 
    \item \textbf{CI/CD Config:} The GitHub Actions workflow file (.github/workflows/) and ArgoCD 
    application configuration. 
    \item \textbf{Documentation:} A brief README explaining all the deployment steps. 
\end{enumerate}

\end{document}