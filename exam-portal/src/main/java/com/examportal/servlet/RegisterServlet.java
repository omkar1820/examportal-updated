package com.examportal.servlet;

import com.examportal.dao.UserDAO;
import com.examportal.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(password);

        boolean success = new UserDAO().register(user);
        if (success) {
            res.sendRedirect(req.getContextPath() + "/index.jsp?registered=true");
        } else {
            req.setAttribute("error", "Registration failed. Email may already exist.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
        }
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.sendRedirect(req.getContextPath() + "/register.jsp");
    }
}
