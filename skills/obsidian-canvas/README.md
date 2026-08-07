# Obsidian Canvas

Create and edit Obsidian Canvas (`.canvas`) files — visual canvases following the JSON Canvas spec. The skill handles all four node types (text, file, link, group), edges with arrows and anchor sides, color presets and hex colors, valid 16-character hex IDs, and the JSON validation pitfalls (newline escapes, ID uniqueness, edge integrity) that quietly break a canvas in Obsidian.

## Why this exists

Canvases in Obsidian are JSON under the hood, and the JSON has just enough structure to fail subtly: a duplicated 16-char hex ID, an edge pointing at a node that doesn't exist, a `\\n` escape that renders as the literal characters `\n` in a text node. Hand-editing a canvas works until it doesn't, and the failure mode is "Obsidian opens it but it looks broken." This skill writes valid canvases that render correctly the first time, and edits existing ones without introducing the small JSON gotchas that ruin an afternoon.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "create a canvas"
  - "build a mind map in Obsidian"
  - "make a flowchart for this project"
  - "add a node to my canvas"
- Working with any `.canvas` file (the skill activates automatically when one is in context)

## What it does

The skill creates new `.canvas` files with the base structure `{"nodes": [], "edges": []}` and adds nodes (text, file, link, group) with properly-generated unique 16-character hex IDs and non-overlapping positions. It connects nodes with edges, supporting anchor sides (top/right/bottom/left), labels, and colors. It validates JSON, ID uniqueness, and edge integrity (every `fromNode`/`toNode` resolves) before considering the file complete. It does **not** modify the underlying notes that file-type nodes reference, only the canvas itself.

### Inputs

- **Description of desired canvas** — node content, structure, connections.
- **Optional existing `.canvas` file** — to extend or edit.

### Outputs

- A `.canvas` file with valid JSON, ready to open in Obsidian.

### External systems used

- Local filesystem (read/write `.canvas` files)
- Obsidian (the `.canvas` file renders inside the Obsidian app — the skill itself is filesystem-only)

## How to use it

A typical session looks like this:

```text
You: create a canvas for the Project Atlas architecture: three services
     (auth-service, payments-ui, notifications-worker) connected to a
     central API gateway, with a separate group for external integrations.

Skill: Writing project-phoenix.canvas:

       - 4 text nodes for the services + gateway
       - 1 group node containing 2 link nodes for external integrations
       - 6 edges with arrows from services → gateway, gateway → externals
       - Position: gateway centered at (0,0); services arranged left;
         external group placed at (800, -50) with 2 internal nodes
       - Color: services in green ("4"), gateway in cyan ("5"),
         externals group in purple ("6")

       Saved. Open in Obsidian to verify the layout.
```

## Getting the most out of it

- **Let the skill handle ID generation.** 16-character hex IDs are easy to mistype. The skill generates them and verifies uniqueness; you don't need to think about it.
- **Use groups for visual organization.** Groups don't enforce containment in Obsidian — child nodes are just visually inside the group's bounds. Position child nodes deliberately within the group's `x`/`y`/`width`/`height`.
- **Add labels to edges that aren't obvious.** A bare arrow says "connected." A labeled arrow ("triggers", "depends on", "supersedes") says what kind of connection — much higher signal in dense diagrams.
- **Keep aspect ratios sane.** Text nodes default to readable sizes (200-450 wide, 80-300 tall). File nodes for images need larger heights. The skill follows these defaults; override only with reason.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Use `\\n` for newlines in text nodes.** Obsidian renders that as the literal characters `\n`. The skill always uses `\n` in JSON strings (which becomes a real newline when parsed).
- ❌ **Generate non-unique IDs.** When extending an existing canvas, the skill reads the existing IDs and verifies non-collision before adding new ones.
- ❌ **Create edges pointing at nonexistent nodes.** Every `fromNode` and `toNode` is checked against the nodes array. Stale references break Obsidian's rendering.
- ❌ **Modify the notes that file-type nodes reference.** The canvas points at notes; editing the notes is a separate skill ([obsidian-markdown](../obsidian-markdown/) or [obsidian-cli](../obsidian-cli/)).

## Examples

### Example: A simple flowchart

