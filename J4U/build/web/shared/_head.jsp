<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String contextPath = request.getContextPath();
%>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>${param.title} | Justice4U Premium</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Third Party Plugins -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" crossorigin="anonymous" />
    
    <!-- AdminLTE & Custom Tokens -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminlte.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/shared/justice4u-tokens.css" />
    
    <style>
        .app-wrapper { min-height: 100vh; background: var(--bg); }
        .app-main { padding-top: 1rem; }
        .breadcrumb-item a { color: var(--gold); text-decoration: none; font-size: 0.85rem; font-weight: 500; }
        .breadcrumb-item.active { font-size: 0.85rem; color: var(--text-faint); }
        
        /* Minimal Scrollbar */
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.1); border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(0,0,0,0.2); }
    </style>
</head>
