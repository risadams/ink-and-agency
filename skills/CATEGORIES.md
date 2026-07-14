# Skill Categories

All skills live under `skills/<category>/<name>/SKILL.md`. Categories are folders for
browsability only — a skill's invocation name is its leaf folder and is independent of
category (see [ADR-0007](../docs/adr/ADR-0007-skill-categories.md)). Discovery is recursive.

**215 skills across 15 categories.**

## Business & Product &nbsp;`business-product` (22)

Product, project, delivery, issue management, and go-to-market.

- [`assumption-mapping`](business-product/assumption-mapping/) — Use when the user needs to identify and prioritize risky assumptions in a product idea, feature, or strategy.
- [`backlog-grooming`](business-product/backlog-grooming/) — Use when the user needs to groom, refine, or clean up a product backlog.
- [`business-analyst`](business-product/business-analyst/) — Use when analyzing business processes, gathering requirements from stakeholders, or identifying process improvement opportunities to drive o
- [`content-marketer`](business-product/content-marketer/) — Use when you need to develop comprehensive content strategies, create SEO-optimized marketing content, or execute multi-channel content camp
- [`content-quality-editor`](business-product/content-quality-editor/) — Use this skill before publishing any AI-generated content — blog posts, READMEs, release notes, commit messages, PR descriptions, documentat
- [`customer-success-manager`](business-product/customer-success-manager/) — Use when you need to assess customer health, develop retention strategies, identify upsell opportunities, or maximize customer lifetime valu
- [`growth-loops`](business-product/growth-loops/) — Use when the user wants to design a growth loop, understand PLG mechanics, or build sustainable acquisition.
- [`issue-draft-release-notes`](business-product/issue-draft-release-notes/) — Draft a customer-facing release note for a Jira ticket by gathering the ticket context (summary, description, type, fix version, comments) a
- [`issue-dup-find`](business-product/issue-dup-find/) — Scan all open issues in a Jira project and identify likely duplicates using semantic comparison.
- [`issue-estimate-sp`](business-product/issue-estimate-sp/) — Estimate story points for a Jira ticket using historical data and multi-persona scrum poker.
- [`issue-feature-breakdown`](business-product/issue-feature-breakdown/) — Analyze a Jira ticket by gathering full context from Jira and Confluence, following linked tickets, then running a clarity-council to identi
- [`issue-suggest-component`](business-product/issue-suggest-component/) — Suggest Jira components for one ticket or sweep all open tickets in a project.
- [`issue-triage`](business-product/issue-triage/) — Triage a bug or issue by gathering context (Jira ticket or free-form description), mapping the suspected code area via codebase-explain, hyp
- [`legal-advisor`](business-product/legal-advisor/) — Use when you need to draft contracts, review compliance requirements, develop IP protection strategies, or assess legal risks for technology
- [`license-engineer`](business-product/license-engineer/) — Use when architecting, implementing, or optimizing end-to-end legal licensing systems—from OSI standard selection and dependency compliance 
- [`product-manager`](business-product/product-manager/) — Use when you need to make product strategy decisions, prioritize features, or define roadmap plans based on user needs and business goals.
- [`project-manager`](business-product/project-manager/) — Use when you need to establish project plans, track execution progress, manage risks, control budget/schedule, and coordinate stakeholders a
- [`sales-engineer`](business-product/sales-engineer/) — Use when you need to conduct technical pre-sales activities including solution architecture, proof-of-concept development, and technical dem
- [`scrum-master`](business-product/scrum-master/) — Use when teams need facilitation, process optimization, velocity improvement, or agile ceremony management—especially for sprint planning, r
- [`technical-writer`](business-product/technical-writer/) — Use when you need to create, improve, or maintain technical documentation including API references, user guides, SDK documentation, and gett
- [`ux-researcher`](business-product/ux-researcher/) — Use when you need to conduct user research, analyze user behavior, or generate actionable insights to validate design decisions and uncover 
- [`wordpress-master`](business-product/wordpress-master/) — Use when you need to architect, optimize, or troubleshoot WordPress implementations ranging from custom theme/plugin development to enterpri

## Codebase & Build &nbsp;`codebase-build` (8)

Understand, review, debug, and build a codebase (the implement/tdd loop).

