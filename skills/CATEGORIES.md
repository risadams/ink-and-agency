# Skill Categories

All skills live under `skills/<name>/SKILL.md` — a flat layout, because Agent Plugins 1.0.0
fixes skill discovery at the immediate children of `skills/`. Categories are a browsing aid
declared in each skill's `category:` frontmatter field, not a folder path, so recategorizing
a skill moves nothing and breaks no links.

**289 skills across 15 categories**, plus the featured [`clarity-council`](clarity-council/) skill.

> **Featured:** [`clarity-council`](clarity-council/) carries `category: featured` rather than one of
> the 15 below — it's the persona-consultation engine that many other skills delegate to, and it ships
> with the bundled `persona/` library. It's an ordinary invokable skill; the separate bucket just
> reflects how central it is.
>
> **Not a category:** `skills/persona/` holds the 46 council persona contracts — shared reference
> documents (no `SKILL.md`), read by the [`clarity-council`](clarity-council/)
> skill. They're advisory voices you consult, not invokable skills, so they don't appear below.

## Business & Product &nbsp;`business-product` (18)

Product delivery, issue management, and go-to-market.

- [`assumption-mapping`](assumption-mapping/) — Use when the user needs to identify and prioritize risky assumptions in a product idea, feature, or strategy.
- [`backlog-grooming`](backlog-grooming/) — Use when the user needs to groom, refine, or clean up a product backlog.
- [`business-analyst`](business-analyst/) — Use when analyzing business processes, gathering requirements from stakeholders, or identifying process improvement opportunities to drive o
- [`content-marketer`](content-marketer/) — Use when you need to develop comprehensive content strategies, create SEO-optimized marketing content, or execute multi-channel content camp
- [`content-quality-editor`](content-quality-editor/) — Use this skill before publishing any AI-generated content — blog posts, READMEs, release notes, commit messages, PR descriptions, documentat
- [`growth-loops`](growth-loops/) — Use when the user wants to design a growth loop, understand PLG mechanics, or build sustainable acquisition.
- [`issue-draft-release-notes`](issue-draft-release-notes/) — Draft a customer-facing release note for a Jira ticket by gathering the ticket context (summary, description, type, fix version, comments) a
- [`issue-dup-find`](issue-dup-find/) — Scan all open issues in a Jira project and identify likely duplicates using semantic comparison.
- [`issue-estimate-sp`](issue-estimate-sp/) — Estimate story points for a Jira ticket using historical data and multi-persona scrum poker.
- [`issue-feature-breakdown`](issue-feature-breakdown/) — Analyze a Jira ticket by gathering full context from Jira and Confluence, following linked tickets, then running a clarity-council to identi
- [`issue-suggest-component`](issue-suggest-component/) — Suggest Jira components for one ticket or sweep all open tickets in a project.
- [`issue-triage`](issue-triage/) — Triage a bug or issue by gathering context (Jira ticket or free-form description), mapping the suspected code area via codebase-explain, hyp
- [`legal-advisor`](legal-advisor/) — Use when you need to draft contracts, review compliance requirements, develop IP protection strategies, or assess legal risks for technology
- [`license-engineer`](license-engineer/) — Use when architecting, implementing, or optimizing end-to-end legal licensing systems—from OSI standard selection and dependency compliance 
- [`project-manager`](project-manager/) — Use when you need to establish project plans, track execution progress, manage risks, control budget/schedule, and coordinate stakeholders a
- [`sales-engineer`](sales-engineer/) — Use when you need to conduct technical pre-sales activities including solution architecture, proof-of-concept development, and technical dem
- [`technical-writer`](technical-writer/) — Use when you need to create, improve, or maintain technical documentation including API references, user guides, SDK documentation, and gett
- [`wordpress-master`](wordpress-master/) — Use when you need to architect, optimize, or troubleshoot WordPress implementations ranging from custom theme/plugin development to enterpri

## Codebase & Build &nbsp;`codebase-build` (9)

Understand, review, debug, and build a codebase (the implement/tdd loop).

