# Contributing to DiscordInteractions

First off, thank you for considering contributing to DiscordInteractions! It's people like you that make this library better for everyone.

The following is a set of guidelines for contributing to DiscordInteractions, which is hosted on GitHub at [profiq/discord-interactions-elixir](https://github.com/profiq/discord-interactions-elixir). These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Code of Conduct

This project and everyone participating in it is governed by the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [conduct@profiq.com](mailto:conduct@profiq.com).

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

**Before Submitting A Bug Report:**

* Check the [issues](https://github.com/profiq/discord-interactions-elixir/issues) to see if the problem has already been reported.
* Perform a cursory search to see if the problem has already been reported.

**How Do I Submit A (Good) Bug Report?**

Bugs are tracked as GitHub issues. Create an issue and provide the following information:

* Use a clear and descriptive title
* Describe the exact steps which reproduce the problem
* Provide specific examples to demonstrate the steps
* Describe the behavior you observed after following the steps
* Explain which behavior you expected to see instead and why
* Include screenshots or animated GIFs if possible
* Include your environment details (OS, Elixir version, etc.)

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion, including completely new features and minor improvements to existing functionality.

**How Do I Submit A (Good) Enhancement Suggestion?**

Enhancement suggestions are tracked as GitHub issues. Create an issue and provide the following information:

* Use a clear and descriptive title
* Provide a step-by-step description of the suggested enhancement
* Provide specific examples to demonstrate the steps
* Describe the current behavior and explain which behavior you expected to see instead
* Explain why this enhancement would be useful to most users
* List some other libraries or applications where this enhancement exists, if applicable

### Pull Requests

* Fill in the required template
* Follow the [Elixir style guide](https://github.com/christopheradams/elixir_style_guide)
* Include tests for new features or bug fixes
* End all files with a newline
* Place requires and aliases at the top of modules
* Avoid platform-dependent code

## Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/profiq/discord-interactions-elixir.git`
3. Install dependencies: `mix deps.get`
4. Run tests: `mix test`

## Styleguides

### Git Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages. This leads to more readable messages that are easy to follow when looking through the project history.

Each commit message consists of a **header**, a **body** and a **footer**. The header has a special format that includes a **type**, a **scope** and a **subject**:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The **header** is mandatory and the **scope** of the header is optional.

Examples:

```
feat(commands): add support for user commands

fix(api): handle rate limit errors properly

docs(readme): update installation instructions
```

#### Type

Must be one of the following:

* **build**: Changes that affect the build system or external dependencies
* **ci**: Changes to our CI configuration files and scripts
* **docs**: Documentation only changes
* **feat**: A new feature
* **fix**: A bug fix
* **perf**: A code change that improves performance
* **refactor**: A code change that neither fixes a bug nor adds a feature
* **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
* **test**: Adding missing tests or correcting existing tests

### Elixir Styleguide

* Use the formatter: `mix format`
* Follow Credo recommendations: `mix credo --strict`
* Write documentation for public functions
* Write tests for new functionality

## Testing

* Ensure all tests pass: `mix test`
* Add tests for new features
* Ensure code passes Credo checks: `mix credo --strict`
* Ensure code is properly formatted: `mix format --check-formatted`

## Additional Notes

### Issue and Pull Request Labels

This section lists the labels we use to help us track and manage issues and pull requests.

* **bug** - Issues that are bugs
* **documentation** - Issues or PRs related to documentation
* **enhancement** - Issues that are feature requests or PRs that implement features
* **good first issue** - Good for newcomers
* **help wanted** - Extra attention is needed

## Thank You!

Your contributions to open source, large or small, make projects like this possible. Thank you for taking the time to contribute.
