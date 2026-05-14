<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.examportal.dao.*,com.examportal.model.*,java.util.*" %>
<%
  if(session.getAttribute("userRole") == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp"); return;
  }
  int studentId = (Integer) session.getAttribute("userId");
  List<Result> results = new ResultDAO().getResultsByStudent(studentId);

  String scoreParam = request.getParameter("score");
  String totalParam = request.getParameter("total");
  String pctParam   = request.getParameter("pct");
%>
<!DOCTYPE html>
<html>
<head>
  <title>My Results - ExamPortal</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>body{background:#f0f2f5;}.navbar{background:linear-gradient(90deg,#1e3c72,#2a5298)!important;}</style>
</head>
<body>
<nav class="navbar navbar-dark px-4 py-3">
  <span class="navbar-brand fw-bold">📝 ExamPortal</span>
  <div class="d-flex gap-2">
    <a href="${pageContext.request.contextPath}/student/dashboard.jsp" class="btn btn-outline-light btn-sm">← Dashboard</a>
    <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm">Logout</a>
  </div>
</nav>
<div class="container mt-4">

  <% if(scoreParam != null) {
       double pct = Double.parseDouble(pctParam);
       boolean pass = pct >= 60; %>
    <div class="card text-center p-5 mb-4" style="background:linear-gradient(135deg,<%= pass ? "#11998e,#38ef7d" : "#eb3349,#f45c43" %>);color:white;border-radius:16px;">
      <div style="font-size:4rem;"><%= pass ? "🏆" : "😞" %></div>
      <h2><%= pass ? "Congratulations! You Passed!" : "Better Luck Next Time" %></h2>
      <h3>Score: <%= scoreParam %> / <%= totalParam %></h3>
      <h4><%= pctParam %>%</h4>
      <p><%= pass ? "Great performance! Keep it up." : "You need 60% to pass. Study more and try again." %></p>
    </div>
  <% } %>

  <% if(request.getParameter("error") != null) { %>
    <div class="alert alert-warning"><%= request.getParameter("error") %></div>
  <% } %>

  <h5 class="fw-bold mb-3">📊 My Exam History</h5>
  <div class="card p-3">
    <% if(results.isEmpty()) { %>
      <p class="text-muted text-center py-4">You haven't taken any exams yet. <a href="${pageContext.request.contextPath}/student/dashboard.jsp">Take one now!</a></p>
    <% } else { %>
    <table class="table table-hover">
      <thead class="table-dark"><tr><th>#</th><th>Exam</th><th>Score</th><th>Percentage</th><th>Result</th><th>Date</th></tr></thead>
      <tbody>
      <% int i=1; for(Result r : results) { %>
        <tr>
          <td><%= i++ %></td>
          <td><strong><%= r.getExamTitle() %></strong></td>
          <td><%= r.getScore() %> / <%= r.getTotalMarks() %></td>
          <td><%= r.getPercentage() %>%</td>
          <td>
            <% if(r.getPercentage() >= 60) { %><span class="badge bg-success fs-6">PASS</span>
            <% } else { %><span class="badge bg-danger fs-6">FAIL</span><% } %>
          </td>
          <td><small class="text-muted"><%= r.getSubmittedAt() %></small></td>
        </tr>
      <% } %>
      </tbody>
    </table>
    <% } %>
  </div>
</div>
</body>
</html>
