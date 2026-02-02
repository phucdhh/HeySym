# Configuration file for nbgrader - HeySym Project

c = get_config()  #noqa

# ============================================================================
# 1. EXCHANGE DIRECTORY - NƠI NỘP BÀI
# ============================================================================

# Thư mục exchange (student nộp bài tập vào đây)
c.Exchange.root = '/Users/mac/HeySym/exchange'

# Course ID (có thể thay đổi cho từng khóa học)
c.CourseDirectory.course_id = 'sympy_2025'

# ============================================================================
# 2. TIMEZONE
# ============================================================================

# Múi giờ Việt Nam
c.Execute.timeout = 180  # 3 phút timeout cho mỗi cell
c.ClearSolutions.code_stub = {
    'python': '# YOUR CODE HERE\nraise NotImplementedError()',
}

# ============================================================================
# 3. GRADING CONFIGURATION
# ============================================================================

# Tự động chấm điểm
c.Execute.allow_errors = False

# Tạo feedback cho sinh viên
c.GenerateFeedback.force = True

# ============================================================================
# 4. DATABASE
# ============================================================================

# Sử dụng SQLite database
c.NbGrader.db_url = 'sqlite:////Users/mac/HeySym/config/gradebook.db'

# ============================================================================
# GHI CHÚ - NOTES
# ============================================================================
#
# NBGRADER WORKFLOW:
# 1. Instructor tạo bài tập: nbgrader generate_assignment <assignment_name>
# 2. Instructor release bài: nbgrader release_assignment <assignment_name>
# 3. Student fetch bài: nbgrader fetch_assignment <assignment_name>
# 4. Student làm bài và submit: nbgrader submit <assignment_name>
# 5. Instructor collect bài: nbgrader collect <assignment_name>
# 6. Instructor chấm tự động: nbgrader autograde <assignment_name>
# 7. Instructor chấm thủ công (nếu cần): nbgrader formgrade
# 8. Instructor tạo feedback: nbgrader generate_feedback <assignment_name>
# 9. Instructor release feedback: nbgrader release_feedback <assignment_name>
# 10. Student fetch feedback: nbgrader fetch_feedback <assignment_name>
#
# PERMISSIONS:
# - Exchange directory phải có quyền 777 (đã set trong jupyterhub_config.py)
# - Mỗi student chỉ thấy bài tập của mình
#
# ============================================================================
