# Branch Resolve Conflicts — Examples

Annotated walkthroughs of real conflict resolution scenarios, from simple to complex.

## Example 1: Refactoring meets feature development (simple combine)

**Scenario:** You're merging a feature branch that added new functionality (`feat/user-preferences`) into main, which recently completed a refactor of the user module.

**Starting state:**
```bash
$ git merge feat/user-preferences
Auto-merging src/user/service.ts
CONFLICT (content): Merge conflict in src/user/service.ts
Automatic merge failed; fix conflicts and then commit the result.

$ git status
both modified:      src/user/service.ts
```

**The conflict:**
```typescript
<<<<<<< HEAD (main)
// Refactored: User service now delegates to UserRepository
export class UserService {
  constructor(private repo: UserRepository) {}

  async getUser(id: string): Promise<User> {
    return this.repo.findById(id);
  }

  async updateUser(id: string, data: Partial<User>): Promise<User> {
    return this.repo.update(id, data);
  }
}
||||||| merged common ancestor
// Old: Direct database access in service
export class UserService {
  async getUser(id: string): Promise<User> {
    return db.query('SELECT * FROM users WHERE id = ?', [id]);
  }

  async updateUser(id: string, data: Partial<User>): Promise<User> {
    return db.query('UPDATE users SET ? WHERE id = ?', [data, id]);
  }
}
=======
// Feature branch: Added preferences handling
export class UserService {
  async getUser(id: string): Promise<User> {
    return db.query('SELECT * FROM users WHERE id = ?', [id]);
  }

  async updateUser(id: string, data: Partial<User>): Promise<User> {
    return db.query('UPDATE users SET ? WHERE id = ?', [data, id]);
  }

  async getUserPreferences(id: string): Promise<UserPreferences> {
    return db.query('SELECT * FROM user_preferences WHERE user_id = ?', [id]);
  }

  async updateUserPreferences(id: string, prefs: Partial<UserPreferences>): Promise<UserPreferences> {
    return db.query('UPDATE user_preferences SET ? WHERE user_id = ?', [prefs, id]);
  }
}
>>>>>>> feat/user-preferences
```

**Analysis:**
- **Main branch intent:** Refactor UserService to use dependency injection (UserRepository pattern). Cleaner architecture, testable.
- **Feature branch intent:** Add user preferences functionality. New feature, but unaware of refactor.
- **Compatibility:** Both intents are valuable and compatible. The feature should use the refactored architecture.

**Resolution:**
```typescript
// Resolved: Both intents combined
// - Main's architecture (DI + repository pattern)
// - Feature's new preferences methods

export class UserService {
  constructor(
    private userRepo: UserRepository,
    private preferencesRepo: UserPreferencesRepository
  ) {}

  async getUser(id: string): Promise<User> {
    return this.userRepo.findById(id);
  }

  async updateUser(id: string, data: Partial<User>): Promise<User> {
    return this.userRepo.update(id, data);
  }

  async getUserPreferences(id: string): Promise<UserPreferences> {
    return this.preferencesRepo.findByUserId(id);
  }

  async updateUserPreferences(id: string, prefs: Partial<UserPreferences>): Promise<UserPreferences> {
    return this.preferencesRepo.update(id, prefs);
  }
}
```

**After resolution:**
```bash
$ npm test
 PASS src/user/service.test.ts
 PASS src/user/preferences.test.ts
$ npm run typecheck
No errors.
$ npm run format
Already formatted.

$ git add src/user/service.ts
$ git commit -m "merge: integrate user preferences with refactored service architecture

Merge resolves conflict by:
- Preserving main's DI + repository pattern (cleaner testability)
- Integrating feature's new UserPreferencesRepository methods
- Both intents: modern architecture + new functionality"
```

**Key insight:** Both branches wanted good things. The resolution isn't picking a winner; it's combining them intelligently.

---

## Example 2: Configuration contradiction (must pick one, document why)

**Scenario:** You're merging a performance optimization branch (`perf/connection-pooling`) into main. The pooling implementation requires a different connection timeout than main's recent safety improvements.