- [`code-review`](codebase-build/code-review/) — Two-axis review of the working diff since a fixed point — Standards (does it follow this repo's coding standards + a code-smell baseline?) a
- [`codebase-churn`](codebase-build/codebase-churn/) — Analyze a git repository's history and produce an SVG treemap of file churn — area = lines changed, color = commit frequency.
- [`codebase-explain`](codebase-build/codebase-explain/) — Tell the agent to explain code with broader context and a higher-level perspective.
- [`codebase-improve-architecture`](codebase-build/codebase-improve-architecture/) — Find deepening opportunities in a codebase, informed by the domain language in CONTEXT.md and the decisions in docs/adr/.
- [`codebase-plan-refactor`](codebase-build/codebase-plan-refactor/) — Create a detailed refactor plan with tiny commits via user interview, then file it as an issue.
- [`debug`](codebase-build/debug/) — Diagnosis loop for hard bugs and performance regressions.
- [`implement`](codebase-build/implement/) — Build a piece of work (ticket, spec, or free-form request) through a tunable pipeline — test-first, verify, review, and track — where every 
- [`tdd`](codebase-build/tdd/) — Test-driven development — the red → green loop and the rules that make its tests worth keeping.

## Core Development &nbsp;`core-development` (11)

Full-stack, backend, frontend, mobile, API, and architecture builders.

- [`api-designer`](core-development/api-designer/) — Use when designing new APIs, creating API specifications, or refactoring existing API architecture for scalability and developer experience.
- [`backend-developer`](core-development/backend-developer/) — Use when building server-side APIs, microservices, and backend systems that require robust architecture, scalability planning, and productio
- [`design-bridge`](core-development/design-bridge/) — Use when you need to translate a DESIGN.md into polished Claude Code instructions for building user interfaces that faithfully match the cho
- [`electron-pro`](core-development/electron-pro/) — Use when building Electron desktop applications that require native OS integration, cross-platform distribution, security hardening, and per
- [`frontend-developer`](core-development/frontend-developer/) — Use when building complete frontend applications across React, Vue, and Angular frameworks requiring multi-framework expertise and full-stac
- [`fullstack-developer`](core-development/fullstack-developer/) — Use when you need to build complete features spanning database, API, and frontend layers together as a cohesive unit.
- [`graphql-architect`](core-development/graphql-architect/) — Use when designing or evolving GraphQL schemas across microservices, implementing federation architectures, or optimizing query performance 
- [`microservices-architect`](core-development/microservices-architect/) — Use when designing distributed system architecture, decomposing monolithic applications into independent microservices, or establishing comm
- [`mobile-developer`](core-development/mobile-developer/) — Use when building cross-platform mobile applications requiring native performance optimization, platform-specific features, and offline-firs
- [`ui-designer`](core-development/ui-designer/) — Use when designing visual interfaces, creating design systems, building component libraries, or refining user-facing aesthetics requiring ex
- [`websocket-engineer`](core-development/websocket-engineer/) — Use when implementing real-time bidirectional communication features using WebSockets, Socket.IO, or similar technologies at scale.

## Data & AI &nbsp;`data-ai` (11)

Data engineering, ML, AI, analytics, and LLM work.

- [`ai-engineer`](data-ai/ai-engineer/) — Use when architecting, implementing, or optimizing end-to-end AI systems—from model selection and training pipelines to production deploymen
- [`data-analyst`](data-ai/data-analyst/) — Use when you need to extract insights from business data, create dashboards and reports, or perform statistical analysis to support decision
- [`data-engineer`](data-ai/data-engineer/) — Use when you need to design, build, or optimize data pipelines, ETL/ELT processes, and data infrastructure.
- [`data-scientist`](data-ai/data-scientist/) — Use when you need to analyze data patterns, build predictive models, or extract statistical insights from datasets.
- [`database-optimizer`](data-ai/database-optimizer/) — Use when you need to analyze slow queries, optimize database performance across multiple systems, or implement indexing strategies to improv
- [`llm-architect`](data-ai/llm-architect/) — Use when designing LLM systems for production, implementing fine-tuning or RAG architectures, optimizing inference serving infrastructure, o
- [`ml-engineer`](data-ai/ml-engineer/) — Use when building production ML systems requiring model training pipelines, model serving infrastructure, performance optimization, and auto
- [`nlp-engineer`](data-ai/nlp-engineer/) — Use when building production NLP systems, implementing text processing pipelines, developing language models, or solving domain-specific NLP
- [`postgres-pro`](data-ai/postgres-pro/) — Use when you need to optimize PostgreSQL performance, design high-availability replication, or troubleshoot database issues at scale.
- [`prompt-engineer`](data-ai/prompt-engineer/) — Use when you need to design, optimize, test, or evaluate prompts for large language models in production systems.
- [`reinforcement-learning-engineer`](data-ai/reinforcement-learning-engineer/) — Use when designing RL environments, training agents with reward optimization, implementing policy gradient methods, or deploying decision-ma

## Developer Experience &nbsp;`developer-experience` (17)

Tooling, build, CLI, docs, refactoring, and Git workflow.

- [`branch-rebase`](developer-experience/branch-rebase/) — Safely rebase the current branch onto its upstream target (baseline, main, or master).
- [`branch-resolve-conflicts`](developer-experience/branch-resolve-conflicts/) — Resolve complex git merge/rebase conflicts by reconstructing intent, preserving both branches' goals when possible, and running automated ch
- [`build-engineer`](developer-experience/build-engineer/) — Use when you need to optimize build performance, reduce compilation times, or scale build systems across growing teams.
- [`cli-developer`](developer-experience/cli-developer/) — Use when building command-line tools and terminal applications that require intuitive command design, cross-platform compatibility, and opti
- [`dependency-manager`](developer-experience/dependency-manager/) — Use when you need to audit dependencies for vulnerabilities, resolve version conflicts, optimize bundle sizes, or implement automated depend
- [`documentation-engineer`](developer-experience/documentation-engineer/) — Use when you need to create, architect, or overhaul comprehensive documentation systems including API docs, tutorials, guides, and developer
- [`dx-optimizer`](developer-experience/dx-optimizer/) — Use when optimizing the complete developer workflow including build times, feedback loops, testing efficiency, and developer satisfaction me
- [`git-workflow-manager`](developer-experience/git-workflow-manager/) — Use when you need to design, establish, or optimize Git workflows, branching strategies, and merge management for a project or team.
- [`legacy-modernizer`](developer-experience/legacy-modernizer/) — Use when modernizing legacy systems that need incremental migration strategies, technical debt reduction, and risk mitigation while maintain
- [`mcp-developer`](developer-experience/mcp-developer/) — Use when you need to build, debug, or optimize Model Context Protocol (MCP) servers and clients that connect AI systems to external tools an
- [`powershell-module-architect`](developer-experience/powershell-module-architect/) — Use when architecting and refactoring PowerShell modules, designing profile systems, or creating cross-version compatible automation librari
- [`powershell-ui-architect`](developer-experience/powershell-ui-architect/) — Use when designing or building desktop graphical interfaces (WinForms, WPF, Metro-style dashboards) or terminal user interfaces (TUIs) for P
- [`readme-generator`](developer-experience/readme-generator/) — Use when you need a maintainer-ready README built from exact repository reality, with deep codebase scanning, zero hallucination, and option
- [`refactoring-specialist`](developer-experience/refactoring-specialist/) — Use when you need to transform poorly structured, complex, or duplicated code into clean, maintainable systems while preserving all existing
- [`slack-expert`](developer-experience/slack-expert/) — Use when developing Slack applications, implementing Slack API integrations, or reviewing Slack bot code for security and best practices.
- [`tooling-engineer`](developer-experience/tooling-engineer/) — Use when you need to build or enhance developer tools including CLIs, code generators, build tools, and IDE extensions.
- [`visual-asset-generator`](developer-experience/visual-asset-generator/) — Use when you need to generate production-ready visual assets for a project — app icons, favicons, OG images, logos, wordmarks, or social med

## Executive Function &nbsp;`exec-function` (9)

Neurodivergent-friendly executive-function support.

- [`break-it-down`](exec-function/break-it-down/) — Decode messages into plain language with tone and intent analysis.
- [`daily-briefing`](exec-function/daily-briefing/) — Personal daily briefing assistant.
- [`energy-budget`](exec-function/energy-budget/) — Log today's load (meetings, sensory stuff, social events, deep work); skill scores the load, warns when the day is heading toward burnout, a
- [`hyperfocus-recovery`](exec-function/hyperfocus-recovery/) — Reconstruct context after a deep session or interruption — "what was I doing?" Reads recent git diff, modified files, open editors, and last
- [`interest-capture`](exec-function/interest-capture/) — Quick dump for the current hyperfixation so it doesn't derail today's work but also isn't lost.
- [`meeting-decompression`](exec-function/meeting-decompression/) — Dump what happened in a meeting; skill separates facts from feelings, flags action items, and notes social ambiguities to follow up on (inst
- [`rejection-sensitivity-check`](exec-function/rejection-sensitivity-check/) — Paste a message that stung; get a calibrated read on whether it's actually critical or neutral-but-terse.
- [`task-initiation`](exec-function/task-initiation/) — You know what to do but can't start.
- [`time-reality-check`](exec-function/time-reality-check/) — Counter time blindness — you say "20 minutes" but it'll take 2 hours.

## Infrastructure &nbsp;`infrastructure` (16)

DevOps, cloud, containers, networking, databases, and incident response.

- [`azure-infra-engineer`](infrastructure/azure-infra-engineer/) — Use when designing, deploying, or managing Azure infrastructure with focus on network architecture, Entra ID integration, PowerShell automat
- [`cloud-architect`](infrastructure/cloud-architect/) — Use when you need to design, evaluate, or optimize cloud infrastructure architecture at scale.
- [`database-administrator`](infrastructure/database-administrator/) — Use when optimizing database performance, implementing high-availability architectures, setting up disaster recovery, or managing database i
- [`deployment-engineer`](infrastructure/deployment-engineer/) — Use when designing, building, or optimizing CI/CD pipelines and deployment automation strategies.
- [`devops-engineer`](infrastructure/devops-engineer/) — Use when building or optimizing infrastructure automation, CI/CD pipelines, containerization strategies, and deployment workflows to acceler
- [`devops-incident-responder`](infrastructure/devops-incident-responder/) — Use when actively responding to production incidents, diagnosing critical service failures, or conducting incident postmortems to implement 
- [`docker-expert`](infrastructure/docker-expert/) — Use when you need to build, optimize, or secure Docker container images and orchestration for production environments.
- [`incident-responder`](infrastructure/incident-responder/) — Use when an active security breach, service outage, or operational incident requires immediate response, evidence preservation, and coordina
- [`kubernetes-specialist`](infrastructure/kubernetes-specialist/) — Use when you need to design, deploy, configure, or troubleshoot Kubernetes clusters and workloads in production environments.
- [`network-engineer`](infrastructure/network-engineer/) — Use when designing, optimizing, or troubleshooting cloud and hybrid network infrastructures, or when addressing network security, performanc
- [`platform-engineer`](infrastructure/platform-engineer/) — Use when building or improving internal developer platforms (IDPs), designing self-service infrastructure, or optimizing developer workflows
- [`security-engineer`](infrastructure/security-engineer/) — Use when implementing comprehensive security solutions across infrastructure, building automated security controls into CI/CD pipelines, or 
- [`sre-engineer`](infrastructure/sre-engineer/) — Use when you need to establish or improve system reliability through SLO definition, error budget management, and automation.
- [`terraform-engineer`](infrastructure/terraform-engineer/) — Use when building, refactoring, or scaling infrastructure as code using Terraform with focus on multi-cloud deployments, module architecture
- [`terragrunt-expert`](infrastructure/terragrunt-expert/) — Expert Terragrunt specialist mastering infrastructure orchestration, DRY configurations, and multi-environment deployments.
- [`windows-infra-admin`](infrastructure/windows-infra-admin/) — Use when managing Windows Server infrastructure, Active Directory, DNS, DHCP, and Group Policy configurations, especially for enterprise-sca

## Language Specialists &nbsp;`language-specialists` (33)

Language- and framework-specific experts.

- [`angular-architect`](language-specialists/angular-architect/) — Use when architecting enterprise Angular 15+ applications with complex state management, optimizing RxJS patterns, designing micro-frontend 
- [`ansible-expert`](language-specialists/ansible-expert/) — Use when building infrastructure automation, configuration management, and orchestration with Ansible.
- [`cpp-pro`](language-specialists/cpp-pro/) — Use when building high-performance C++ systems requiring modern C++20/23 features, template metaprogramming, or zero-overhead abstractions f
- [`csharp-developer`](language-specialists/csharp-developer/) — Use when building ASP.NET Core web APIs, cloud-native .NET solutions, or modern C# applications requiring async patterns, dependency injecti
- [`django-developer`](language-specialists/django-developer/) — Use when building Django 4+ web applications, REST APIs, or modernizing existing Django projects with async views and enterprise patterns.
- [`dotnet-core-expert`](language-specialists/dotnet-core-expert/) — Use when building .NET Core applications requiring cloud-native architecture, high-performance microservices, modern C# patterns, or cross-p
- [`dotnet-framework-4.8-expert`](language-specialists/dotnet-framework-4.8-expert/) — Use when working on legacy .NET Framework 4.8 enterprise applications that require maintenance, modernization, or integration with Windows-b
- [`elixir-expert`](language-specialists/elixir-expert/) — Use when you need to build fault-tolerant, concurrent systems leveraging OTP patterns, GenServer architectures, and Phoenix framework for re
- [`expo-react-native-expert`](language-specialists/expo-react-native-expert/) — Use when building mobile applications with Expo and React Native that require native module integration, navigation setup, performant animat
- [`fastapi-developer`](language-specialists/fastapi-developer/) — Use when building modern async Python APIs with FastAPI, implementing Pydantic v2 validation, dependency injection patterns, or deploying hi
- [`flutter-expert`](language-specialists/flutter-expert/) — Use when building cross-platform mobile applications with Flutter 3+ that require custom UI implementation, complex state management, native
- [`golang-pro`](language-specialists/golang-pro/) — Use when building Go applications requiring concurrent programming, high-performance systems, microservices, or cloud-native architectures w
- [`gradle-expert`](language-specialists/gradle-expert/) — Use when building and configuring Gradle projects, optimizing build performance, managing dependencies, implementing multi-module architectu
- [`java-architect`](language-specialists/java-architect/) — Use when designing enterprise Java architectures, migrating Spring Boot applications, or establishing microservices patterns for scalable cl
- [`javascript-pro`](language-specialists/javascript-pro/) — Use when you need to build, optimize, or refactor modern JavaScript code for browser, Node.js, or full-stack applications requiring ES2023+ 
- [`kotlin-specialist`](language-specialists/kotlin-specialist/) — Use when building Kotlin applications requiring advanced coroutine patterns, multiplatform code sharing, or Android/server-side development 
- [`laravel-specialist`](language-specialists/laravel-specialist/) — Use when building Laravel 10+ applications, architecting Eloquent models with complex relationships, implementing queue systems for async pr
- [`nextjs-developer`](language-specialists/nextjs-developer/) — Use when building production Next.js 14+ applications that require full-stack development with App Router, server components, and advanced p
- [`node-specialist`](language-specialists/node-specialist/) — Use when you need to build, optimize, or debug Node.js backend applications, APIs, CLIs, or microservices requiring deep ecosystem knowledge
- [`php-pro`](language-specialists/php-pro/) — Use when working with PHP 8.3+ projects that require strict typing, modern language features, and enterprise framework expertise (Laravel or
- [`powershell-5.1-expert`](language-specialists/powershell-5.1-expert/) — Use when automating Windows infrastructure tasks requiring PowerShell 5.1 scripts with RSAT modules for Active Directory, DNS, DHCP, GPO man
- [`powershell-7-expert`](language-specialists/powershell-7-expert/) — Use when building cross-platform cloud automation scripts, Azure infrastructure orchestration, or CI/CD pipelines requiring PowerShell 7+ wi
- [`python-pro`](language-specialists/python-pro/) — Use when you need to build type-safe, production-ready Python code for web APIs, system utilities, or complex applications requiring modern 
- [`rails-expert`](language-specialists/rails-expert/) — Use when building or modernizing Rails applications requiring API development, Hotwire reactivity, real-time features, background job proces
- [`react-specialist`](language-specialists/react-specialist/) — Use when optimizing existing React applications for performance, implementing advanced React 18+ features, or solving complex state manageme
- [`rust-engineer`](language-specialists/rust-engineer/) — Use when building Rust systems where memory safety, ownership patterns, zero-cost abstractions, and performance optimization are critical fo
- [`shell-expert`](language-specialists/shell-expert/) — Use when building shell scripts for system administration, automation, and DevOps.
- [`spring-boot-engineer`](language-specialists/spring-boot-engineer/) — Use when building enterprise Spring Boot 3+ applications requiring microservices architecture, cloud-native deployment, or reactive programm
- [`sql-pro`](language-specialists/sql-pro/) — Use when you need to optimize complex SQL queries, design efficient database schemas, or solve performance issues across PostgreSQL, MySQL, 
- [`swift-expert`](language-specialists/swift-expert/) — Use when building native iOS, macOS, or server-side Swift applications requiring advanced concurrency patterns, protocol-oriented architectu
- [`symfony-specialist`](language-specialists/symfony-specialist/) — Use when building Symfony 6+/7+/8+ applications, architecting Doctrine ORM entities with complex relationships, implementing Messenger compo
- [`typescript-pro`](language-specialists/typescript-pro/) — Use when implementing TypeScript code requiring advanced type system patterns, complex generics, type-level programming, or end-to-end type 
- [`vue-expert`](language-specialists/vue-expert/) — Use when building Vue 3 applications that require Composition API mastery, reactivity optimization, or Nuxt 3 development with enterprise-sc

## Meta-Orchestration &nbsp;`meta-orchestration` (19)

Multi-agent coordination, planning, and the plan→spec→tickets build pipeline.

- [`agent-installer`](meta-orchestration/agent-installer/) — Use when the user wants to discover, browse, or install Claude Code agents from the subagent repository.
- [`agent-organizer`](meta-orchestration/agent-organizer/) — Use when assembling and optimizing multi-agent teams to execute complex projects that require careful task decomposition, agent capability m
- [`codebase-orchestrator`](meta-orchestration/codebase-orchestrator/) — Use when you need repository-wide refactor governance with explicit approval loops, weighted risk prioritization, diff previews, and determi
- [`context-manager`](meta-orchestration/context-manager/) — Use for managing shared state, information retrieval, and data synchronization when multiple agents need coordinated access to context and m
- [`defuddle`](meta-orchestration/defuddle/) — Extract clean markdown content from web pages using Defuddle CLI, removing clutter and navigation to save tokens.
- [`error-coordinator`](meta-orchestration/error-coordinator/) — Use when distributed system errors occur and need coordinated handling across multiple components, or when you need to implement comprehensi
- [`handoff`](meta-orchestration/handoff/) — Compact the current conversation into a handoff document for another agent to pick up.
- [`it-ops-orchestrator`](meta-orchestration/it-ops-orchestrator/) — Use for orchestrating complex IT operations tasks that span multiple domains (PowerShell automation, .NET development, infrastructure manage
- [`knowledge-synthesizer`](meta-orchestration/knowledge-synthesizer/) — Use when you need to extract actionable patterns from agent interactions, synthesize insights across multiple workflows, and enable organiza
- [`multi-agent-coordinator`](meta-orchestration/multi-agent-coordinator/) — Use when coordinating multiple concurrent agents that need to communicate, share state, synchronize work, and handle distributed failures ac
- [`performance-monitor`](meta-orchestration/performance-monitor/) — Use when establishing observability infrastructure to track system metrics, detect performance anomalies, and optimize resource usage across
- [`plan-to-spec`](meta-orchestration/plan-to-spec/) — Synthesize the current conversation into a spec (PRD) and stage it as a local file.
- [`plan-to-tickets`](meta-orchestration/plan-to-tickets/) — Break a spec, plan, or the current conversation into a local, numbered, spec-kit-style task list of tracer-bullet vertical slices with expli
- [`research`](meta-orchestration/research/) — Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo.
- [`skill-create`](meta-orchestration/skill-create/) — Create new agent skills with proper structure, progressive disclosure, and bundled resources.
- [`task-distributor`](meta-orchestration/task-distributor/) — Use when distributing tasks across multiple agents or workers, managing queues, and balancing workloads to maximize throughput while respect
- [`teach`](meta-orchestration/teach/) — Teach the user a new skill or concept, within this workspace.
- [`work-plan`](meta-orchestration/work-plan/) — Plan a huge chunk of work — more than one agent session can hold — as a shared map of decision tickets on your issue tracker, and resolve th
- [`workflow-orchestrator`](meta-orchestration/workflow-orchestrator/) — Use when you need to design, implement, or optimize complex business process workflows with multiple states, error handling, and transaction

## Obsidian &nbsp;`obsidian` (6)

Read/write and structure an Obsidian vault.

- [`obsidian-bases`](obsidian/obsidian-bases/) — Create and edit Obsidian Bases (.base files) with views, filters, formulas, and summaries.
- [`obsidian-canvas`](obsidian/obsidian-canvas/) — Create and edit Obsidian Canvas files (.canvas) following the JSON Canvas spec — nodes, edges, groups, and connections.
- [`obsidian-charts`](obsidian/obsidian-charts/) — Build interactive charts in Obsidian notes using the Charts plugin (phibr0/obsidian-charts).
- [`obsidian-cli`](obsidian/obsidian-cli/) — Interact with Obsidian vaults using the Obsidian CLI to read, create, search, and manage notes, tasks, properties, and more.
- [`obsidian-markdown`](obsidian/obsidian-markdown/) — Create and edit Obsidian Flavored Markdown with wikilinks, embeds, callouts, properties, and other Obsidian-specific syntax.
- [`obsidian-vault`](obsidian/obsidian-vault/) — Search, create, and manage notes in the Obsidian vault with wikilinks and index notes.

## Quality & Security &nbsp;`quality-security` (17)

Testing, code review, security auditing, compliance, and performance.

- [`accessibility-tester`](quality-security/accessibility-tester/) — Use when you need comprehensive accessibility testing, WCAG compliance verification, or assessment of assistive technology support.
- [`ad-security-reviewer`](quality-security/ad-security-reviewer/) — Use when you need to audit Active Directory security posture, evaluate privilege escalation risks, review identity delegation patterns, or a
- [`ai-writing-auditor`](quality-security/ai-writing-auditor/) — Use when you need to audit content for AI writing patterns and rewrite text to remove them.
- [`architect-reviewer`](quality-security/architect-reviewer/) — Use when you need to evaluate system design decisions, architectural patterns, and technology choices at the macro level.
- [`chaos-engineer`](quality-security/chaos-engineer/) — Use when you need to design and execute controlled failure experiments, validate system resilience before incidents occur, or conduct game d
- [`code-reviewer`](quality-security/code-reviewer/) — Use when you need to conduct comprehensive code reviews focusing on code quality, security vulnerabilities, and best practices.
- [`compliance-auditor`](quality-security/compliance-auditor/) — Use when you need to achieve regulatory compliance, implement compliance controls, or prepare for audits across frameworks like GDPR, HIPAA,
- [`debugger`](quality-security/debugger/) — Use when you need to diagnose and fix bugs, identify root causes of failures, or analyze error logs and stack traces to resolve issues.
- [`error-detective`](quality-security/error-detective/) — Use when you need to diagnose why errors are occurring in your system, correlate errors across services, identify root causes, and prevent f
- [`gdpr-ccpa-compliance`](quality-security/gdpr-ccpa-compliance/) — Use when the user needs to understand GDPR or CCPA compliance, review data practices, or assess privacy requirements.
- [`penetration-tester`](quality-security/penetration-tester/) — Use when you need to conduct authorized security penetration tests to identify real vulnerabilities through active exploitation and validati
- [`performance-engineer`](quality-security/performance-engineer/) — Use when you need to identify and eliminate performance bottlenecks in applications, databases, or infrastructure systems, and when baseline
- [`powershell-security-hardening`](quality-security/powershell-security-hardening/) — Use when you need to harden PowerShell automation, secure remoting configuration, enforce least-privilege design, or align scripts with ente
- [`qa-expert`](quality-security/qa-expert/) — Use when you need comprehensive quality assurance strategy, test planning across the entire development cycle, or quality metrics analysis t
- [`security-auditor`](quality-security/security-auditor/) — Use when conducting comprehensive security audits, compliance assessments, or risk evaluations across systems, infrastructure, and processes
- [`test-automator`](quality-security/test-automator/) — Use when you need to build, implement, or enhance automated test frameworks, create test scripts, or integrate testing into CI/CD pipelines.
- [`ui-ux-tester`](quality-security/ui-ux-tester/) — Use when you need exhaustive UI and UX functionality testing driven by documented user flows, with browser or desktop interaction tooling an

## Research & Analysis &nbsp;`research-analysis` (18)

Research, decision support, idea work, and the clarity-council.

- [`ab-test-analysis`](research-analysis/ab-test-analysis/) — Use when the user wants to analyze A/B test results, interpret p-values, determine statistical significance, or make a ship/no-ship decision
- [`clarity-council`](research-analysis/clarity-council/) — Facilitates structured single-persona or multi-persona consultation for strategy, product, engineering, operations, and risk decisions.
- [`cohort-analysis`](research-analysis/cohort-analysis/) — Use when the user wants to analyze retention, cohort behavior, engagement trends, or understand how different user groups perform over time.
- [`competitive-analyst`](research-analysis/competitive-analyst/) — Use when you need to analyze direct and indirect competitors, benchmark against market leaders, or develop strategies to strengthen competit
- [`data-researcher`](research-analysis/data-researcher/) — Use when you need to discover, collect, and validate data from multiple sources to fuel analysis and decision-making.
- [`first-principles-thinking`](research-analysis/first-principles-thinking/) — Use when the user wants to challenge assumptions, break down a complex problem from scratch, or approach something with first principles rea
- [`grill-me`](research-analysis/grill-me/) — Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree.
- [`grill-with-docs`](research-analysis/grill-with-docs/) — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (CONTEXT.md, A
- [`idea-choice`](research-analysis/idea-choice/) — Weigh one or more ideas/concepts with a structured pros-and-cons analysis.
- [`idea-decision-maker`](research-analysis/idea-decision-maker/) — Stuck between options.
- [`idea-generate`](research-analysis/idea-generate/) — Helps users generate, refine, and stress-test ideas from loose topics.
- [`market-researcher`](research-analysis/market-researcher/) — Use when you need to analyze markets, understand consumer behavior, assess competitive landscapes, and size opportunities to inform business
- [`project-idea-validator`](research-analysis/project-idea-validator/) — Use when you need an idea pressure-tested with brutal honesty, competitor teardown, market validation, and clear go/no-go guidance before bu
- [`research-analyst`](research-analysis/research-analyst/) — Use when you need comprehensive research across multiple sources with synthesis of findings into actionable insights, trend identification, 
- [`scientific-literature-researcher`](research-analysis/scientific-literature-researcher/) — Use when you need to search scientific literature and retrieve structured experimental data from published studies.
- [`search-specialist`](research-analysis/search-specialist/) — Use when you need to find specific information across multiple sources using advanced search strategies, query optimization, and targeted in
- [`trend-analyst`](research-analysis/trend-analyst/) — Use when analyzing emerging patterns, predicting industry shifts, or developing future scenarios to inform strategic planning and competitiv
- [`which-skill`](research-analysis/which-skill/) — Router over this pack's skills and flows.

## Scrum & Sprint &nbsp;`scrum-sprint` (6)

The Scrum ceremony chain — snapshot, plan, standup, review.

- [`daily-standup-prep`](scrum-sprint/daily-standup-prep/) — Generate a per-team standup markdown report by gathering activity over the last N days from Jira, GitLab, Confluence, and a local Git repo.
- [`good-morning`](scrum-sprint/good-morning/) — Morning kickoff wrapper that runs sprint-snapshot (daily tag), daily-standup-prep (with sprint burndown), and daily-briefing (report only — 
- [`sprint-plan`](scrum-sprint/sprint-plan/) — Convert the start-of-sprint canvas into a planning markdown report — sprint goal summary, committed scope, capacity vs commitment (split int
- [`sprint-review`](scrum-sprint/sprint-review/) — End-of-sprint stakeholder report comparing the start.canvas (planning) to end.canvas (sprint close).
- [`sprint-snapshot`](scrum-sprint/sprint-snapshot/) — Capture a point-in-time snapshot of a scrum team's current sprint board from Jira and render it into the Obsidian vault as (1) an Obsidian C
- [`sprint-sos-report`](scrum-sprint/sprint-sos-report/) — End-of-week scrum-of-scrums report comparing two sprint snapshots and surfacing key findings, observations, trouble areas, and trends.

## Specialized Domains &nbsp;`specialized-domains` (13)

Vertical expertise — blockchain, IoT, fintech, gaming, healthcare, and more.

- [`api-documenter`](specialized-domains/api-documenter/) — Use when creating or improving API documentation, writing OpenAPI specifications, building interactive documentation portals, or generating 
- [`blockchain-developer`](specialized-domains/blockchain-developer/) — Use when building smart contracts, DApps, and blockchain protocols that require expertise in Solidity, gas optimization, security auditing, 
- [`embedded-systems`](specialized-domains/embedded-systems/) — Use when developing firmware for resource-constrained microcontrollers, implementing RTOS-based applications, or optimizing real-time system
- [`fintech-engineer`](specialized-domains/fintech-engineer/) — Use when building payment systems, financial integrations, or compliance-heavy financial applications that require secure transaction proces
- [`game-developer`](specialized-domains/game-developer/) — Use when implementing game systems, optimizing graphics rendering, building multiplayer networking, or developing gameplay mechanics for gam
- [`healthcare-admin`](specialized-domains/healthcare-admin/) — Use when working on healthcare administration tasks including revenue cycle management, HIPAA/compliance auditing, medical coding (ICD-10, C
- [`hipaa-compliance`](specialized-domains/hipaa-compliance/) — Use when the user is building a healthcare product and needs to understand HIPAA compliance.
- [`iot-engineer`](specialized-domains/iot-engineer/) — Use when designing and deploying IoT solutions requiring expertise in device management, edge computing, cloud integration, and handling cha
- [`m365-admin`](specialized-domains/m365-admin/) — Use when automating Microsoft 365 administrative tasks including Exchange Online mailbox provisioning, Teams collaboration management, Share
- [`payment-integration`](specialized-domains/payment-integration/) — Use when implementing payment systems, integrating payment gateways, or handling financial transactions that require PCI compliance, fraud p
- [`quant-analyst`](specialized-domains/quant-analyst/) — Use when you need to develop quantitative trading strategies, build financial models with rigorous mathematical foundations, or conduct adva
- [`risk-manager`](specialized-domains/risk-manager/) — Use when you need to identify, quantify, and mitigate enterprise-level risks across financial, operational, regulatory, and strategic domain
- [`seo-specialist`](specialized-domains/seo-specialist/) — Use when you need comprehensive SEO optimization encompassing technical audits, keyword strategy, content optimization, and search rankings 

## Writing &nbsp;`writing` (9)

Draft, shape, and calibrate written material.

- [`writing-apology-calibrator`](writing/writing-apology-calibrator/) — Drafted apology in, calibrated apology out.
- [`writing-beats`](writing/writing-beats/) — Shape an article as a journey of beats, choose-your-own-adventure style.
- [`writing-cold-open`](writing/writing-cold-open/) — Generates the first sentence of a message or email when you can't get past the blank cursor.
- [`writing-draft-article`](writing/writing-draft-article/) — Guide the user from raw idea, topic, or draft to a finished, polished article through relentless questioning and iterative writing.
- [`writing-fragments`](writing/writing-fragments/) — Grilling session that mines the user for fragments — heterogeneous nuggets of writing (claims, vignettes, sharp sentences, half-thoughts) — 
- [`writing-humanize`](writing/writing-humanize/) — Remove signs of AI-generated writing from text.
- [`writing-shape`](writing/writing-shape/) — Take a markdown file of raw material and shape it into an article through a conversational session — drafting candidate openings, growing th
- [`writing-social-script`](writing/writing-social-script/) — Generate a script for a specific social scenario you're dreading: declining a meeting, asking for a deadline extension, following up on sile
- [`writing-tone-check`](writing/writing-tone-check/) — Reverse decoder — paste a draft message and get a read on how it will land before you send.

