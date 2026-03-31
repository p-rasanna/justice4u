<header class="topbar">
    <div>
        <h1 class="topbar-title">${param.title}</h1>
        <p class="topbar-subtitle">Attorney Portal</p>
    </div>
    <% String lname = (String)session.getAttribute("lname"); %>
    <div class="avatar-circle"><%= (lname != null && lname.length() > 0) ? Character.toUpperCase(lname.charAt(0)) : "A" %></div>
</header>