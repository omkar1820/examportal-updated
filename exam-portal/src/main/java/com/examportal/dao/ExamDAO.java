package com.examportal.dao;

import com.examportal.model.Exam;
import com.examportal.util.DBConnection;
import java.sql.*;
import java.util.*;

public class ExamDAO {

    public List<Exam> getAllExams() {
        List<Exam> list = new ArrayList<>();
        String sql = "SELECT * FROM exams WHERE is_active=1";
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) { list.add(mapExam(rs)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Exam getExamById(int id) {
        String sql = "SELECT * FROM exams WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapExam(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean addExam(Exam exam) {
        String sql = "INSERT INTO exams (title, subject, duration_minutes, created_by) VALUES (?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, exam.getTitle());
            ps.setString(2, exam.getSubject());
            ps.setInt(3, exam.getDurationMinutes());
            ps.setInt(4, exam.getCreatedBy());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean deleteExam(int id) {
        String sql = "DELETE FROM exams WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public void updateTotalMarks(int examId) {
        String sql = "UPDATE exams SET total_marks=(SELECT COALESCE(SUM(marks),0) FROM questions WHERE exam_id=?) WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, examId); ps.setInt(2, examId);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    private Exam mapExam(ResultSet rs) throws SQLException {
        Exam e = new Exam();
        e.setId(rs.getInt("id"));
        e.setTitle(rs.getString("title"));
        e.setSubject(rs.getString("subject"));
        e.setDurationMinutes(rs.getInt("duration_minutes"));
        e.setTotalMarks(rs.getInt("total_marks"));
        e.setActive(rs.getInt("is_active") == 1);
        return e;
    }
}
