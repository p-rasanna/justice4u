<header class="topbar">
  <div>
    <h1 class="topbar-title">${param.title}</h1>
    <p class="topbar-subtitle">Client Portal</p>
  </div>
  <% String cname = (String)session.getAttribute("cname"); %>
  <div class="avatar-circle"><%= (cname != null && cname.length() > 0) ? Character.toUpperCase(cname.charAt(0)) : "C" %></div>
</header>