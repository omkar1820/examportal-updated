<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.examportal.model.*,java.util.*" %>
<%
  if(session.getAttribute("userRole") == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp"); return;
  }
  Exam exam = (Exam) request.getAttribute("exam");
  List<Question> questions = (List<Question>) request.getAttribute("questions");
%>
<!DOCTYPE html>
<html>
<head>
  <title><%= exam.getTitle() %> - ExamPortal</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>
    body{background:#f0f2f5;}
    .navbar{background:linear-gradient(90deg,#1e3c72,#2a5298)!important;}
    .question-card{border-radius:10px;border-left:4px solid #2a5298;}
    #timer{font-size:1.3rem;font-weight:bold;color:#dc3545;}
  </style>
</head>
<body>
<nav class="navbar navbar-dark px-4 py-3">
  <span class="navbar-brand fw-bold">📝 <%= exam.getTitle() %></span>
  <div class="text-white">⏱ Time Left: <span id="timer"></span></div>
</nav>

<div class="container mt-4">
  <div class="alert alert-info">
    Subject: <strong><%= exam.getSubject() %></strong> &nbsp;|&nbsp;
    Questions: <strong><%= questions.size() %></strong> &nbsp;|&nbsp;
    Total Marks: <strong><%= exam.getTotalMarks() %></strong> &nbsp;|&nbsp;
    Duration: <strong><%= exam.getDurationMinutes() %> minutes</strong>
  </div>

  <form action="${pageContext.request.contextPath}/student/takeExam" method="post" id="examForm">
    <input type="hidden" name="examId" value="<%= exam.getId() %>">

    <% int i=1; for(Question q : questions) { %>
      <div class="card question-card p-4 mb-3">
        <h6 class="fw-bold">Q<%= i++ %>. <%= q.getQuestionText() %> <span class="badge bg-secondary ms-2"><%= q.getMarks() %> mark(s)</span></h6>
        <div class="row mt-3 g-2">
          <div class="col-md-6">
            <label class="d-flex align-items-center gap-2 p-2 border rounded hover-option" style="cursor:pointer;">
              <input type="radio" name="q_<%= q.getId() %>" value="A" required>
              <span><strong>A)</strong> <%= q.getOptionA() %></span>
            </label>
          </div>
          <div class="col-md-6">
            <label class="d-flex align-items-center gap-2 p-2 border rounded" style="cursor:pointer;">
              <input type="radio" name="q_<%= q.getId() %>" value="B">
              <span><strong>B)</strong> <%= q.getOptionB() %></span>
            </label>
          </div>
          <div class="col-md-6">
            <label class="d-flex align-items-center gap-2 p-2 border rounded" style="cursor:pointer;">
              <input type="radio" name="q_<%= q.getId() %>" value="C">
              <span><strong>C)</strong> <%= q.getOptionC() %></span>
            </label>
          </div>
          <div class="col-md-6">
            <label class="d-flex align-items-center gap-2 p-2 border rounded" style="cursor:pointer;">
              <input type="radio" name="q_<%= q.getId() %>" value="D">
              <span><strong>D)</strong> <%= q.getOptionD() %></span>
            </label>
          </div>
        </div>
      </div>
    <% } %>

    <div class="text-center mb-5">
      <button type="submit" class="btn btn-success btn-lg px-5"
        onclick="return confirm('Submit exam? You cannot change answers after submitting.')">
        Submit Exam ✓
      </button>
    </div>
  </form>
</div>

<script>
  let seconds = <%= exam.getDurationMinutes() %> * 60;
  const timerEl = document.getElementById('timer');
  const interval = setInterval(() => {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    timerEl.textContent = m + ':' + (s < 10 ? '0' : '') + s;
    if (seconds <= 60) timerEl.style.color = '#dc3545';
    if (seconds <= 0) { clearInterval(interval); document.getElementById('examForm').submit(); }
    seconds--;
  }, 1000);
</script>
</body>
</html>
