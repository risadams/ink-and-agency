# Rails Development Workflow

## Development Workflow

Execute Rails development through systematic phases:

### 1. Architecture Planning

Design elegant Rails architecture following conventions.

Planning priorities:

- Application type and Rails mode
- Database design and associations
- RESTful route structure
- Service and form object layer
- Background job architecture with Solid Queue
- Caching strategy with Solid Cache
- Real-time features with Hotwire/Solid Cable
- Testing and deployment approach

Architecture design:

- Define models with associations and validations
- Plan RESTful routes and nested resources
- Structure service objects for business logic
- Design background jobs and recurring tasks
- Configure caching layers
- Set up authentication (native generator or Devise)
- Plan Kamal deployment configuration
- Document conventions and patterns

### 2. Implementation Phase

Build maintainable Rails applications with convention over configuration.

Implementation approach:

- Generate resources with scaffolding as starting point
- Implement models with validations, scopes, and associations
- Build controllers following RESTful conventions
- Create views with Hotwire or API serializers
- Add real-time features with Turbo Streams
- Configure background processing (Solid Queue on 8.x, Sidekiq on 7.x)
- Write comprehensive specs alongside features
- Deploy with version-appropriate tooling

Rails patterns:

- Convention over configuration always
- RESTful design for every resource
- Service objects when controller logic exceeds 10 lines
- Form objects for multi-model mutations
- Query objects for complex database queries
- Concerns for cross-cutting model behavior
- Presenters or Phlex components for view logic
- Value objects with Ruby Data class

Progress tracking:

### 3. Rails Excellence

Deliver exceptional Rails applications.

Excellence checklist:

- Conventions followed throughout
- Tests comprehensive and fast
- Performance profiled and optimized
- Code idiomatic and readable
- Security audited with brakeman
- Caching effective at all layers
- Background jobs monitored (Mission Control or Sidekiq Web UI)
- Deployment automated and zero-downtime

Code excellence:

- DRY without premature abstraction
- SOLID applied pragmatically
- Rails conventions over custom patterns
- Readable code over clever code
- YJIT-optimized patterns (Ruby 3.3+)
- Minimal gem dependencies
- Strong parameter discipline
- Encrypted credentials for secrets

Hotwire excellence:

- Turbo Drive for seamless navigation
- Turbo Frames scoped to the right granularity
- Turbo Streams for surgical DOM updates
- Stimulus controllers small and focused
- Progressive enhancement as default
- Server-rendered HTML first, JavaScript second
- Morphing for efficient DOM updates
- Native mobile bridge with Turbo Native

Testing excellence:

- Request specs for every endpoint
- Model specs for validations and business logic
- System specs for critical user flows
- Factory patterns over excessive fixtures
- Parallel tests for speed
- No flaky tests tolerated
- CI pipeline green before merge
- Coverage tracked but not gamed

Performance excellence:

- YJIT enabled in production (Ruby 3.3+)
- N+1 queries caught by strict_loading
- Fragment caching on expensive views
- Caching layer appropriate to version (Solid Cache or Redis)
- Database indexes on all foreign keys and query columns
- Background jobs for anything over 100ms
- CDN for assets and user uploads
- Response times under 100ms for API endpoints

Deployment excellence:

- Rails 8: Kamal 2 with Thruster for HTTP/2 and auto-SSL
- Rails 7: Capistrano, Docker Compose, or PaaS
- Docker image optimized and small
- Health checks configured
- Database migrations run safely (strong_migrations)
- Environment parity (dev/staging/prod)
- Monitoring with error tracking (Sentry, Honeybadger)
- Log aggregation and observability

Always prioritize convention over configuration, developer happiness, and the Rails way. Build applications that are powerful, maintainable, and a joy to work on.
