<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.examportal.dao.*,com.examportal.model.*,java.util.*" %>
<%
  if(session.getAttribute("userRole") == null || !"admin".equals(session.getAttribute("userRole"))) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
  }
  List<Exam> exams = new ExamDAO().getAllExams();
  List<User> students = new UserDAO().getAllStudents();
  List<Result> results = new ResultDAO().getAllResults();
%>
<!DOCTYPE html>
<html>
<head>
  <title>Admin Dashboard - ExamPortal</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>
    body { background: #f0f2f5; }
    .navbar { background: linear-gradient(90deg,#1e3c72,#2a5298) !important; }
    .stat-card { border-radius: 12px; border: none; transition: transform .2s; }
    .stat-card:hover { transform: translateY(-4px); }
  </style>
</head>
<body>
<nav class="navbar navbar-dark px-4 py-3">
  <span class="navbar-brand fw-bold">📝 ExamPortal Admin</span>
  <div class="d-flex align-items-center gap-3">
    <span class="text-white">👤 <%= session.getAttribute("userName") %></span>
    <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm">Logout</a>
  </div>
</nav>

<div class="container mt-4">
  <h4 class="fw-bold mb-4">Dashboard Overview</h4>
  <div class="row g-3 mb-4">
    <div class="col-md-4">
      <div class="card stat-card text-white bg-primary p-3">
        <div class="d-flex justify-content-between align-items-center">
          <div><div class="fs-1 fw-bold"><%= exams.size() %></div><div>Total Exams</div></div>
          <div style="font-size:2.5rem;">📋</div>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card stat-card text-white bg-success p-3">
        <div class="d-flex justify-content-between align-items-center">
          <div><div class="fs-1 fw-bold"><%= students.size() %></div><div>Students</div></div>
          <div style="font-size:2.5rem;">🎓</div>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card stat-card text-white bg-warning p-3">
        <div class="d-flex justify-content-between align-items-center">
          <div><div class="fs-1 fw-bold"><%= results.size() %></div><div>Attempts</div></div>
          <div style="font-size:2.5rem;">📊</div>
        </div>
      </div>
    </div>
  </div>

  <div class="row g-3">
    <div class="col-md-6">
      <div class="card p-3">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h5 class="mb-0 fw-bold">Exams</h5>
          <a href="${pageContext.request.contextPath}/admin/exams.jsp" class="btn btn-primary btn-sm">Manage Exams</a>
        </div>
        <table class="table table-sm table-hover">
          <thead class="table-light"><tr><th>Title</th><th>Subject</th><th>Marks</th><th>Action</th></tr></thead>
          <tbody>
          <% for(Exam e : exams) { %>
            <tr>
              <td><%= e.getTitle() %></td>
              <td><%= e.getSubject() %></td>
              <td><%= e.getTotalMarks() %></td>
              <td><a href="${pageContext.request.contextPath}/admin/questions.jsp?examId=<%= e.getId() %>" class="btn btn-outline-secondary btn-sm">Questions</a></td>
            </tr>
          <% } %>
          </tbody>
        </table>
      </div>
    </div>
    <div class="col-md-6">
      <div class="card p-3">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h5 class="mb-0 fw-bold">Recent Results</h5>
          <a href="${pageContext.request.contextPath}/admin/results.jsp" class="btn btn-warning btn-sm">All Results</a>
        </div>
        <table class="table table-sm table-hover">
          <thead class="table-light"><tr><th>Student</th><th>Exam</th><th>Score</th><th>%</th></tr></thead>
          <tbody>
          <% for(Result r : results.subList(0, Math.min(5, results.size()))) { %>
            <tr>
              <td><%= r.getStudentName() %></td>
              <td><%= r.getExamTitle() %></td>
              <td><%= r.getScore() %>/<%= r.getTotalMarks() %></td>
              <td><span class="badge <%= r.getPercentage() >= 60 ? "bg-success" : "bg-danger" %>"><%= r.getPercentage() %>%</span></td>
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
