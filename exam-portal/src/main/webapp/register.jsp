<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Register - ExamPortal</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>
    body { background: linear-gradient(135deg, #1e3c72, #2a5298); min-height: 100vh; display: flex; align-items: center; }
    .card { border-radius: 16px; box-shadow: 0 10px 40px rgba(0,0,0,0.3); }
  </style>
</head>
<body>
<div class="container">
  <div class="row justify-content-center">
    <div class="col-md-4">
      <div class="card p-4">
        <div class="text-center mb-4">
          <div style="font-size:2.5rem;">🎓</div>
          <h4 class="fw-bold text-primary">Student Registration</h4>
        </div>

        <% if(request.getAttribute("error") != null) { %>
          <div class="alert alert-danger py-2">${error}</div>
        <% } %>

        <form action="${pageContext.request.contextPath}/register" method="post">
          <div class="mb-3">
            <label class="form-label fw-semibold">Full Name</label>
            <input type="text" name="name" class="form-control" placeholder="Enter full name" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Email</label>
            <input type="email" name="email" class="form-control" placeholder="Enter email" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Password</label>
            <input type="password" name="password" class="form-control" placeholder="Create password" required>
          </div>
          <button type="submit" class="btn btn-success w-100">Register</button>
        </form>
        <hr>
        <p class="text-center mb-0 small">Already have an account? <a href="${pageContext.request.contextPath}/index.jsp">Login</a></p>
      </div>
    </div>
  </div>
</div>
</body>
</html>
