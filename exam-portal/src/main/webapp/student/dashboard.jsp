<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.examportal.dao.*,com.examportal.model.*,java.util.*" %>
<%
  if(session.getAttribute("userRole") == null || !"student".equals(session.getAttribute("userRole"))) {
    response.sendRedirect(request.getContextPath() + "/index.jsp"); return;
  }
  int studentId = (Integer) session.getAttribute("userId");
  List<Exam> exams = new ExamDAO().getAllExams();
  List<Result> myResults = new ResultDAO().getResultsByStudent(studentId);
  ResultDAO rdao = new ResultDAO();
%>
<!DOCTYPE html>
<html>
<head>
  <title>Student Dashboard - ExamPortal</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>
    body{background:#f0f2f5;}
    .navbar{background:linear-gradient(90deg,#1e3c72,#2a5298)!important;}
    .exam-card{border-radius:12px;transition:transform .2s;border:none;}
    .exam-card:hover{transform:translateY(-4px);box-shadow:0 8px 24px rgba(0,0,0,.15);}
  </style>
</head>
<body>
<nav class="navbar navbar-dark px-4 py-3">
  <span class="navbar-brand fw-bold">📝 ExamPortal</span>
  <div class="d-flex align-items-center gap-3">
    <span class="text-white">👤 <%= session.getAttribute("userName") %></span>
    <a href="${pageContext.request.contextPath}/student/results.jsp" class="btn btn-outline-light btn-sm">My Results</a>
    <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm">Logout</a>
  </div>
</nav>

<div class="container mt-4">
  <h4 class="fw-bold mb-1">Welcome, <%= session.getAttribute("userName") %>! 👋</h4>
  <p class="text-muted mb-4">Choose an exam to start</p>

  <div class="row g-3 mb-4">
    <div class="col-md-3">
      <div class="card text-center p-3" style="background:linear-gradient(135deg,#667eea,#764ba2);color:white;border-radius:12px;">
        <div class="fs-2 fw-bold"><%= exams.size() %></div>
        <div>Available Exams</div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card text-center p-3" style="background:linear-gradient(135deg,#11998e,#38ef7d);color:white;border-radius:12px;">
        <div class="fs-2 fw-bold"><%= myResults.size() %></div>
        <div>Exams Taken</div>
      </div>
    </div>
  </div>

  <h5 class="fw-bold mb-3">📋 Available Exams</h5>
  <div class="row g-3">
  <% for(Exam e : exams) {
       boolean attempted = rdao.hasAttempted(studentId, e.getId()); %>
    <div class="col-md-4">
      <div class="card exam-card p-3">
        <div class="d-flex justify-content-between align-items-start mb-2">
          <span class="badge bg-primary"><%= e.getSubject() %></span>
          <% if(attempted) { %><span class="badge bg-secondary">Completed</span><% } else { %><span class="badge bg-success">Available</span><% } %>
        </div>
        <h6 class="fw-bold"><%= e.getTitle() %></h6>
        <div class="text-muted small mb-3">
          ⏱ <%= e.getDurationMinutes() %> minutes &nbsp;|&nbsp; 📊 <%= e.getTotalMarks() %> marks
        </div>
        <% if(attempted) { %>
          <button class="btn btn-secondary btn-sm w-100" disabled>Already Attempted</button>
        <% } else { %>
          <a href="${pageContext.request.contextPath}/student/takeExam?examId=<%= e.getId() %>" class="btn btn-primary btn-sm w-100">Start Exam →</a>
        <% } %>
      </div>
    </div>
  <% } %>
  </div>
</div>
</body>
</html>
