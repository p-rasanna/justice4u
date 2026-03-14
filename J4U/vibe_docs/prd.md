# Justice4U: Product Requirements Document (PRD)

## High-Level Goals

Justice4U is a comprehensive digital platform designed to bridge the gap between people seeking legal assistance (Clients) and legal professionals (Lawyers & Interns). The goal is to provide a secure, organized, and reliable ecosystem where clients can post cases, lawyers can review and accept them, and an administrative layer ensures compliance, verified credentials, and smooth operations.

## Target Users

1. **Clients**: Individuals or organizations seeking legal representation or advice. They need an easy way to register, post their case details securely, and find verified lawyers matching their needs.
2. **Lawyers**: Legal professionals looking to acquire new clients. They require a rigorous onboarding process (document verification) to establish trust, and need intuitive dashboards to view and accept cases.
3. **Interns**: Law students or junior practitioners seeking experience. They can apply for internships directly through the platform, awaiting approval.
4. **Administrators**: The governing body of the platform. They are responsible for reviewing and approving lawyer registrations (checking bar certificates, ID proofs), approving new clients, allocating cases, and overseeing total platform activity.

## Core Features

### 1. Robust Role-Based Authentication (RBAC)

- Distinct registration and login flows for Clients, Lawyers, Interns, and Admins.
- Session-based security ensuring users can only access endpoints authorized for their specific role.
- Password hashing and secure verification.

### 2. Administrator Command Center

- A unified dashboard providing key metrics (Total Clients, Pending Verifications, Pending Matches).
- **Lawyer Verification Queue**: A dedicated workspace to review uploaded documents (Bar Council Certificates, ID proofs, live selfies) and manually approve or reject lawyer applications.
- **Client Management**: Monitoring and verifying client registrations.
- **Case Allocation**: Overseeing pending cases and matching them appropriately.

### 3. Lawyer Operations

- Upload secure verification documents during onboarding.
- Dashboard to view available/pending cases and manage accepted clients.

### 4. Client Operations

- Securely post case descriptions and requirements.
- Dashboard to track the status of posted cases and view assigned legal representation.

### 5. Notification & Feedback System

- Alert triggers and visual queues summarizing pending tasks for users and administrators.

## Non-Functional Requirements

- **Security**: The system must adhere to strict data security standards, securely processing document uploads (`FileUploadUtil`) and utilizing sanitized data inputs to prevent injection.
- **Design Aesthetics**: The platform utilizes a "10/10 INTELLIGENCE THEME" – professional, modern, and trust-inspiring, featuring fonts like Inter, Space Grotesk, and Playfair Display, with distinct status pill coloring.
- **Simplicity**: Maintain a straightforward JSP/Servlet architecture without over-engineering complex ORMs, optimizing the ecosystem for a "diploma-level" or accessible continuous delivery model.
