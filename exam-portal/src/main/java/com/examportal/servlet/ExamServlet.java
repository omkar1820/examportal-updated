package com.examportal.servlet;

import com.examportal.dao.ExamDAO;
import com.examportal.dao.QuestionDAO;
import com.examportal.model.Exam;
import com.examportal.model.Question;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/exam")
public class ExamServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        ExamDAO examDAO = new ExamDAO();

        if ("addExam".equals(action)) {
            Exam exam = new Exam();
            exam.setTitle(req.getParameter("title"));
            exam.setSubject(req.getParameter("subject"));
            exam.setDurationMinutes(Integer.parseInt(req.getParameter("duration")));
            HttpSession session = req.getSession();
            exam.setCreatedBy((Integer) session.getAttribute("userId"));
            examDAO.addExam(exam);
            res.sendRedirect(req.getContextPath() + "/admin/exams.jsp?success=Exam+added");

        } else if ("addQuestion".equals(action)) {
            Question q = new Question();
            q.setExamId(Integer.parseInt(req.getParameter("examId")));
            q.setQuestionText(req.getParameter("questionText"));
            q.setOptionA(req.getParameter("optionA"));
            q.setOptionB(req.getParameter("optionB"));
            q.setOptionC(req.getParameter("optionC"));
            q.setOptionD(req.getParameter("optionD"));
            q.setCorrectOption(req.getParameter("correctOption"));
            q.setMarks(Integer.parseInt(req.getParameter("marks")));
            new QuestionDAO().addQuestion(q);
            examDAO.updateTotalMarks(q.getExamId());
            res.sendRedirect(req.getContextPath() + "/admin/questions.jsp?examId=" + q.getExamId() + "&success=Question+added");

        } else if ("deleteExam".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            examDAO.deleteExam(id);
            res.sendRedirect(req.getContextPath() + "/admin/exams.jsp");

        } else if ("deleteQuestion".equals(action)) {
            int qid = Integer.parseInt(req.getParameter("id"));
            int eid = Integer.parseInt(req.getParameter("examId"));
            new QuestionDAO().deleteQuestion(qid);
            examDAO.updateTotalMarks(eid);
            res.sendRedirect(req.getContextPath() + "/admin/questions.jsp?examId=" + eid);
        }
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.sendRedirect(req.getContextPath() + "/admin/exams.jsp");
    }
}