- [`code-review`](code-review/) — Two-axis review of the working diff since a fixed point — Standards (does it follow this repo's coding standards + a code-smell baseline?) a
- [`codebase-churn`](codebase-churn/) — Analyze a git repository's history and produce an SVG treemap of file churn — area = lines changed, color = commit frequency.
- [`codebase-design`](codebase-design/) — Shared vocabulary and principles for designing deep modules — a lot of behaviour behind a small interface, placed at a clean seam.
- [`codebase-explain`](codebase-explain/) — Tell the agent to explain code with broader context and a higher-level perspective.
- [`codebase-improve-architecture`](codebase-improve-architecture/) — Find deepening opportunities in a codebase, informed by the domain language in CONTEXT.md and the decisions in docs/adr/.
- [`codebase-plan-refactor`](codebase-plan-refactor/) — Create a detailed refactor plan with tiny commits via user interview, then file it as an issue.
- [`debug`](debug/) — Diagnosis loop for hard bugs and performance regressions.
- [`implement`](implement/) — Build a piece of work (ticket, spec, or free-form request) through a tunable pipeline — test-first, verify, review, and track — where every 
- [`tdd`](tdd/) — Test-driven development — the red → green loop and the rules that make its tests worth keeping.

## Core Development &nbsp;`core-development` (11)

Full-stack, backend, frontend, mobile, API, and architecture builders.

- [`api-designer`](api-designer/) — Use when designing new APIs, creating API specifications, or refactoring existing API architecture for scalability and developer experience.
- [`backend-developer`](backend-developer/) — Use when building server-side APIs, microservices, and backend systems that require robust architecture, scalability planning, and productio
- [`design-bridge`](design-bridge/) — Use when you need to translate a DESIGN.md into polished Claude Code instructions for building user interfaces that faithfully match the cho
- [`electron-pro`](electron-pro/) — Use when building Electron desktop applications that require native OS integration, cross-platform distribution, security hardening, and per
- [`frontend-developer`](frontend-developer/) — Use when building complete frontend applications across React, Vue, and Angular frameworks requiring multi-framework expertise and full-stac
- [`fullstack-developer`](fullstack-developer/) — Use when you need to build complete features spanning database, API, and frontend layers together as a cohesive unit.
- [`graphql-architect`](graphql-architect/) — Use when designing or evolving GraphQL schemas across microservices, implementing federation architectures, or optimizing query performance 
- [`microservices-architect`](microservices-architect/) — Use when designing distributed system architecture, decomposing monolithic applications into independent microservices, or establishing comm
- [`mobile-developer`](mobile-developer/) — Use when building cross-platform mobile applications requiring native performance optimization, platform-specific features, and offline-firs
- [`ui-designer`](ui-designer/) — Use when designing visual interfaces, creating design systems, building component libraries, or refining user-facing aesthetics requiring ex
- [`websocket-engineer`](websocket-engineer/) — Use when implementing real-time bidirectional communication features using WebSockets, Socket.IO, or similar technologies at scale.

## Data & AI &nbsp;`data-ai` (11)

Data engineering, ML, AI, analytics, and LLM work.

- [`ai-engineer`](ai-engineer/) — Use when architecting, implementing, or optimizing end-to-end AI systems—from model selection and training pipelines to production deploymen
- [`data-analyst`](data-analyst/) — Use when you need to extract insights from business data, create dashboards and reports, or perform statistical analysis to support decision
- [`data-engineer`](data-engineer/) — Use when you need to design, build, or optimize data pipelines, ETL/ELT processes, and data infrastructure.
- [`data-scientist`](data-scientist/) — Use when you need to analyze data patterns, build predictive models, or extract statistical insights from datasets.
- [`database-optimizer`](database-optimizer/) — Use when you need to analyze slow queries, optimize database performance across multiple systems, or implement indexing strategies to improv
- [`llm-architect`](llm-architect/) — Use when designing LLM systems for production, implementing fine-tuning or RAG architectures, optimizing inference serving infrastructure, o
- [`ml-engineer`](ml-engineer/) — Use when building production ML systems requiring model training pipelines, model serving infrastructure, performance optimization, and auto
- [`nlp-engineer`](nlp-engineer/) — Use when building production NLP systems, implementing text processing pipelines, developing language models, or solving domain-specific NLP
- [`postgres-pro`](postgres-pro/) — Use when you need to optimize PostgreSQL performance, design high-availability replication, or troubleshoot database issues at scale.
- [`prompt-engineer`](prompt-engineer/) — Use when you need to design, optimize, test, or evaluate prompts for large language models in production systems.
- [`reinforcement-learning-engineer`](reinforcement-learning-engineer/) — Use when designing RL environments, training agents with reward optimization, implementing policy gradient methods, or deploying decision-ma

## Developer Experience &nbsp;`developer-experience` (18)

Tooling, build, CLI, docs, refactoring, and Git workflow.

- [`branch-rebase`](branch-rebase/) — Safely rebase the current branch onto its upstream target (baseline, main, or master).
- [`branch-resolve-conflicts`](branch-resolve-conflicts/) — Resolve complex git merge/rebase conflicts by reconstructing intent, preserving both branches' goals when possible, and running automated ch
- [`build-engineer`](build-engineer/) — Use when you need to optimize build performance, reduce compilation times, or scale build systems across growing teams.
- [`cli-developer`](cli-developer/) — Use when building command-line tools and terminal applications that require intuitive command design, cross-platform compatibility, and opti
- [`dependency-manager`](dependency-manager/) — Use when you need to audit dependencies for vulnerabilities, resolve version conflicts, optimize bundle sizes, or implement automated depend
- [`documentation-engineer`](documentation-engineer/) — Use when you need to create, architect, or overhaul comprehensive documentation systems including API docs, tutorials, guides, and developer
- [`dx-optimizer`](dx-optimizer/) — Use when optimizing the complete developer workflow including build times, feedback loops, testing efficiency, and developer satisfaction me
- [`git-workflow-manager`](git-workflow-manager/) — Use when you need to design, establish, or optimize Git workflows, branching strategies, and merge management for a project or team.
- [`legacy-modernizer`](legacy-modernizer/) — Use when modernizing legacy systems that need incremental migration strategies, technical debt reduction, and risk mitigation while maintain
- [`mcp-developer`](mcp-developer/) — Use when you need to build, debug, or optimize Model Context Protocol (MCP) servers and clients that connect AI systems to external tools an
- [`powershell-module-architect`](powershell-module-architect/) — Use when architecting and refactoring PowerShell modules, designing profile systems, or creating cross-version compatible automation librari
- [`powershell-ui-architect`](powershell-ui-architect/) — Use when designing or building desktop graphical interfaces (WinForms, WPF, Metro-style dashboards) or terminal user interfaces (TUIs) for P
- [`readme-generator`](readme-generator/) — Write, overhaul, or review a project README that is accurate to the repository and easy for a human to read — deep codebase scan for exact
- [`refactoring-specialist`](refactoring-specialist/) — Use when you need to transform poorly structured, complex, or duplicated code into clean, maintainable systems while preserving all existing
- [`slack-expert`](slack-expert/) — Use when developing Slack applications, implementing Slack API integrations, or reviewing Slack bot code for security and best practices.
- [`tooling-engineer`](tooling-engineer/) — Use when you need to build or enhance developer tools including CLIs, code generators, build tools, and IDE extensions.
- [`visual-asset-generator`](visual-asset-generator/) — Use when you need to generate production-ready visual assets for a project — app icons, favicons, OG images, logos, wordmarks, or social med
- [`wizard`](wizard/) — Generate an interactive bash wizard that walks a human step by step through a manual procedure.

## Executive Function &nbsp;`exec-function` (14)

Neurodivergent-friendly executive-function support.

- [`break-it-down`](break-it-down/) — Decode messages into plain language with tone and intent analysis.
- [`daily-briefing`](daily-briefing/) — Personal daily briefing assistant.
- [`energy-budget`](energy-budget/) — Log today's load (meetings, sensory stuff, social events, deep work); skill scores the load, warns when the day is heading toward burnout, a
- [`hyperfocus-exit`](hyperfocus-exit/) — Stop a deep work session on purpose without losing the thread — captures what is only in your head, writes a park file, and drops a PARKED br
- [`hyperfocus-recovery`](hyperfocus-recovery/) — Reconstruct context after a deep session or interruption — "what was I doing?" Reads recent git diff, modified files, open editors, and last
- [`i-am-autistic`](i-am-autistic/) — Shape every response for an autistic reader — say the thing directly, label whether an instruction is required or optional, keep language lit
- [`i-have-adhd`](i-have-adhd/) — Shape every response for a reader with ADHD — lead with the next action, number multi-step work, restate progress state each turn, hold one t
- [`interest-capture`](interest-capture/) — Quick dump for the current hyperfixation so it doesn't derail today's work but also isn't lost.
- [`meeting-decompression`](meeting-decompression/) — Dump what happened in a meeting; skill separates facts from feelings, flags action items, and notes social ambiguities to follow up on (inst
- [`overwhelm-triage`](overwhelm-triage/) — Take an unstructured dump of everything competing for attention and return exactly one thing to do now, with the rest explicitly parked and
- [`rejection-sensitivity-check`](rejection-sensitivity-check/) — Paste a message that stung; get a calibrated read on whether it's actually critical or neutral-but-terse.
- [`task-initiation`](task-initiation/) — You know what to do but can't start.
- [`time-reality-check`](time-reality-check/) — Counter time blindness — you say "20 minutes" but it'll take 2 hours.
- [`wait-what`](wait-what/) — Fire this the moment a message doesn't land — the agent re-pitches it in plain language with the context you were missing.

## Infrastructure &nbsp;`infrastructure` (16)

DevOps, cloud, containers, networking, databases, and incident response.

- [`azure-infra-engineer`](azure-infra-engineer/) — Use when designing, deploying, or managing Azure infrastructure with focus on network architecture, Entra ID integration, PowerShell automat
- [`cloud-architect`](cloud-architect/) — Use when you need to design, evaluate, or optimize cloud infrastructure architecture at scale.
- [`database-administrator`](database-administrator/) — Use when optimizing database performance, implementing high-availability architectures, setting up disaster recovery, or managing database i
- [`deployment-engineer`](deployment-engineer/) — Use when designing, building, or optimizing CI/CD pipelines and deployment automation strategies.
- [`devops-engineer`](devops-engineer/) — Use when building or optimizing infrastructure automation, CI/CD pipelines, containerization strategies, and deployment workflows to acceler
- [`devops-incident-responder`](devops-incident-responder/) — Use when actively responding to production incidents, diagnosing critical service failures, or conducting incident postmortems to implement 
- [`docker-expert`](docker-expert/) — Use when you need to build, optimize, or secure Docker container images and orchestration for production environments.
- [`incident-responder`](incident-responder/) — Use when an active security breach, service outage, or operational incident requires immediate response, evidence preservation, and coordina
- [`kubernetes-specialist`](kubernetes-specialist/) — Use when you need to design, deploy, configure, or troubleshoot Kubernetes clusters and workloads in production environments.
- [`network-engineer`](network-engineer/) — Use when designing, optimizing, or troubleshooting cloud and hybrid network infrastructures, or when addressing network security, performanc
- [`platform-engineer`](platform-engineer/) — Use when building or improving internal developer platforms (IDPs), designing self-service infrastructure, or optimizing developer workflows
- [`security-engineer`](security-engineer/) — Use when implementing comprehensive security solutions across infrastructure, building automated security controls into CI/CD pipelines, or 
- [`sre-engineer`](sre-engineer/) — Use when you need to establish or improve system reliability through SLO definition, error budget management, and automation.
- [`terraform-engineer`](terraform-engineer/) — Use when building, refactoring, or scaling infrastructure as code using Terraform with focus on multi-cloud deployments, module architecture
- [`terragrunt-expert`](terragrunt-expert/) — Expert Terragrunt specialist mastering infrastructure orchestration, DRY configurations, and multi-environment deployments.
- [`windows-infra-admin`](windows-infra-admin/) — Use when managing Windows Server infrastructure, Active Directory, DNS, DHCP, and Group Policy configurations, especially for enterprise-sca

## Language Specialists &nbsp;`language-specialists` (33)

Language- and framework-specific experts.

- [`angular-architect`](angular-architect/) — Use when architecting enterprise Angular 15+ applications with complex state management, optimizing RxJS patterns, designing micro-frontend 
- [`ansible-expert`](ansible-expert/) — Use when building infrastructure automation, configuration management, and orchestration with Ansible.
- [`cpp-pro`](cpp-pro/) — Use when building high-performance C++ systems requiring modern C++20/23 features, template metaprogramming, or zero-overhead abstractions f
- [`csharp-developer`](csharp-developer/) — Use when building ASP.NET Core web APIs, cloud-native .NET solutions, or modern C# applications requiring async patterns, dependency injecti
- [`django-developer`](django-developer/) — Use when building Django 4+ web applications, REST APIs, or modernizing existing Django projects with async views and enterprise patterns.
- [`dotnet-core-expert`](dotnet-core-expert/) — Use when building .NET Core applications requiring cloud-native architecture, high-performance microservices, modern C# patterns, or cross-p
- [`dotnet-framework-4.8-expert`](dotnet-framework-4.8-expert/) — Use when working on legacy .NET Framework 4.8 enterprise applications that require maintenance, modernization, or integration with Windows-b
- [`elixir-expert`](elixir-expert/) — Use when you need to build fault-tolerant, concurrent systems leveraging OTP patterns, GenServer architectures, and Phoenix framework for re
- [`expo-react-native-expert`](expo-react-native-expert/) — Use when building mobile applications with Expo and React Native that require native module integration, navigation setup, performant animat
- [`fastapi-developer`](fastapi-developer/) — Use when building modern async Python APIs with FastAPI, implementing Pydantic v2 validation, dependency injection patterns, or deploying hi
- [`flutter-expert`](flutter-expert/) — Use when building cross-platform mobile applications with Flutter 3+ that require custom UI implementation, complex state management, native
- [`golang-pro`](golang-pro/) — Use when building Go applications requiring concurrent programming, high-performance systems, microservices, or cloud-native architectures w
- [`gradle-expert`](gradle-expert/) — Use when building and configuring Gradle projects, optimizing build performance, managing dependencies, implementing multi-module architectu
- [`java-architect`](java-architect/) — Use when designing enterprise Java architectures, migrating Spring Boot applications, or establishing microservices patterns for scalable cl
- [`javascript-pro`](javascript-pro/) — Use when you need to build, optimize, or refactor modern JavaScript code for browser, Node.js, or full-stack applications requiring ES2023+ 
- [`kotlin-specialist`](kotlin-specialist/) — Use when building Kotlin applications requiring advanced coroutine patterns, multiplatform code sharing, or Android/server-side development 
- [`laravel-specialist`](laravel-specialist/) — Use when building Laravel 10+ applications, architecting Eloquent models with complex relationships, implementing queue systems for async pr
- [`nextjs-developer`](nextjs-developer/) — Use when building production Next.js 14+ applications that require full-stack development with App Router, server components, and advanced p
- [`node-specialist`](node-specialist/) — Use when you need to build, optimize, or debug Node.js backend applications, APIs, CLIs, or microservices requiring deep ecosystem knowledge
- [`php-pro`](php-pro/) — Use when working with PHP 8.3+ projects that require strict typing, modern language features, and enterprise framework expertise (Laravel or
- [`powershell-5.1-expert`](powershell-5.1-expert/) — Use when automating Windows infrastructure tasks requiring PowerShell 5.1 scripts with RSAT modules for Active Directory, DNS, DHCP, GPO man
- [`powershell-7-expert`](powershell-7-expert/) — Use when building cross-platform cloud automation scripts, Azure infrastructure orchestration, or CI/CD pipelines requiring PowerShell 7+ wi
- [`python-pro`](python-pro/) — Use when you need to build type-safe, production-ready Python code for web APIs, system utilities, or complex applications requiring modern 
- [`rails-expert`](rails-expert/) — Use when building or modernizing Rails applications requiring API development, Hotwire reactivity, real-time features, background job proces
- [`react-specialist`](react-specialist/) — Use when optimizing existing React applications for performance, implementing advanced React 18+ features, or solving complex state manageme
- [`rust-engineer`](rust-engineer/) — Use when building Rust systems where memory safety, ownership patterns, zero-cost abstractions, and performance optimization are critical fo
- [`shell-expert`](shell-expert/) — Use when building shell scripts for system administration, automation, and DevOps.
- [`spring-boot-engineer`](spring-boot-engineer/) — Use when building enterprise Spring Boot 3+ applications requiring microservices architecture, cloud-native deployment, or reactive programm
- [`sql-pro`](sql-pro/) — Use when you need to optimize complex SQL queries, design efficient database schemas, or solve performance issues across PostgreSQL, MySQL, 
- [`swift-expert`](swift-expert/) — Use when building native iOS, macOS, or server-side Swift applications requiring advanced concurrency patterns, protocol-oriented architectu
- [`symfony-specialist`](symfony-specialist/) — Use when building Symfony 6+/7+/8+ applications, architecting Doctrine ORM entities with complex relationships, implementing Messenger compo
- [`typescript-pro`](typescript-pro/) — Use when implementing TypeScript code requiring advanced type system patterns, complex generics, type-level programming, or end-to-end type 
- [`vue-expert`](vue-expert/) — Use when building Vue 3 applications that require Composition API mastery, reactivity optimization, or Nuxt 3 development with enterprise-sc

## Meta-Orchestration &nbsp;`meta-orchestration` (22)

Multi-agent coordination, planning, and the plan→spec→tickets build pipeline.

- [`agent-installer`](agent-installer/) — Use when the user wants to discover, browse, or install Claude Code agents from the subagent repository.
- [`agent-organizer`](agent-organizer/) — Use when assembling and optimizing multi-agent teams to execute complex projects that require careful task decomposition, agent capability m
- [`codebase-orchestrator`](codebase-orchestrator/) — Use when you need repository-wide refactor governance with explicit approval loops, weighted risk prioritization, diff previews, and determi
- [`context-manager`](context-manager/) — Use for managing shared state, information retrieval, and data synchronization when multiple agents need coordinated access to context and m
- [`defuddle`](defuddle/) — Extract clean markdown content from web pages using Defuddle CLI, removing clutter and navigation to save tokens.
- [`error-coordinator`](error-coordinator/) — Use when distributed system errors occur and need coordinated handling across multiple components, or when you need to implement comprehensi
- [`handoff`](handoff/) — Compact the current conversation into a handoff document for another agent to pick up.
- [`it-ops-orchestrator`](it-ops-orchestrator/) — Use for orchestrating complex IT operations tasks that span multiple domains (PowerShell automation, .NET development, infrastructure manage
- [`knowledge-synthesizer`](knowledge-synthesizer/) — Use when you need to extract actionable patterns from agent interactions, synthesize insights across multiple workflows, and enable organiza
- [`multi-agent-coordinator`](multi-agent-coordinator/) — Use when coordinating multiple concurrent agents that need to communicate, share state, synchronize work, and handle distributed failures ac
- [`performance-monitor`](performance-monitor/) — Use when establishing observability infrastructure to track system metrics, detect performance anomalies, and optimize resource usage across
- [`plan-to-questionnaire`](plan-to-questionnaire/) — Turn a decision you can't answer alone into a Markdown questionnaire for the one person who can.
- [`plan-to-spec`](plan-to-spec/) — Synthesize the current conversation into a spec (PRD) and stage it as a local file.
- [`plan-to-tickets`](plan-to-tickets/) — Break a spec, plan, or the current conversation into a local, numbered, spec-kit-style task list of tracer-bullet vertical slices with expli
- [`prototype`](prototype/) — Build a throwaway prototype to answer a design question.
- [`research`](research/) — Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo.
- [`skill-create`](skill-create/) — Create new agent skills with proper structure, progressive disclosure, and bundled resources.
- [`task-distributor`](task-distributor/) — Use when distributing tasks across multiple agents or workers, managing queues, and balancing workloads to maximize throughput while respect
- [`teach`](teach/) — Teach the user a new skill or concept, within this workspace.
- [`work-plan`](work-plan/) — Plan a huge chunk of work — more than one agent session can hold — as a shared map of decision tickets on your issue tracker, and resolve th
- [`workflow-orchestrator`](workflow-orchestrator/) — Use when you need to design, implement, or optimize complex business process workflows with multiple states, error handling, and transaction
- [`writing-for-agents`](writing-for-agents/) — Reference for writing any document an agent consumes — a skill, an AGENTS.md or CLAUDE.md, a doc reached by a pointer.

## Obsidian &nbsp;`obsidian` (6)

Read/write and structure an Obsidian vault.

- [`obsidian-bases`](obsidian-bases/) — Create and edit Obsidian Bases (.base files) with views, filters, formulas, and summaries.
- [`obsidian-canvas`](obsidian-canvas/) — Create and edit Obsidian Canvas files (.canvas) following the JSON Canvas spec — nodes, edges, groups, and connections.
- [`obsidian-charts`](obsidian-charts/) — Build interactive charts in Obsidian notes using the Charts plugin (phibr0/obsidian-charts).
- [`obsidian-cli`](obsidian-cli/) — Interact with Obsidian vaults using the Obsidian CLI to read, create, search, and manage notes, tasks, properties, and more.
- [`obsidian-markdown`](obsidian-markdown/) — Create and edit Obsidian Flavored Markdown with wikilinks, embeds, callouts, properties, and other Obsidian-specific syntax.
- [`obsidian-vault`](obsidian-vault/) — Search, create, and manage notes in the Obsidian vault with wikilinks and index notes.

## Quality & Security &nbsp;`quality-security` (92)

Testing, security auditing, compliance, and performance.

- [`accessibility-tester`](accessibility-tester/) — Use when you need comprehensive accessibility testing, WCAG compliance verification, or assessment of assistive technology support.
- [`ad-security-reviewer`](ad-security-reviewer/) — Use when you need to audit Active Directory security posture, evaluate privilege escalation risks, review identity delegation patterns, or a
- [`ai-writing-auditor`](ai-writing-auditor/) — Use when you need to audit content for AI writing patterns and rewrite text to remove them.
- [`chaos-engineer`](chaos-engineer/) — Use when you need to design and execute controlled failure experiments, validate system resilience before incidents occur, or conduct game d
- [`compliance-auditor`](compliance-auditor/) — Use when you need to achieve regulatory compliance, implement compliance controls, or prepare for audits across frameworks like GDPR, HIPAA,
- [`debugger`](debugger/) — Use when you need to diagnose and fix bugs, identify root causes of failures, or analyze error logs and stack traces to resolve issues.
- [`error-detective`](error-detective/) — Use when you need to diagnose why errors are occurring in your system, correlate errors across services, identify root causes, and prevent f
- [`gdpr-ccpa-compliance`](gdpr-ccpa-compliance/) — Use when the user needs to understand GDPR or CCPA compliance, review data practices, or assess privacy requirements.
- [`offensive-active-directory`](offensive-active-directory/) — Active Directory attack methodology for internal network red team engagements. Covers reconnaissance (BloodHound, PowerView, ADExplorer),
- [`offensive-advanced-redteam`](offensive-advanced-redteam/) — Comprehensive red team operations methodology covering full engagement lifecycle from planning through reporting. Addresses engagement scoping
- [`offensive-ai-security`](offensive-ai-security/) — AI/LLM security offensive checklist: prompt injection, jailbreaking, model extraction, training data poisoning, adversarial inputs, LLM-assisted
- [`offensive-anti-forensics`](offensive-anti-forensics/) — Anti-forensics and evidence destruction techniques for red team operators conducting authorized engagements. Covers log clearing on Windows
- [`offensive-api-abuse`](offensive-api-abuse/) — Advanced API exploitation methodology focused on business logic abuse and sophisticated attack patterns that bypass traditional security
- [`offensive-api-security`](offensive-api-security/) — Comprehensive API security testing methodology covering REST, gRPC, and WebSocket attack surfaces. Addresses the full OWASP API Security Top 10
- [`offensive-basic-exploitation`](offensive-basic-exploitation/) — Week 5 exploit development curriculum. Foundational exploitation techniques: controlling EIP/RIP, ROP chain construction, ret2libc, shellcode
- [`offensive-bluetooth-ble`](offensive-bluetooth-ble/) — Bluetooth Low Energy (BLE) attack methodology — GATT enumeration, characteristic read/write without auth, pairing downgrade (Just Works forced),
- [`offensive-bluetooth-classic`](offensive-bluetooth-classic/) — Bluetooth Classic (BR/EDR) attack methodology — device discovery, service enumeration via SDP, LMP/L2CAP layer attacks, legacy PIN cracking
- [`offensive-bug-identification`](offensive-bug-identification/) — Systematic bug identification methodology: source code review patterns, black-box testing strategies, taint analysis, dangerous function
- [`offensive-business-logic`](offensive-business-logic/) — Business logic vulnerability testing for web/mobile/API engagements. Covers workflow bypass, state machine violations, multi-step process abuse,
- [`offensive-c2-frameworks`](offensive-c2-frameworks/) — Command and Control framework deployment, configuration, and operational tradecraft for red team engagements. Covers Cobalt Strike (malleable C2
- [`offensive-cicd-pipeline`](offensive-cicd-pipeline/) — Comprehensive CI/CD pipeline exploitation methodology covering GitHub Actions injection vectors (expression injection via PR titles and issue
- [`offensive-cicd-secrets`](offensive-cicd-secrets/) — Comprehensive secrets extraction methodology targeting CI/CD environments across all major platforms. Covers environment variable extraction
- [`offensive-cloud`](offensive-cloud/) — Cloud security attack methodology covering AWS, Azure, and GCP. Includes credential harvesting (IMDS, ~/.aws, env vars, leaked CI secrets,
- [`offensive-container-escape`](offensive-container-escape/) — Container escape and breakout techniques targeting Docker, containerd, and Podman runtimes. Covers privileged container breakout via host
- [`offensive-crash-analysis`](offensive-crash-analysis/) — Week 4 exploit development curriculum. Crash triage and analysis methodology: WinDbg/GDB analysis, ASAN/MSAN output interpretation,
- [`offensive-crypto-attacks`](offensive-crypto-attacks/) — Systematic methodology for identifying and exploiting cryptographic implementation weaknesses in real-world applications. Covers padding oracle
- [`offensive-data-exfiltration`](offensive-data-exfiltration/) — Dense methodology covering DNS exfiltration (dnscat2, iodine, dns2tcp), HTTPS tunneling (domain fronting, CDN abuse, legitimate service
- [`offensive-deauth-disassoc`](offensive-deauth-disassoc/) — Deauthentication and disassociation attacks against 802.11 networks — targeted single-client deauth for handshake capture, broadcast deauth for
- [`offensive-dependency-confusion`](offensive-dependency-confusion/) — Deep-dive offensive methodology for dependency confusion and namespace attacks across all major package ecosystems. Covers npm scope confusion
- [`offensive-deserialization`](offensive-deserialization/) — Insecure deserialization exploitation across Java, PHP, .NET, Python, Node.js, and Ruby. Covers gadget chain construction with
- [`offensive-edr-evasion`](offensive-edr-evasion/) — EDR evasion offensive checklist: hook unhooking (user/kernel), direct syscalls, PPID spoofing, process injection variants, AMSI bypass, ETW
- [`offensive-evil-twin`](offensive-evil-twin/) — Evil Twin / KARMA / Mana access point methodology — rogue AP construction with hostapd-mana / wifiphisher / airgeddon, KARMA universal probe
- [`offensive-exploit-dev-course`](offensive-exploit-dev-course/) — Full exploit development course roadmap and syllabus: weekly topics, recommended reading, lab setup, and learning path from vulnerability
- [`offensive-exploit-development`](offensive-exploit-development/) — Exploit development operational guide: environment setup, debugging workflow, PoC development lifecycle, writing reliable exploits, using
- [`offensive-fast-checking`](offensive-fast-checking/) — Speed-optimized offensive checklist for rapid assessment: quick-win vulnerability patterns, fast recon shortcuts, automated scanner
- [`offensive-file-upload`](offensive-file-upload/) — File upload vulnerability checklist: MIME type bypass, extension bypass, magic byte manipulation, path traversal in filenames, stored XSS via
- [`offensive-fuzzing`](offensive-fuzzing/) — Practical offensive fuzzing methodology covering target identification, fuzzer selection (AFL++, libFuzzer, Honggfuzz, Boofuzz, syzkaller),
- [`offensive-fuzzing-course`](offensive-fuzzing-course/) — Week 2 of the exploit development curriculum. Covers fuzzing methodology: target selection, corpus generation, coverage-guided fuzzing with
- [`offensive-graphql`](offensive-graphql/) — Offensive methodology for attacking GraphQL APIs during penetration tests and bug bounty engagements. Covers the full attack lifecycle: endpoint
- [`offensive-idor`](offensive-idor/) — IDOR (Insecure Direct Object Reference) testing checklist: object ID enumeration, horizontal/vertical privilege escalation, GUID predictability,
- [`offensive-initial-access`](offensive-initial-access/) — Initial access techniques checklist: phishing (spear/smishing), credential stuffing, exposed service exploitation, supply chain attacks,
- [`offensive-iot`](offensive-iot/) — IoT and embedded device security testing methodology. Covers hardware reconnaissance (UART, JTAG, SWD, SPI flash, I2C EEPROM, eMMC chip-off),
- [`offensive-jwt`](offensive-jwt/) — JWT attack methodology for penetration testers. Covers algorithm confusion (alg:none, RS256→HS256), weak HMAC secret brute force, kid parameter
- [`offensive-k8s-attacks`](offensive-k8s-attacks/) — Kubernetes cluster attack techniques covering the full attack lifecycle from initial foothold in a pod to cluster-wide compromise. Covers
- [`offensive-keylogger-arch`](offensive-keylogger-arch/) — Low-level keylogger architecture design: kernel driver hooks (WH_KEYBOARD_LL, SetWindowsHookEx), ETW-based input capture, user-mode vs
- [`offensive-krack-fragattacks`](offensive-krack-fragattacks/) — KRACK (CVE-2017-13077..082) and FragAttacks (CVE-2020-24586..588 + 26139-26147) — key reinstallation, fragmentation, and aggregation attacks
- [`offensive-lateral-movement`](offensive-lateral-movement/) — Comprehensive lateral movement tradecraft for authorized red team engagements covering credential-based movement (pass-the-hash,
- [`offensive-linux-privesc`](offensive-linux-privesc/) — Comprehensive Linux privilege escalation methodology for offensive security engagements. Covers the full attack surface from a low-privilege
- [`offensive-lorawan-sub-ghz`](offensive-lorawan-sub-ghz/) — LoRaWAN and sub-GHz (433 / 868 / 915 MHz) attack methodology — LoRaWAN ABP/OTAA join attack, network/session key reuse, frame counter replay,
- [`offensive-mitigations`](offensive-mitigations/) — Security mitigation reference and bypass catalog: ASLR, DEP/NX, RELRO, stack canaries, CFI, sandboxing, seccomp. Covers both detection of
- [`offensive-mobile`](offensive-mobile/) — Mobile (Android + iOS) application penetration testing methodology. Covers static analysis (apktool/jadx for Android, class-dump/Hopper/IDA for
- [`offensive-network-attacks`](offensive-network-attacks/) — Dense description covering ARP spoofing, LLMNR/NBT-NS/mDNS poisoning, DNS poisoning, MITM attacks, VLAN hopping, DHCP attacks, 802.1X/NAC
- [`offensive-oauth`](offensive-oauth/) — OAuth 2.0 attack checklist: authorization code interception, redirect_uri bypass, CSRF on OAuth flow, state parameter abuse, open redirector
- [`offensive-open-redirect`](offensive-open-redirect/) — Open redirect vulnerability checklist: parameter identification, bypass techniques (URL encoding, double slashes, CRLF injection, protocol
- [`offensive-osint`](offensive-osint/) — Comprehensive OSINT methodology skill for offensive security, red team intelligence gathering, and bug bounty reconnaissance. Covers domain
- [`offensive-osint-methodology`](offensive-osint-methodology/) — Structured OSINT methodology framework: target definition, source selection, collection workflows, data correlation, timeline reconstruction,
- [`offensive-parameter-pollution`](offensive-parameter-pollution/) — HTTP parameter pollution (HPP) checklist: duplicate parameter injection, backend vs frontend parsing differences, WAF bypass via HPP,
- [`offensive-persistence`](offensive-persistence/) — Comprehensive persistence tradecraft for authorized red team engagements covering Windows and Linux mechanisms. Windows techniques include
- [`offensive-phishing`](offensive-phishing/) — Phishing campaign execution methodology for authorized red team engagements. Covers end-to-end campaign lifecycle: infrastructure provisioning
- [`offensive-race-condition`](offensive-race-condition/) — Race condition (TOCTOU) testing checklist: identifying timing windows, Burp Suite Turbo Intruder, Last-Byte sync technique, rate limit bypass,
- [`offensive-rce`](offensive-rce/) — Remote Code Execution testing checklist: OS command injection, SSTI-to-RCE, deserialization RCE, file upload RCE, XXE with SSRF to RCE, RCE via
- [`offensive-reporting`](offensive-reporting/) — Penetration test and red team report writing methodology. Covers executive summary structuring (risk-led narrative for non-technical readers),
- [`offensive-request-smuggling`](offensive-request-smuggling/) — HTTP request smuggling checklist: CL.TE, TE.CL, TE.TE variants, detection with timing and differential responses, WAF bypass, cache poisoning,
- [`offensive-shellcode`](offensive-shellcode/) — Shellcode development reference for offensive security engagements. Use when writing custom x86/x64 shellcode, implementing position-independent
- [`offensive-social-engineering`](offensive-social-engineering/) — Social engineering attack techniques beyond email phishing for authorized red team and physical penetration testing engagements. Covers
- [`offensive-sqli`](offensive-sqli/) — SQL injection testing skill for offensive security assessments and bug bounty hunting. Covers error-based, UNION-based, boolean/time-based
- [`offensive-ssrf`](offensive-ssrf/) — Server-Side Request Forgery testing checklist: SSRF discovery, blind SSRF with out-of-band, cloud metadata endpoints (AWS/GCP/Azure), SSRF
- [`offensive-ssti`](offensive-ssti/) — Dense description covering Server-Side Template Injection across Jinja2, Twig, Freemarker, Velocity, Pebble, Smarty, Mako, Handlebars, ERB,
- [`offensive-supply-chain`](offensive-supply-chain/) — Comprehensive offensive methodology for software supply chain attacks covering the full kill chain from reconnaissance through exploitation.
- [`offensive-tls-attacks`](offensive-tls-attacks/) — Comprehensive methodology for auditing and exploiting TLS/SSL implementations and misconfigurations across network services and mobile
- [`offensive-toctou`](offensive-toctou/) — Time-of-Check / Time-of-Use (TOCTOU) race condition exploitation methodology across binary, kernel, filesystem, web, and container layers.
- [`offensive-vuln-classes`](offensive-vuln-classes/) — Exploit development curriculum covering core vulnerability classes with real-world CVE case studies: stack/heap buffer overflows,
- [`offensive-waf-bypass`](offensive-waf-bypass/) — WAF bypass techniques checklist: encoding bypass (URL/HTML/Unicode/double encoding), case variation, comment injection, HTTP header
- [`offensive-wifi`](offensive-wifi/) — Wireless / 802.11 attack methodology for red team engagements and wireless security assessments. Covers monitor-mode setup, WPA/WPA2-PSK
- [`offensive-wifi-recon`](offensive-wifi-recon/) — Wi-Fi reconnaissance methodology — adapter selection, monitor mode and packet injection setup, regulatory domain handling, multi-band airspace
- [`offensive-windows-boundaries`](offensive-windows-boundaries/) — Windows security boundary taxonomy and attack surface enumeration: kernel/user boundary, sandbox boundaries (LPAC, AppContainer), COM/RPC
- [`offensive-windows-mitigations`](offensive-windows-mitigations/) — Deep-dive on Windows exploit mitigations: ASLR, DEP/NX, CFG, CET/Shadow Stack, SEHOP, Heap Guard, ACG, Arbitrary Code Guard. Covers both the
- [`offensive-windows-privesc`](offensive-windows-privesc/) — Comprehensive Windows privilege escalation methodology for offensive security engagements. Covers the full attack surface from a standard user
- [`offensive-wpa-enterprise`](offensive-wpa-enterprise/) — WPA/WPA2/WPA3-Enterprise (802.1X / EAP) attack methodology — EAP method identification (PEAP-MSCHAPv2, EAP-TTLS, EAP-TLS, EAP-GTC, EAP-PWD,
- [`offensive-wpa2-psk`](offensive-wpa2-psk/) — WPA/WPA2-PSK attack methodology — four-way handshake capture via targeted deauthentication, PMKID attacks (no client required), hcxdumptool /
- [`offensive-wpa3-sae`](offensive-wpa3-sae/) — WPA3 / SAE (Simultaneous Authentication of Equals) attack methodology — transition-mode (mixed WPA2/WPA3) downgrade, Dragonblood side-channel
- [`offensive-wps`](offensive-wps/) — WPS (Wi-Fi Protected Setup) PIN attack methodology — Pixie Dust offline attack against vulnerable chipsets (Ralink, Realtek, Broadcom,
- [`offensive-xss`](offensive-xss/) — Cross-Site Scripting testing checklist: stored/reflected/DOM/blind XSS discovery, polyglot payloads, CSP bypass, XSS filter bypass, event
- [`offensive-xxe`](offensive-xxe/) — XML External Entity injection testing checklist: classic XXE, blind XXE (out-of-band), XXE via file upload (SVG/docx), XXE in SOAP/REST,
- [`offensive-z-wave`](offensive-z-wave/) — Z-Wave attack methodology — sniffing with Z-Force / EZ-Wave / RTL-SDR + ZniffMobile, S0 (legacy) network-key derivation flaw and key reuse, S2
- [`offensive-zigbee-thread-matter`](offensive-zigbee-thread-matter/) — Zigbee, Thread, and Matter mesh-protocol attack methodology — IEEE 802.15.4 sniffing with TI CC2531 / CC2540 / Sonoff Zigbee Dongle E, KillerBee
- [`penetration-tester`](penetration-tester/) — Use when you need to conduct authorized security penetration tests to identify real vulnerabilities through active exploitation and validati
- [`performance-engineer`](performance-engineer/) — Use when you need to identify and eliminate performance bottlenecks in applications, databases, or infrastructure systems, and when baseline
- [`powershell-security-hardening`](powershell-security-hardening/) — Use when you need to harden PowerShell automation, secure remoting configuration, enforce least-privilege design, or align scripts with ente
- [`security-audit`](security-audit/) — Security guidance and vulnerability review for codebases, APIs, services, CLI tools, libraries, and daemons. Use for security questions, foc
- [`test-automator`](test-automator/) — Use when you need to build, implement, or enhance automated test frameworks, create test scripts, or integrate testing into CI/CD pipelines.
- [`ui-ux-tester`](ui-ux-tester/) — Use when you need exhaustive UI and UX functionality testing driven by documented user flows, with browser or desktop interaction tooling an

## Research & Analysis &nbsp;`research-analysis` (12)

Research, decision support, and idea work. (The [`clarity-council`](clarity-council/) skill — which
many of these delegate to — lives at the top level; see the callout at the top of this file.)

- [`ab-test-analysis`](ab-test-analysis/) — Use when the user wants to analyze A/B test results, interpret p-values, determine statistical significance, or make a ship/no-ship decision
- [`cohort-analysis`](cohort-analysis/) — Use when the user wants to analyze retention, cohort behavior, engagement trends, or understand how different user groups perform over time.
- [`data-researcher`](data-researcher/) — Use when you need to discover, collect, and validate data from multiple sources to fuel analysis and decision-making.
- [`domain-modeling`](domain-modeling/) — Actively build and sharpen a project's domain model — challenge fuzzy terms, stress-test with scenarios, write CONTEXT.md and ADRs inline.
- [`first-principles-thinking`](first-principles-thinking/) — Use when the user wants to challenge assumptions, break down a complex problem from scratch, or approach something with first principles rea
- [`grill-me`](grill-me/) — Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree.
- [`grill-with-docs`](grill-with-docs/) — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (CONTEXT.md, A
- [`idea-choice`](idea-choice/) — Weigh one or more ideas/concepts with a structured pros-and-cons analysis.
- [`idea-decision-maker`](idea-decision-maker/) — Stuck between options.
- [`idea-generate`](idea-generate/) — Helps users generate, refine, and stress-test ideas from loose topics.
- [`search-specialist`](search-specialist/) — Use when you need to find specific information across multiple sources using advanced search strategies, query optimization, and targeted in
- [`which-skill`](which-skill/) — Router over this pack's skills and flows.

## Scrum & Sprint &nbsp;`scrum-sprint` (6)

The Scrum ceremony chain — snapshot, plan, standup, review.

- [`daily-standup-prep`](daily-standup-prep/) — Generate a per-team standup markdown report by gathering activity over the last N days from Jira, GitLab, Confluence, and a local Git repo.
- [`good-morning`](good-morning/) — Morning kickoff wrapper that runs sprint-snapshot (daily tag), daily-standup-prep (with sprint burndown), and daily-briefing (report only — 
- [`sprint-plan`](sprint-plan/) — Convert the start-of-sprint canvas into a planning markdown report — sprint goal summary, committed scope, capacity vs commitment (split int
- [`sprint-review`](sprint-review/) — End-of-sprint stakeholder report comparing the start.canvas (planning) to end.canvas (sprint close).
- [`sprint-snapshot`](sprint-snapshot/) — Capture a point-in-time snapshot of a scrum team's current sprint board from Jira and render it into the Obsidian vault as (1) an Obsidian C
- [`sprint-sos-report`](sprint-sos-report/) — End-of-week scrum-of-scrums report comparing two sprint snapshots and surfacing key findings, observations, trouble areas, and trends.

## Specialized Domains &nbsp;`specialized-domains` (11)

Vertical expertise — blockchain, IoT, fintech, gaming, healthcare, and more.

- [`api-documenter`](api-documenter/) — Use when creating or improving API documentation, writing OpenAPI specifications, building interactive documentation portals, or generating 
- [`blockchain-developer`](blockchain-developer/) — Use when building smart contracts, DApps, and blockchain protocols that require expertise in Solidity, gas optimization, security auditing, 
- [`embedded-systems`](embedded-systems/) — Use when developing firmware for resource-constrained microcontrollers, implementing RTOS-based applications, or optimizing real-time system
- [`fintech-engineer`](fintech-engineer/) — Use when building payment systems, financial integrations, or compliance-heavy financial applications that require secure transaction proces
- [`game-developer`](game-developer/) — Use when implementing game systems, optimizing graphics rendering, building multiplayer networking, or developing gameplay mechanics for gam
- [`healthcare-admin`](healthcare-admin/) — Use when working on healthcare administration tasks including revenue cycle management, HIPAA/compliance auditing, medical coding (ICD-10, C
- [`hipaa-compliance`](hipaa-compliance/) — Use when the user is building a healthcare product and needs to understand HIPAA compliance.
- [`iot-engineer`](iot-engineer/) — Use when designing and deploying IoT solutions requiring expertise in device management, edge computing, cloud integration, and handling cha
- [`m365-admin`](m365-admin/) — Use when automating Microsoft 365 administrative tasks including Exchange Online mailbox provisioning, Teams collaboration management, Share
- [`payment-integration`](payment-integration/) — Use when implementing payment systems, integrating payment gateways, or handling financial transactions that require PCI compliance, fraud p
- [`quant-analyst`](quant-analyst/) — Use when you need to develop quantitative trading strategies, build financial models with rigorous mathematical foundations, or conduct adva

## Writing &nbsp;`writing` (9)

Draft, shape, and calibrate written material.

- [`writing-apology-calibrator`](writing-apology-calibrator/) — Drafted apology in, calibrated apology out.
- [`writing-beats`](writing-beats/) — Shape an article as a journey of beats, choose-your-own-adventure style.
- [`writing-cold-open`](writing-cold-open/) — Generates the first sentence of a message or email when you can't get past the blank cursor.
- [`writing-draft-article`](writing-draft-article/) — Guide the user from raw idea, topic, or draft to a finished, polished article through relentless questioning and iterative writing.
- [`writing-fragments`](writing-fragments/) — Grilling session that mines the user for fragments — heterogeneous nuggets of writing (claims, vignettes, sharp sentences, half-thoughts) — 
- [`writing-humanize`](writing-humanize/) — Remove signs of AI-generated writing from text.
- [`writing-shape`](writing-shape/) — Take a markdown file of raw material and shape it into an article through a conversational session — drafting candidate openings, growing th
- [`writing-social-script`](writing-social-script/) — Generate a script for a specific social scenario you're dreading: declining a meeting, asking for a deadline extension, following up on sile
- [`writing-tone-check`](writing-tone-check/) — Reverse decoder — paste a draft message and get a read on how it will land before you send.

