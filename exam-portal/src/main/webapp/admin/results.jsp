<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.examportal.dao.*,com.examportal.model.*,java.util.*" %>
<%
  if(session.getAttribute("userRole") == null || !"admin".equals(session.getAttribute("userRole"))) {
    response.sendRedirect(request.getContextPath() + "/index.jsp"); return;
  }
  List<Result> results = new ResultDAO().getAllResults();
%>
<!DOCTYPE html>
<html>
<head>
  <title>All Results - ExamPortal</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>body{background:#f0f2f5;}.navbar{background:linear-gradient(90deg,#1e3c72,#2a5298)!important;}</style>
</head>
<body>
<nav class="navbar navbar-dark px-4 py-3">
  <span class="navbar-brand fw-bold">📝 ExamPortal Admin</span>
  <div class="d-flex gap-2">
    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-outline-light btn-sm">Dashboard</a>
    <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm">Logout</a>
  </div>
</nav>
<div class="container mt-4">
  <h5 class="fw-bold mb-3">📊 All Exam Results</h5>
  <div class="card p-3">
    <table class="table table-hover">
      <thead class="table-dark">
        <tr><th>#</th><th>Student</th><th>Exam</th><th>Score</th><th>Percentage</th><th>Result</th><th>Date</th></tr>
      </thead>
      <tbody>
      <% int i=1; for(Result r : results) { %>
        <tr>
          <td><%= i++ %></td>
          <td><%= r.getStudentName() %></td>
          <td><%= r.getExamTitle() %></td>
          <td><strong><%= r.getScore() %> / <%= r.getTotalMarks() %></strong></td>
          <td><%= r.getPercentage() %>%</td>
          <td>
            <% if(r.getPercentage() >= 60) { %><span class="badge bg-success">PASS</span>
            <% } else { %><span class="badge bg-danger">FAIL</span><% } %>
          </td>
          <td><small><%= r.getSubmittedAt() %></small></td>
        </tr>
      <% } %>
      </tbody>
    </table>
  </div>
</div>
</body>
</html>
