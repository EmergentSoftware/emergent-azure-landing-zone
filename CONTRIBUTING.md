# Contributing to Emergent Software Azure Landing Zone

Thank you for your interest in contributing to our Azure Landing Zone reference implementation!

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in [Issues](../../issues)
2. If not, create a new issue with:
   - Clear description of the problem or suggestion
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Terraform and Azure provider versions
   - Any relevant logs or error messages

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style and patterns
   - Use the wrapper module pattern for any new AVM modules
   - Update documentation as needed
   - Test your changes thoroughly

4. **Commit your changes**
   ```bash
   git commit -m "feat: add description of your changes"
   ```
   Use conventional commit messages:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `refactor:` for code refactoring
   - `test:` for test changes

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Provide a clear description of the changes
   - Reference any related issues
   - Ensure all checks pass

## Guidelines

### Module Development

- **Always use wrapper modules** for AVM resources in the `modules/` directory
- Pin AVM module versions using `~>` constraints
- Document all variables and outputs
- Include usage examples in module README files

### Code Style

- Use consistent naming conventions:
  - Resources: `kebab-case`
  - Variables: `snake_case`
  - Modules: `kebab-case`
- Include comments for complex logic
- Use meaningful variable and resource names

### Documentation

- Update README files when adding features
- Include examples in documentation
- Keep deployment guides up to date
- Document any breaking changes

### Testing

Before submitting:
- Run `terraform fmt -recursive` to format code
- Run `terraform validate` in all directories
- Test the complete deployment workflow
- Verify documentation accuracy

## Questions?

If you have questions about contributing, please open an issue with the `question` label.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
