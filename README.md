# Secure CI/CD Lab -- DevSecOps Pipeline with Docker and GitHub Actions

This project demonstrates a secure CI/CD pipeline for a Python Flask
application using GitHub Actions. The pipeline integrates automated
testing, static code analysis, dependency vulnerability scanning,
container image security scanning, Docker image publishing, and artifact
generation.

The goal of the project is to simulate a realistic DevSecOps workflow
where security checks are integrated throughout the development
lifecycle to prevent insecure code or vulnerable dependencies from
reaching deployment.

------------------------------------------------------------------------

# Project Overview

The repository contains a small Flask application along with a
multi-stage CI/CD pipeline that performs the following:

1.  Runs automated tests
2.  Performs code quality checks
3.  Conducts static application security testing (SAST)
4.  Scans dependencies for known vulnerabilities
5.  Builds a Docker container image
6.  Publishes the image to GitHub Container Registry
7.  Scans the container image for OS and library vulnerabilities
8.  Generates a deployment artifact

The pipeline is executed automatically whenever code is pushed to the
`main` branch or when pull requests are opened.

------------------------------------------------------------------------

# CI/CD Pipeline Architecture

Push Code\
↓\
Tests\
↓\
Security Checks\
↓\
Docker Build & Publish\
↓\
Container Vulnerability Scan\
↓\
Deployment Artifact Generation

Each stage runs in a separate GitHub Actions runner, ensuring isolated
environments and reproducible builds.

------------------------------------------------------------------------

# Pipeline Stages

## 1. Automated Testing

Unit tests are executed using pytest to verify application behavior.

    python -m pytest -v

If tests fail, the pipeline stops and the change cannot proceed further.

------------------------------------------------------------------------

## 2. Code Quality Checks

Code style and formatting are validated using flake8.

    python -m flake8 .

This ensures code consistency and helps catch potential issues early.

------------------------------------------------------------------------

## 3. Static Application Security Testing

Bandit is used to scan the Python source code for common security issues
such as:

-   unsafe subprocess usage
-   insecure configurations
-   hardcoded secrets
-   risky network bindings

```{=html}
<!-- -->
```
    python -m bandit -r app

------------------------------------------------------------------------

## 4. Dependency Vulnerability Scanning

pip-audit scans Python dependencies against known vulnerability
databases.

    python -m pip_audit

This prevents vulnerable packages from being introduced into the
application.

------------------------------------------------------------------------

## 5. Docker Image Build and Publication

The pipeline builds a container image using the project's Dockerfile.

    docker build -t ghcr.io/<username>/secure-cicd-lab .

The image is then pushed to GitHub Container Registry (GHCR).

    ghcr.io/<username>/secure-cicd-lab:latest

Publishing the image allows downstream deployment systems to consume the
container artifact.

------------------------------------------------------------------------

## 6. Container Image Security Scanning

After the image is published, Trivy scans the container for
vulnerabilities within:

-   operating system packages
-   system libraries
-   container layers

Example finding discovered during development:

    glibc: Integer overflow in memalign leads to heap corruption
    CVE-2026-0861

The pipeline was configured to fail if HIGH or CRITICAL vulnerabilities
were detected.

------------------------------------------------------------------------

## 7. Deployment Artifact Generation

Once all checks pass, a deployment artifact is created containing only
the files required to run the application:

    deploy/
     ├── app/
     ├── requirements.txt
     └── Dockerfile

The artifact is uploaded using the GitHub Actions artifact storage
feature.

------------------------------------------------------------------------

# Container Security Fix Implemented

Trivy initially detected a vulnerability in the Debian base image used
by the Python container.

The issue was resolved by adding system package updates to the Docker
build process.

    RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

This ensures the container receives the latest available security
patches during the build stage.

------------------------------------------------------------------------

# Interesting Challenges and Solutions

## Understanding CI/CD Trigger Behavior

A key learning point was understanding that tools such as pytest,
bandit, and pip-audit do not run automatically on their own. Instead,
the GitHub Actions workflow triggers them whenever a push or pull
request occurs.

The pipeline acts as the orchestrator that runs these checks
sequentially.

------------------------------------------------------------------------

## Handling Security Scanner Findings

Multiple scanners identified issues during development:

  - Bandit:     Hardcoded network binding
  - pip-audit:   Vulnerable dependency versions
  - Trivy:       Vulnerable base OS packages

Each finding required a different remediation strategy.

------------------------------------------------------------------------

## Secure Flask Network Binding

Bandit flagged the application binding to all interfaces (0.0.0.0). To
address this while maintaining container compatibility, the application
host configuration was made environment-driven.

    host = os.getenv("FLASK_HOST", "127.0.0.1")

Docker then overrides the environment variable during runtime.

------------------------------------------------------------------------

## Container Vulnerability Remediation

The base Python image included vulnerable system libraries. Updating OS
packages during the Docker build resolved these findings.

------------------------------------------------------------------------

# Technologies Used


 - Python                      Application language
 - Flask                       Lightweight web framework
 - GitHub Actions              CI/CD pipeline automation
 - pytest                      Unit testing
 - flake8                      Code linting
 - Bandit                      Static security analysis
 - pip-audit                   Dependency vulnerability scanning
 - Docker                      Containerized application packaging
 - Trivy                       Container image vulnerability scanning
 - GitHub Container Registry   Container image storage

------------------------------------------------------------------------

# Running the Application Locally

Build the container:

    docker build -t secure-cicd-lab .

Run the container:

    docker run -p 5000:5000 secure-cicd-lab

Access the application:

http://localhost:5000

Health endpoint:

http://localhost:5000/health

------------------------------------------------------------------------

# Learning Objectives

This project demonstrates how to:

-   build a multi-stage CI/CD pipeline
-   integrate security checks into development workflows
-   enforce quality gates before deployment
-   build and publish container images
-   perform container vulnerability scanning
-   remediate findings discovered by automated security tools

------------------------------------------------------------------------

