# Justice4U: Technology Stack

This document specifies the languages, frameworks, and infrastructure utilized in the Justice4U project.

## Core Architecture

- **Paradigm**: Monolithic Java EE Web Application (Client-Server Model)
- **Deployment**: Apache Tomcat

## Backend (Server-Side)

- **Language**: Java
- **Framework Specification**: Java Servlets & JavaServer Pages (JSP)
- **Database Connectivity**: JDBC (Java Database Connectivity)
- **Security**: `J4USecurityFilter` handling session validation; `PasswordUtil` handling password verification (supporting legacy plain-text comparisons where necessary for diploma-level simplicity).
- **Utility Libraries**: `com.google.gson.Gson` (JSON processing), standard `javax.servlet` libraries.

## Frontend (Client-Side)

- **Language**: HTML5, CSS3, JavaScript (Vanilla JS & minimal jQuery where legacy)
- **CSS Framework**: Bootstrap 5.3.0 (Used via CDN for responsive gridding and structural utilities).
- **Design System ("10/10 INTELLIGENCE THEME")**:
  - Entirely custom CSS overriding default frameworks to achieve a bespoke, highly professional aesthetic.
  - **Typography**:
    - `Inter` (UI standard text)
    - `Playfair Display` (Headers/Branding)
    - `Space Grotesk` (Metrics, technical data)
  - **Iconography**: Phosphor Icons (via unpkg CDN)
- **Templating**: Direct JSP Scriplets (`<% ... %>`) merging Java with HTML.

## Database Layer

- **System**: MySQL (Relational Database Management System)
- **Connector**: MySQL Connector/J (`mysql-connector-java-*.jar`)
- **Key Tables**: `cust_reg`, `lawyer_reg`, `intern`, `customer_cases`, `lawyer_documents`

## Build & Tooling

- **Build System**: Apache Ant (via standard NetBeans `build.xml` processes)
- **Environment**: JDK 8+ environment mapped loosely to XAMPP for database hosting.
