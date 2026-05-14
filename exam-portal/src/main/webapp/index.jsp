<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Online Exam Portal - Login</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>
    body { background: linear-gradient(135deg, #1e3c72, #2a5298); min-height: 100vh; display: flex; align-items: center; }
    .card { border-radius: 16px; box-shadow: 0 10px 40px rgba(0,0,0,0.3); }
    .brand { color: #2a5298; font-weight: 700; font-size: 1.5rem; }
  </style>
</head>
<body>
<div class="container">
  <div class="row justify-content-center">
    <div class="col-md-4">
      <div class="card p-4">
        <div class="text-center mb-4">
          <div style="font-size:3rem;">📝</div>
          <div class="brand">ExamPortal</div>
          <p class="text-muted small">Online Examination System</p>
        </div>

        <% if(request.getParameter("registered") != null) { %>
          <div class="alert alert-success py-2">Registration successful! Please login.</div>
        <% } %>
        <% if(request.getAttribute("error") != null) { %>
          <div class="alert alert-danger py-2">${error}</div>
        <% } %>

        <form action="${pageContext.request.contextPath}/login" method="post">
          <div class="mb-3">
            <label class="form-label fw-semibold">Email</label>
            <input type="email" name="email" class="form-control" placeholder="Enter email" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Password</label>
            <input type="password" name="password" class="form-control" placeholder="Enter password" required>
          </div>
          <button type="submit" class="btn btn-primary w-100">Login</button>
        </form>
        <hr>
        <p class="text-center mb-0 small">New student? <a href="${pageContext.request.contextPath}/register.jsp">Register here</a></p>
        <hr>
        <p class="text-center text-muted small mb-0">
          Admin: admin@exam.com / admin123<br>
          Student: john@exam.com / student123
        </p>
      </div>
    </div>
  </div>
</div>
</body>
</html>
