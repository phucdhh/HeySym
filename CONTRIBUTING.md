# Contributing to HeySym

Thank you for your interest in contributing to HeySym! 🎓

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/HeySym.git
   cd HeySym
   ```
3. **Create a branch** for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

Follow the setup instructions in [PLAN.md](PLAN.md) Phase 1 to set up your development environment.

## How to Contribute

### Reporting Bugs

- Check if the bug has already been reported in [Issues](https://github.com/phucdhh/HeySym/issues)
- Use the bug report template
- Include:
  - Clear description of the issue
  - Steps to reproduce
  - Expected vs actual behavior
  - System information (OS, Python version, etc.)
  - Relevant logs from `logs/jupyterhub.log`

### Suggesting Features

- Open an issue with the "feature request" label
- Describe:
  - The problem you're trying to solve
  - Your proposed solution
  - Alternative solutions you've considered
  - How it benefits users

### Pull Requests

1. **Make your changes** in your feature branch
2. **Test thoroughly**:
   - Test locally with JupyterHub
   - Test with at least 2-3 concurrent users
   - Check logs for errors
3. **Follow code style**:
   - Python: Follow PEP 8
   - Use meaningful variable/function names
   - Add comments for complex logic
4. **Update documentation**:
   - Update README.md if needed
   - Update PLAN.md if changing deployment process
   - Add docstrings to new functions
5. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add awesome feature"
   ```
   Use conventional commits:
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `refactor:` - Code refactoring
   - `test:` - Adding tests
   - `chore:` - Maintenance tasks

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request** on GitHub

## Code Guidelines

### Python Code Style

- Follow PEP 8
- Use 4 spaces for indentation (no tabs)
- Maximum line length: 88 characters (Black formatter)
- Use type hints where appropriate

### Configuration Files

- Keep configs simple and well-commented
- Use environment variables for sensitive data
- Document all configuration options

### Documentation

- Write clear, concise documentation
- Use Markdown for all docs
- Include code examples where helpful
- Keep PLAN.md updated with deployment changes

## Testing

Before submitting a PR:

- [ ] Test JupyterHub startup
- [ ] Test user signup and approval
- [ ] Test notebook spawning
- [ ] Test AI integration (at least one model)
- [ ] Test nbgrader workflow (create → release → submit → grade)
- [ ] Check for errors in logs
- [ ] Test with 2+ concurrent users

## Community Guidelines

- Be respectful and constructive
- Help newcomers
- Stay on topic
- Follow the [Code of Conduct](CODE_OF_CONDUCT.md) _(coming soon)_

## Questions?

- Open an [Issue](https://github.com/phucdhh/HeySym/issues) for questions
- Use [Discussions](https://github.com/phucdhh/HeySym/discussions) for general chat
- Email: nguyendangminhphuc@dhsphue.edu.vn

## License

By contributing, you agree that your contributions will be licensed under the MIT License (see [LICENSE](LICENSE)).

---

Thank you for making HeySym better! 🚀