**The conflict:**
```typescript
<<<<<<< HEAD (main)
// Safety-first: Longer timeout to avoid spurious failures on slow networks
const CONNECTION_CONFIG = {
  timeout: 30000,  // 30s
  retryCount: 3,
  retryDelay: 1000,
};
||||||| merged common ancestor
const CONNECTION_CONFIG = {
  timeout: 5000,
  retryCount: 1,
  retryDelay: 500,
};
=======
// Perf: Aggressive timeout for pooling efficiency
const CONNECTION_CONFIG = {
  timeout: 3000,  // 3s
  retryCount: 1,
  retryDelay: 100,
};
>>>>>>> perf/connection-pooling
```

**Analysis:**
- **Main intent:** Improve stability for users on slow/unreliable networks. Timeout tolerance is part of the design.
- **Feature intent:** Aggressive pooling that fails fast and retries. Optimizes connection utilization.
- **Incompatibility:** These are in direct conflict. Pooling's 3s timeout will fail on slow networks. Main's 30s timeout will defeat pooling's efficiency.

**Decision framework:**
- What's the merge goal? "Phase 1: Implement connection pooling with safety baseline."
- What's more important: Stability or efficiency? Safety comes first in phase 1.
- Is there a third path? Yes — expose timeout as configurable, default to safe value.

**Resolution:**
```typescript
// Connection config: Safe defaults, tunable for pooling behavior
const DEFAULT_CONNECTION_CONFIG = {
  timeout: 30000,       // 30s — safe default for slow networks
  retryCount: 3,
  retryDelay: 1000,
};

export function getConnectionConfig(options: {
  pooling?: boolean;
  timeout?: number;
} = {}): typeof DEFAULT_CONNECTION_CONFIG {
  return {
    timeout: options.timeout ?? (options.pooling ? 5000 : 30000),
    retryCount: options.pooling ? 1 : 3,
    retryDelay: options.pooling ? 100 : 1000,
  };
}
```

**Commit message:**
```
merge: integrate connection pooling with configurable timeout

Resolves conflict between:
- Main: 30s timeout for stability on slow networks
- Feature: 3s timeout for pooling efficiency

Resolution: Expose timeout as configurable parameter.
- Default: 30s (safety-first, matches main's intent)
- Pooling mode: 5s (balances stability + efficiency)

This allows pooling to tune for throughput while preserving safety
for standard clients. Performance optimization follows in phase 2.

Related: PERF-1234 (connection pooling task)
         STAB-5678 (slow network timeout baseline)
```

**Follow-up:**
An issue is filed: "perf: profile and optimize connection timeout configuration per workload."

**Key insight:** When intents conflict, the resolution isn't arbitrary. It's based on the merge's stated goal + the ability to parameterize both behaviors.

---

## Example 3: Competing error handling strategies (architectural choice)

**Scenario:** You're merging a observability enhancement branch (`obs/detailed-logging`) into main. Both branches touch error handling, but in incompatible ways.

**The conflict:**
```typescript
<<<<<<< HEAD (main)
// Error categorization for routing to appropriate handlers
async function handleRequest(req: Request) {
  try {
    return await processRequest(req);
  } catch (error) {
    if (error instanceof ValidationError) {
      return { status: 400, error: error.message };
    }
    if (error instanceof AuthError) {
      return { status: 401, error: 'Unauthorized' };
    }
    logger.error('Unexpected error:', error);
    return { status: 500, error: 'Internal server error' };
  }
}
||||||| merged common ancestor
async function handleRequest(req: Request) {
  try {
    return await processRequest(req);
  } catch (error) {
    logger.error('Error:', error);
    return { status: 500, error: 'Internal server error' };
  }
}
=======
// Structured logging with context
async function handleRequest(req: Request) {
  try {
    return await processRequest(req);
  } catch (error) {
    logger.error('Request failed', {
      requestId: req.id,
      userId: req.user?.id,
      path: req.path,
      error: error.message,
      stack: error.stack,
    });
    return { status: 500, error: 'Internal server error' };
  }
}
>>>>>>> obs/detailed-logging
```

**Analysis:**
- **Main intent:** Categorize errors and respond with appropriate status codes. Good UX for clients.
- **Feature intent:** Structured logging with rich context. Good for debugging and observability.
- **Incompatibility:** Main only logs unexpected errors. Feature logs all errors with context. They're solving different problems.

**The right answer:** Both are necessary. Combine them.

