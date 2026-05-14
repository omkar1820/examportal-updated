<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.examportal.dao.*,com.examportal.model.*,java.util.*" %>
<%
  if(session.getAttribute("userRole") == null || !"admin".equals(session.getAttribute("userRole"))) {
    response.sendRedirect(request.getContextPath() + "/index.jsp"); return;
  }
  int examId = Integer.parseInt(request.getParameter("examId"));
  Exam exam = new ExamDAO().getExamById(examId);
  List<Question> questions = new QuestionDAO().getQuestionsByExam(examId);
%>
<!DOCTYPE html>
<html>
<head>
  <title>Questions - <%= exam.getTitle() %></title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>body{background:#f0f2f5;}.navbar{background:linear-gradient(90deg,#1e3c72,#2a5298)!important;}</style>
</head>
<body>
<nav class="navbar navbar-dark px-4 py-3">
  <span class="navbar-brand fw-bold">📝 ExamPortal Admin</span>
  <div class="d-flex gap-2">
    <a href="${pageContext.request.contextPath}/admin/exams.jsp" class="btn btn-outline-light btn-sm">← Exams</a>
    <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm">Logout</a>
  </div>
</nav>

<div class="container mt-4">
  <% if(request.getParameter("success") != null) { %>
    <div class="alert alert-success"><%= request.getParameter("success") %></div>
  <% } %>

  <h5 class="fw-bold mb-3">📋 Exam: <%= exam.getTitle() %> | Subject: <%= exam.getSubject() %> | Total Marks: <%= exam.getTotalMarks() %></h5>

  <div class="row g-4">
    <div class="col-md-5">
      <div class="card p-4">
        <h5 class="fw-bold mb-3">➕ Add Question</h5>
        <form action="${pageContext.request.contextPath}/admin/exam" method="post">
          <input type="hidden" name="action" value="addQuestion">
          <input type="hidden" name="examId" value="<%= examId %>">
          <div class="mb-2">
            <label class="form-label">Question</label>
            <textarea name="questionText" class="form-control" rows="3" required></textarea>
          </div>
          <div class="mb-2"><label class="form-label">Option A</label><input type="text" name="optionA" class="form-control" required></div>
          <div class="mb-2"><label class="form-label">Option B</label><input type="text" name="optionB" class="form-control" required></div>
          <div class="mb-2"><label class="form-label">Option C</label><input type="text" name="optionC" class="form-control" required></div>
          <div class="mb-2"><label class="form-label">Option D</label><input type="text" name="optionD" class="form-control" required></div>
          <div class="mb-2">
            <label class="form-label">Correct Option</label>
            <select name="correctOption" class="form-select" required>
              <option value="A">A</option><option value="B">B</option>
              <option value="C">C</option><option value="D">D</option>
            </select>
          </div>
          <div class="mb-3"><label class="form-label">Marks</label><input type="number" name="marks" class="form-control" value="1" min="1" required></div>
          <button class="btn btn-primary w-100">Add Question</button>
        </form>
      </div>
    </div>
    <div class="col-md-7">
      <div class="card p-4">
        <h5 class="fw-bold mb-3">❓ Questions (<%= questions.size() %>)</h5>
        <% if(questions.isEmpty()) { %>
          <p class="text-muted">No questions yet. Add some!</p>
        <% } %>
        <% int i=1; for(Question q : questions) { %>
          <div class="border rounded p-3 mb-3">
            <div class="d-flex justify-content-between">
              <strong>Q<%= i++ %>. <%= q.getQuestionText() %></strong>
              <form action="${pageContext.request.contextPath}/admin/exam" method="post" class="d-inline"
                    onsubmit="return confirm('Delete this question?')">
                <input type="hidden" name="action" value="deleteQuestion">
                <input type="hidden" name="id" value="<%= q.getId() %>">
                <input type="hidden" name="examId" value="<%= examId %>">
                <button class="btn btn-sm btn-danger">✕</button>
              </form>
            </div>
            <div class="mt-2 row g-1">
              <div class="col-6"><span class="<%= "A".equals(q.getCorrectOption()) ? "text-success fw-bold" : "" %>">A) <%= q.getOptionA() %></span></div>
              <div class="col-6"><span class="<%= "B".equals(q.getCorrectOption()) ? "text-success fw-bold" : "" %>">B) <%= q.getOptionB() %></span></div>
              <div class="col-6"><span class="<%= "C".equals(q.getCorrectOption()) ? "text-success fw-bold" : "" %>">C) <%= q.getOptionC() %></span></div>
              <div class="col-6"><span class="<%= "D".equals(q.getCorrectOption()) ? "text-success fw-bold" : "" %>">D) <%= q.getOptionD() %></span></div>
            </div>
            <div class="mt-1"><span class="badge bg-success">Correct: <%= q.getCorrectOption() %></span> <span class="badge bg-secondary"><%= q.getMarks() %> mark(s)</span></div>
          </div>
        <% } %>
      </div>
    </div>
  </div>
</div>
</body>
</html>
