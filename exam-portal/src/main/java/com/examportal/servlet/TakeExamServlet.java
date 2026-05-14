package com.examportal.servlet;

import com.examportal.dao.*;
import com.examportal.model.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/student/takeExam")
public class TakeExamServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int examId = Integer.parseInt(req.getParameter("examId"));
        int studentId = (Integer) req.getSession().getAttribute("userId");

        if (new ResultDAO().hasAttempted(studentId, examId)) {
            res.sendRedirect(req.getContextPath() + "/student/results.jsp?error=Already+attempted");
            return;
        }

        Exam exam = new ExamDAO().getExamById(examId);
        List<Question> questions = new QuestionDAO().getQuestionsByExam(examId);

        req.setAttribute("exam", exam);
        req.setAttribute("questions", questions);
        req.getRequestDispatcher("/student/takeExam.jsp").forward(req, res);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int examId = Integer.parseInt(req.getParameter("examId"));
        int studentId = (Integer) req.getSession().getAttribute("userId");

        Exam exam = new ExamDAO().getExamById(examId);
        List<Question> questions = new QuestionDAO().getQuestionsByExam(examId);

        int score = 0;
        ResultDAO resultDAO = new ResultDAO();

        // Calculate score
        for (Question q : questions) {
            String selected = req.getParameter("q_" + q.getId());
            if (selected != null && selected.equalsIgnoreCase(q.getCorrectOption())) {
                score += q.getMarks();
            }
        }

        double percentage = exam.getTotalMarks() > 0
            ? ((double) score / exam.getTotalMarks()) * 100 : 0;

        Result result = new Result();
        result.setStudentId(studentId);
        result.setExamId(examId);
        result.setScore(score);
        result.setTotalMarks(exam.getTotalMarks());
        result.setPercentage(Math.round(percentage * 100.0) / 100.0);

        int resultId = resultDAO.saveResult(result);

        // Save individual answers
        for (Question q : questions) {
            String selected = req.getParameter("q_" + q.getId());
            boolean correct = selected != null && selected.equalsIgnoreCase(q.getCorrectOption());
            resultDAO.saveAnswer(resultId, q.getId(), selected != null ? selected : "-", correct);
        }

        res.sendRedirect(req.getContextPath() + "/student/results.jsp?score=" + score
            + "&total=" + exam.getTotalMarks() + "&pct=" + result.getPercentage());
    }
}
