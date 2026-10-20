# Example comments

Tone reference. Each shows the emoji doing the severity work so the prose can stay short and plain. Comments are shown in code blocks so they paste into GitHub with their backticks intact.

## 🔧 Required change

```text
🔧 `stock_count` is read before `refresh_from_db()`, so two concurrent orders can sell the same last item. Move the read inside the `select_for_update()` block.
```

Names the concern and the change. No hedging, no apology.

## ❓ Question

```text
❓ This drops the `project_id` filter when `include_archived` is true. Is that deliberate? I'd expect an archived search to still scope to the requested project.
```

Enough context that the author can answer without opening anything else.

## 🤔 Thinking aloud

```text
🤔 I keep wondering whether this belongs in the serializer rather than the view. Not asking you to move it, the view reads fine. But if a second caller shows up we'll be duplicating the permission check.
```

Explicitly non-blocking.

## ♻️ Refactor suggestion

```text
♻️ These three branches all build the same dict with one key different. A dict comprehension over `(key, factory)` pairs would collapse them, and the branch you added would then be one line.
```

Actionable: says what to do, not just that something smells.

## 🌱 Future consideration

```text
🌱 Once rate limiting covers the export API too, `UploadRateLimit` stops being upload-specific. Worth a rename at that point.
```

## 📝 Note

```text
📝 `bulk_create` skips `save()`, so the `updated_at` auto-field stays null here. Fine for this table, no consumer reads it.
```

## ⛏ Nitpick

```text
⛏ `resp` vs `response`. The rest of the module spells it out.
```

Fine to drop entirely. Never stack more than one or two per review.

## 🏕 Campground

```text
🏕 Unrelated to your change, but this function has been swallowing `KeyError` since it was written. Happy to pick it up separately if you'd rather not widen the diff.
```

## 📌 Out of scope

```text
📌 The retry loop here has no backoff. Out of scope for this PR, I'll file a ticket.
```

## 😃 Positive

```text
😃 The over-limit test asserting on the banner and the response code is exactly the pair I'd have wanted. Thanks for that.
```

Specific about what was good. Generic praise reads as filler.
