# Contributing to Claude Skills Collection

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 🎯 Ways to Contribute

### 1. Adding New Skills

- Create a new `.skill` file following our standard format
- Include comprehensive documentation
- Add examples and use cases
- Test thoroughly before submitting

### 2. Improving Documentation

- Fix typos and grammatical errors
- Clarify existing documentation
- Add missing examples
- Translate content (we support EN and RU)

### 3. Reporting Bugs

- Use the GitHub issue tracker
- Provide detailed reproduction steps
- Include your environment details
- Attach relevant logs or screenshots

### 4. Suggesting Enhancements

- Open an issue with the "enhancement" label
- Clearly describe the proposed feature
- Explain the use case and benefits
- Consider implementation details

## 📝 Skill Creation Guidelines

### File Format

Skills should be packaged as ZIP archives with `.skill` extension:

```
my-skill.skill (ZIP archive)
├── SKILL.md              # Main documentation
├── examples/             # Usage examples
├── assets/               # Resources
└── references/           # Additional docs
```

### Documentation Requirements

Each skill must include:

1. **Name and Description**
   - Clear, descriptive name
   - One-sentence summary
   - Detailed description

2. **Usage Instructions**
   - Prerequisites
   - Step-by-step guide
   - Configuration options

3. **Examples**
   - At least 3 real-world examples
   - Input and expected output
   - Edge cases

4. **Metadata**
   - Category and level
   - Tags
   - Version
   - Author

### Quality Standards

- **Documentation:** Must be comprehensive and clear
- **Examples:** Include at least 3 working examples
- **Testing:** Verify all examples work
- **Formatting:** Follow markdown best practices
- **Size:** Keep skills focused and modular

## 🔄 Pull Request Process

1. **Fork the Repository**
   ```bash
   git fork https://github.com/yourusername/info4
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/my-new-skill
   ```

3. **Make Your Changes**
   - Follow coding/documentation standards
   - Add/update tests if applicable
   - Update relevant documentation

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Add: My New Skill for file processing"
   ```

   Commit message format:
   - `Add:` - New features/skills
   - `Fix:` - Bug fixes
   - `Docs:` - Documentation changes
   - `Refactor:` - Code restructuring
   - `Test:` - Test additions/changes

5. **Push to Your Fork**
   ```bash
   git push origin feature/my-new-skill
   ```

6. **Submit a Pull Request**
   - Provide a clear description
   - Reference related issues
   - List changes made
   - Add screenshots if relevant

### PR Review Process

- Maintainers will review your PR within 7 days
- Address any requested changes
- Once approved, your PR will be merged
- You'll be added to contributors list!

## 📋 Style Guide

### Markdown

- Use ATX-style headers (`#` not underlines)
- Include blank lines around headers
- Use code blocks with language specifications
- Limit line length to 120 characters
- Use relative links for internal references

### Code Examples

```markdown
### Example: File Organization

Input:
```bash
organize-files --source ./downloads --pattern "*.pdf"
```

Output:
```
Organized 45 files:
  Documents/PDFs/: 32 files
  Archives/: 13 files
```
```

### Python Code

Follow PEP 8:
- 4 spaces for indentation
- Maximum line length: 79 characters
- Use descriptive variable names
- Include docstrings for functions
- Add type hints where appropriate

## 🏷️ Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature request
- `documentation` - Documentation improvements
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `question` - Further information requested
- `wontfix` - Will not be worked on
- `duplicate` - Duplicate issue

## 🌍 Internationalization

We support multiple languages:

- **English (EN):** Primary language
- **Russian (RU):** Full support

When adding content:
1. Create English version first
2. Add Russian translation if possible
3. Mark untranslated content with `[EN]` tag
4. Submit translations as separate PRs

## 📞 Getting Help

Need help contributing?

- Join our [Discussions](https://github.com/yourusername/info4/discussions)
- Check the [Wiki](https://github.com/yourusername/info4/wiki)
- Ask in issue comments
- Contact maintainers

## ✅ Checklist

Before submitting, ensure:

- [ ] Code/docs follow style guide
- [ ] All examples tested and working
- [ ] Documentation is complete
- [ ] Commit messages are descriptive
- [ ] PR description is clear
- [ ] No merge conflicts
- [ ] Tests pass (if applicable)
- [ ] Updated CHANGELOG.md

## 📜 Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone.

### Our Standards

- Use welcoming and inclusive language
- Respect differing viewpoints
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

### Enforcement

Report unacceptable behavior to maintainers. All complaints will be reviewed and investigated.

## 🙏 Thank You

Your contributions make this project better for everyone. We appreciate your time and effort!

---

**Questions?** Open an issue or discussion thread.
**Ideas?** We'd love to hear them!
**Found a bug?** Help us fix it!

Happy contributing! 🎉