**Resolution:**
```typescript
// Error handling with proper categorization + structured logging
interface RequestContext {
  requestId: string;
  userId?: string;
  path: string;
}

function createErrorContext(req: Request): RequestContext {
  return {
    requestId: req.id,
    userId: req.user?.id,
    path: req.path,
  };
}

async function handleRequest(req: Request) {
  const context = createErrorContext(req);
  try {
    return await processRequest(req);
  } catch (error) {
    const status = categorizeError(error);
    const response = formatErrorResponse(error, status);

    if (status >= 500) {
      // Server error: always log with full context
      logger.error('Request failed', {
        ...context,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
    } else {
      // Client error: log only if not a routine validation issue
      logger.warn('Request rejected', {
        ...context,
        status,
        reason: error instanceof Error ? error.message : 'Unknown',
      });
    }

    return { status, error: response };
  }
}

function categorizeError(error: unknown): number {
  if (error instanceof ValidationError) return 400;
  if (error instanceof AuthError) return 401;
  if (error instanceof NotFoundError) return 404;
  return 500;
}

function formatErrorResponse(error: unknown, status: number): string {
  if (status < 500) {
    return error instanceof Error ? error.message : 'Request invalid';
  }
  return 'Internal server error';
}
```

**Commit message:**
```
merge: integrate structured logging with error categorization

Combines two error-handling strategies:
- Main: Categorize errors (400/401/500) for proper HTTP responses
- Feature: Structured logging with request context for observability

Resolution: Apply both strategies:
- Categorize errors for client response codes
- Log with rich context (requestId, userId, path) for debugging
- Separate logging levels: error for 5xx, warn for 4xx

This gives us both good UX (correct status codes) and good observability
(structured logs with context for each error type).

Related: OBS-4567 (structured logging), ERR-8901 (error handling)
```

**Key insight:** Sometimes conflicts aren't about picking winners. They're about recognizing that both solutions address different concerns, and the right answer is to apply both with proper integration.

---

## Example 4: Test changes after refactoring (combined intent, test adjustments)

**Scenario:** You're rebasing a test improvement branch (`tests/coverage-improvements`) onto main. Main recently refactored the checkout module.

**The conflict:**
```typescript
// tests/checkout.test.ts
<<<<<<< HEAD (main)
// Updated for refactored Cart class
describe('Cart', () => {
  let cart: Cart;
  let itemRepo: MockItemRepository;

  beforeEach(() => {
    itemRepo = new MockItemRepository();
    cart = new Cart(itemRepo);  // Refactored: now uses DI
  });

  it('adds items to cart', async () => {
    await cart.addItem('item1', 2);
    expect(cart.getItems()).toEqual([
      { id: 'item1', quantity: 2, price: 100, total: 200 },
    ]);
  });

  // ... other tests
});
||||||| merged common ancestor
describe('Cart', () => {
  let cart: Cart;

  beforeEach(() => {
    cart = new Cart();  // Old: global state
  });

  it('adds items to cart', () => {
    cart.addItem('item1', 2);
    expect(cart.items).toHaveLength(1);
  });
});
=======
// Coverage improvements: more edge cases, async setup
describe('Cart', () => {
  let cart: Cart;

  beforeEach(() => {
    cart = new Cart();
  });

  it('adds items to cart', () => {
    cart.addItem('item1', 2);
    expect(cart.items).toHaveLength(1);
    expect(cart.getTotalPrice()).toBe(200);
  });

  it('handles duplicate items (merge rather than add)', () => {
    cart.addItem('item1', 2);
    cart.addItem('item1', 3);
    expect(cart.items).toHaveLength(1);
    expect(cart.items[0].quantity).toBe(5);
  });

  it('rejects negative quantities', () => {
    expect(() => cart.addItem('item1', -1)).toThrow();
  });
});
>>>>>>> tests/coverage-improvements
```

**Analysis:**
- **Main intent:** Update tests to match the refactored Cart class (now uses DI, prices are mocked).
- **Feature intent:** Add comprehensive test cases (edge cases, negative paths).
- **Compatibility:** Both are good. Need to combine: use refactored setup + feature's comprehensive test cases.

