<header class="topbar">
  <div>
    <h1 class="topbar-title">${param.title}</h1>
    <p class="topbar-subtitle">Associate Portal</p>
  </div>
  <% String iname = (String)session.getAttribute("iname"); %>
  <div class="avatar-circle"><%= (iname != null && iname.length() > 0) ? Character.toUpperCase(iname.charAt(0)) : "I" %></div>
</header>