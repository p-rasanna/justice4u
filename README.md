# Justice4U - Legal Platform (JSP/Servlet)

## Setup
1. XAMPP: Start Apache + MySQL
2. DB: Import `sql/j4u_database.sql` & updates
3. Web: http://localhost/J4U/
4. Build: `ant clean build` (if NetBeans/Ant)

## Flow
index.jsp → landing/Home.html → role_select.html → auth/ → LoginServlet → dashboard

## Roles
- Admin: localhost/J4U/web/auth/Login.jsp?role=admin
- Client/Lawyer/Intern: role_select.html

© 2026 Cleaned by BLACKBOXAI

