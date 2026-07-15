# shell scripting Development Workflow

## Development Workflow

Execute shell scripting through systematic phases:

### 1. Script Analysis

Understand existing scripts and establish best practices.

Analysis priorities:

- Existing script structure and organization
- Shell compatibility requirements
- Library and utility functions in use
- Error handling patterns
- Testing and validation approach
- Performance requirements
- Security considerations
- Documentation completeness

Technical evaluation:

- Review script structure and organization
- Analyze variable usage and scoping
- Assess error handling strategies
- Check portability across shells
- Evaluate function modularity
- Review command usage patterns
- Identify performance bottlenecks
- Check security practices

### 2. Implementation Phase

Develop shell scripts with focus on reliability and maintainability.

Implementation approach:

- Start with POSIX sh compatibility when possible
- Use functions for code reuse and clarity
- Implement comprehensive error handling
- Add input validation and sanitization
- Create modular utility libraries
- Document scripts with clear headers
- Use meaningful variable and function names
- Optimize for performance and readability

Development patterns:

- Begin with shebang and strict mode (set -euo pipefail)
- Define functions before main execution
- Implement trap handlers for cleanup
- Use local variables in functions
- Add detailed comments for complex logic
- Test across target shells (sh, bash, zsh)
- Verify with shellcheck
- Implement proper error messages

### 3. Quality Assurance

Ensure scripts meet production standards.

Quality verification:

- Shellcheck passes with no warnings
- POSIX sh compliance verified
- Bash/Zsh compatibility tested
- Error handling tested
- Edge cases covered
- Performance benchmarks met
- Security review passed
- Documentation complete

Advanced patterns:

- State machine implementation in shell
- Plugin architecture with sourced modules
- Dynamic function generation
- Functional programming patterns
- Configuration file parsing
- Template expansion
- Namespace management
- Environment isolation

System automation:

- Service orchestration scripts
- Configuration management
- Log aggregation and analysis
- Monitoring and alerting
- Backup and disaster recovery
- Patch management
- Performance tuning
- Capacity planning automation

Deployment automation:

- Application deployment scripts
- Rolling deployment strategies
- Rollback automation
- Health check implementation
- Database migration automation
- Container orchestration
- Load balancer configuration
- DNS and service discovery

Always prioritize clarity, portability, and reliability while building scripts that scale from simple automation to complex systems management.
