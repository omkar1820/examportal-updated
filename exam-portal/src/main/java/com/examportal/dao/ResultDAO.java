package com.examportal.dao;

import com.examportal.model.Result;
import com.examportal.util.DBConnection;
import java.sql.*;
import java.util.*;

public class ResultDAO {

    public int saveResult(Result result) {
        String sql = "INSERT INTO results (student_id, exam_id, score, total_marks, percentage) VALUES (?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, result.getStudentId());
            ps.setInt(2, result.getExamId());
            ps.setInt(3, result.getScore());
            ps.setInt(4, result.getTotalMarks());
            ps.setDouble(5, result.getPercentage());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    public void saveAnswer(int resultId, int questionId, String selected, boolean isCorrect) {
        String sql = "INSERT INTO answers (result_id, question_id, selected_option, is_correct) VALUES (?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, resultId);
            ps.setInt(2, questionId);
            ps.setString(3, selected);
            ps.setInt(4, isCorrect ? 1 : 0);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public List<Result> getResultsByStudent(int studentId) {
        List<Result> list = new ArrayList<>();
        String sql = "SELECT r.*, e.title AS exam_title FROM results r JOIN exams e ON r.exam_id=e.id WHERE r.student_id=? ORDER BY r.submitted_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Result res = new Result();
                res.setId(rs.getInt("id"));
                res.setScore(rs.getInt("score"));
                res.setTotalMarks(rs.getInt("total_marks"));
                res.setPercentage(rs.getDouble("percentage"));
                res.setExamTitle(rs.getString("exam_title"));
                res.setSubmittedAt(rs.getString("submitted_at"));
                list.add(res);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Result> getAllResults() {
        List<Result> list = new ArrayList<>();
        String sql = "SELECT r.*, u.name AS student_name, e.title AS exam_title FROM results r JOIN users u ON r.student_id=u.id JOIN exams e ON r.exam_id=e.id ORDER BY r.submitted_at DESC";
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Result res = new Result();
                res.setId(rs.getInt("id"));
                res.setScore(rs.getInt("score"));
                res.setTotalMarks(rs.getInt("total_marks"));
                res.setPercentage(rs.getDouble("percentage"));
                res.setStudentName(rs.getString("student_name"));
                res.setExamTitle(rs.getString("exam_title"));
                res.setSubmittedAt(rs.getString("submitted_at"));
                list.add(res);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean hasAttempted(int studentId, int examId) {
        String sql = "SELECT id FROM results WHERE student_id=? AND exam_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId); ps.setInt(2, examId);
            return ps.executeQuery().next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}