**Resolution:**
```typescript
describe('Cart', () => {
  let cart: Cart;
  let itemRepo: MockItemRepository;

  beforeEach(() => {
    itemRepo = new MockItemRepository();
    itemRepo.setPrice('item1', 100);
    cart = new Cart(itemRepo);  // Refactored: now uses DI
  });

  describe('adding items', () => {
    it('adds items to cart', async () => {
      await cart.addItem('item1', 2);
      expect(cart.getItems()).toEqual([
        { id: 'item1', quantity: 2, price: 100, total: 200 },
      ]);
    });

    it('handles duplicate items (merge rather than add)', async () => {
      await cart.addItem('item1', 2);
      await cart.addItem('item1', 3);
      expect(cart.getItems()).toHaveLength(1);
      expect(cart.getItems()[0].quantity).toBe(5);
    });

    it('rejects negative quantities', async () => {
      await expect(cart.addItem('item1', -1)).rejects.toThrow(
        'Quantity must be positive'
      );
    });

    it('calculates total price correctly', async () => {
      await cart.addItem('item1', 2);  // 2 * 100 = 200
      expect(cart.getTotalPrice()).toBe(200);
    });
  });

  // ... other test suites
});
```

**After resolution:**
```bash
$ npm test
 PASS tests/checkout.test.ts (4 passed, 0 failed)
$ git add tests/checkout.test.ts
$ git rebase --continue
```

**Commit message:** (auto-generated by rebase)
```
refactor: test improvements for refactored Cart

Updated test suite for new Cart DI pattern + comprehensive coverage:
- Added itemRepo mock with configurable prices
- Extended edge case coverage (merge behavior, negative quantity validation)
- Async/await for refactored async Cart methods
```

**Key insight:** Test conflicts are often the easiest to resolve because both branches usually want the same thing: good coverage. The resolution is usually "use the newer version of both."

---

## Example 5: Feature flag / configuration merge (parametrization)

**Scenario:** You're merging a database migration branch (`db/new-schema`) into main, which added a feature flag system.

**The conflict:**
```typescript
// src/config.ts
<<<<<<< HEAD (main)
const CONFIG = {
  // Feature flags for gradual rollouts
  features: {
    useNewCheckout: process.env.FEATURE_NEW_CHECKOUT === 'true',
    useLargeFileUpload: process.env.FEATURE_LARGE_UPLOAD === 'true',
  },
};
||||||| merged common ancestor
const CONFIG = {
  database: {
    host: 'localhost',
    port: 5432,
    name: 'app_db',
  },
};
=======
// Database schema version configuration
const CONFIG = {
  database: {
    host: 'localhost',
    port: 5432,
    name: 'app_db',
    schemaVersion: 'v2',  // v2 schema added
  },
};
>>>>>>> db/new-schema
```

**Analysis:**
- **Main intent:** Support feature flags for gradual rollouts.
- **Feature intent:** Add database schema version config.
- **Incompatibility:** None! They're solving different problems in the same file.

**Resolution:**
```typescript
const CONFIG = {
  database: {
    host: 'localhost',
    port: 5432,
    name: 'app_db',
    schemaVersion: 'v2',  // Latest schema version
  },
  features: {
    useNewCheckout: process.env.FEATURE_NEW_CHECKOUT === 'true',
    useLargeFileUpload: process.env.FEATURE_LARGE_UPLOAD === 'true',
    // Feature flag for database migration rollout
    useNewSchema: process.env.FEATURE_NEW_SCHEMA === 'true',
  },
};
```

**Commit:**
```bash
$ git add src/config.ts
$ git commit -m "merge: integrate feature flags with new database schema config

Both config updates are orthogonal:
- Feature flags enable gradual rollout strategies
- New schema version tracks database compatibility

Added FEATURE_NEW_SCHEMA flag to control schema v2 adoption."
```

**Key insight:** Not all conflicts are deep technical disagreements. Some are just "both branches extended the same file in different ways." The resolution is often just "append both."

---

## Summary

| Example | Conflict Type | Resolution Strategy | Outcome |
| --- | --- | --- | --- |
| 1: Refactor + feature | Syntactic + complementary intent | Combine intelligently | Both branches' goals achieved |
| 2: Configuration conflict | Direct contradiction | Parametrize to support both | Merge goal wins, with flexibility for future |
| 3: Error handling | Different concerns, same layer | Apply both with integration | Better UX + better observability |
| 4: Test improvements | Same goal, newer code | Use refactored version + all test cases | Comprehensive, correct tests |
| 5: Config extension | Non-overlapping extensions | Merge both sections | Clean, additive change |

The pattern: **Understand intent, preserve both when possible, document trade-offs when not.**