```json
{
  "nodes": [
    {
      "id": "6f0ad84f44ce9c17",
      "type": "text",
      "x": 0, "y": 0,
      "width": 250, "height": 100,
      "text": "Start",
      "color": "4"
    },
    {
      "id": "a1b2c3d4e5f67890",
      "type": "text",
      "x": 350, "y": 0,
      "width": 250, "height": 100,
      "text": "Validate input",
      "color": "5"
    },
    {
      "id": "c3d4e5f678901234",
      "type": "text",
      "x": 700, "y": 0,
      "width": 250, "height": 100,
      "text": "End",
      "color": "1"
    }
  ],
  "edges": [
    {
      "id": "e1234567890abcde",
      "fromNode": "6f0ad84f44ce9c17",
      "fromSide": "right",
      "toNode": "a1b2c3d4e5f67890",
      "toSide": "left",
      "toEnd": "arrow"
    },
    {
      "id": "f234567890abcdef",
      "fromNode": "a1b2c3d4e5f67890",
      "fromSide": "right",
      "toNode": "c3d4e5f678901234",
      "toSide": "left",
      "toEnd": "arrow",
      "label": "if valid"
    }
  ]
}
```

The first node is at (0,0), each next node 350px right. Anchor sides keep arrows tidy.

### Example: A canvas with a file embed and a group

```json
{
  "nodes": [
    {
      "id": "d4e5f6789012345a",
      "type": "group",
      "x": -50, "y": -50,
      "width": 1000, "height": 600,
      "label": "Project Atlas",
      "color": "4"
    },
    {
      "id": "e5f67890123456ab",
      "type": "file",
      "x": 0, "y": 0,
      "width": 400, "height": 300,
      "file": "Projects/Atlas.md"
    },
    {
      "id": "f6789012345abcde",
      "type": "link",
      "x": 500, "y": 0,
      "width": 400, "height": 200,
      "url": "https://example.com/phoenix-docs"
    }
  ],
  "edges": []
}
```

The group is positioned to visually contain the file and link nodes (note the `-50` offset to give padding inside the group).

## Internals

The skill follows this workflow per request:

1. **Create the file** with the base structure `{"nodes": [], "edges": []}`.
2. **Generate unique 16-character hex IDs** for each node and edge.
3. **Add nodes** with required fields: `id`, `type`, `x`, `y`, `width`, `height` plus type-specific fields (`text`, `file`, `url`, `label`).
4. **Add edges** referencing valid `fromNode`/`toNode`, optionally with `fromSide`, `toSide`, `toEnd`, `label`, `color`.
5. **Validate** JSON, ID uniqueness, and edge reference integrity.

Four node types:

- **text** — markdown content; `text` field. Use `\n` for newlines.
- **file** — points at a vault file; `file` field; optional `subpath` for headings/blocks.
- **link** — external URL; `url` field.
- **group** — visual container; optional `label`, `background`, `backgroundStyle`.

Color: preset numbers `"1"`-`"6"` (red, orange, yellow, green, cyan, purple) or hex `"#FF0000"`.

Layout guidelines:

- Coordinates can be negative; canvas extends infinitely.
- `x` increases right, `y` increases down; position is the top-left corner.
- Space nodes 50-100px apart; 20-50px padding inside groups.
- Align to multiples of 10 or 20 for cleaner layouts.

Key constraints:

- **`\n` not `\\n`** in JSON string literals.
- **All edge endpoints must resolve.** No dangling references.
- **IDs are 16 lowercase hex chars** generated from random 64-bit values.

## FAQ

**Q: Can I link a canvas node to another canvas?**
A: Yes — use a file-type node with `file` set to the other `.canvas` path. Obsidian handles the navigation.

**Q: What if I want a non-preset color?**
A: Use a hex string like `"#FF6B35"` instead of a preset number. Both are valid.

**Q: How do I link Mermaid-style nodes inside a canvas text node?**
A: Text nodes support full markdown, including Mermaid blocks. To link Mermaid nodes to vault notes, add `class NodeName internal-link;` inside the Mermaid block (see [obsidian-markdown](../obsidian-markdown/) for syntax details).

**Q: Why do my edges have arrows on both ends?**
A: By default, `toEnd` is `"arrow"` and `fromEnd` is `"none"`. If both ends have arrows, you've explicitly set `fromEnd: "arrow"` somewhere — change it back to `"none"` or omit it.

**Q: Can I animate or auto-layout the canvas?**
A: No — canvases are static. For auto-layout, you'd export to a graph tool. For interactivity, use Obsidian plugins.

## Related skills

- **[obsidian-vault](../obsidian-vault/)** — for the underlying notes that file-type nodes reference.
- **[obsidian-markdown](../obsidian-markdown/)** — for the markdown content inside text nodes (callouts, embeds, wikilinks all work).

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (full schema, validation rules, examples)
- **[references/](references/)** — Additional examples (`EXAMPLES.md`)
