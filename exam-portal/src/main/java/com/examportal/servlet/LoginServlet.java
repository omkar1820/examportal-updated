package com.examportal.servlet;

import com.examportal.dao.UserDAO;
import com.examportal.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        User user = new UserDAO().login(email, password);
        if (user != null) {
            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("userRole", user.getRole());

            if ("admin".equals(user.getRole())) {
                res.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");
            } else {
                res.sendRedirect(req.getContextPath() + "/student/dashboard.jsp");
            }
        } else {
            req.setAttribute("error", "Invalid email or password!");
            req.getRequestDispatcher("/index.jsp").forward(req, res);
        }
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.sendRedirect(req.getContextPath() + "/index.jsp");
    }
}
