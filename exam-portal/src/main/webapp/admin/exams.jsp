<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.examportal.dao.*,com.examportal.model.*,java.util.*" %>
<%
  if(session.getAttribute("userRole") == null || !"admin".equals(session.getAttribute("userRole"))) {
    response.sendRedirect(request.getContextPath() + "/index.jsp"); return;
  }
  List<Exam> exams = new ExamDAO().getAllExams();
%>
<!DOCTYPE html>
<html>
<head>
  <title>Manage Exams</title>
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
  <% if(request.getParameter("success") != null) { %>
    <div class="alert alert-success"><%= request.getParameter("success") %></div>
  <% } %>

  <div class="row g-4">
    <div class="col-md-5">
      <div class="card p-4">
        <h5 class="fw-bold mb-3">➕ Add New Exam</h5>
        <form action="${pageContext.request.contextPath}/admin/exam" method="post">
          <input type="hidden" name="action" value="addExam">
          <div class="mb-3">
            <label class="form-label">Exam Title</label>
            <input type="text" name="title" class="form-control" required placeholder="e.g. Java Basics">
          </div>
          <div class="mb-3">
            <label class="form-label">Subject</label>
            <input type="text" name="subject" class="form-control" required placeholder="e.g. Java Programming">
          </div>
          <div class="mb-3">
            <label class="form-label">Duration (minutes)</label>
            <input type="number" name="duration" class="form-control" value="30" min="5" required>
          </div>
          <button class="btn btn-primary w-100">Add Exam</button>
        </form>
      </div>
    </div>
    <div class="col-md-7">
      <div class="card p-4">
        <h5 class="fw-bold mb-3">📋 All Exams</h5>
        <table class="table table-hover">
          <thead class="table-dark"><tr><th>#</th><th>Title</th><th>Subject</th><th>Duration</th><th>Marks</th><th>Actions</th></tr></thead>
          <tbody>
          <% for(Exam e : exams) { %>
            <tr>
              <td><%= e.getId() %></td>
              <td><strong><%= e.getTitle() %></strong></td>
              <td><%= e.getSubject() %></td>
              <td><%= e.getDurationMinutes() %> min</td>
              <td><span class="badge bg-primary"><%= e.getTotalMarks() %></span></td>
              <td>
                <a href="${pageContext.request.contextPath}/admin/questions.jsp?examId=<%= e.getId() %>" class="btn btn-sm btn-outline-primary">Questions</a>
                <form action="${pageContext.request.contextPath}/admin/exam" method="post" class="d-inline"
                      onsubmit="return confirm('Delete this exam?')">
                  <input type="hidden" name="action" value="deleteExam">
                  <input type="hidden" name="id" value="<%= e.getId() %>">
                  <button class="btn btn-sm btn-outline-danger">Delete</button>
                </form>
              </td>
            </tr>
          <% } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>
</body>
</html>
