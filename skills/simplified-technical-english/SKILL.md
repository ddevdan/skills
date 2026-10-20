---
name: simplified-technical-english
description: Rewrite technical documents into ASD-STE100 Simplified Technical English. Use when the user wants to simplify, clarify, or convert a design spec, tech spec, requirements doc, or README into plain/controlled technical English, or mentions STE, ASD-STE100, or Simplified Technical English.
---

# Simplified Technical English (ASD-STE100)

Rewrite a technical document into **Simplified Technical English (STE)** — the ASD-STE100 controlled language. STE removes ambiguity so a reader with limited English understands the text on the first read: approved words used one way, short sentences, active voice, one instruction at a time.

The authoritative writing rules live in [`rules.md`](rules.md). A bundled word list, [`dictionary.csv`](dictionary.csv), maps ~486 common non-approved words to their approved replacements with examples (columns: `keyword`, `Approved meaning/ALTERNATIVES`, `APPROVED EXAMPLE`, `Not approved`). This is a subset, not the full official STE **Dictionary** (~2,000 words), which is proprietary — request the free copy from https://www.asd-ste100.org/. Use `dictionary.csv` for the substitutions it covers, apply the writing rules everywhere, and flag vocabulary the subset cannot confirm rather than claiming approval.

## Step 1 — Scope the source

Identify the document to rewrite (a file path or pasted text) and classify each part as one of two modes, because sentence limits and verb rules differ:

- **Procedure** — steps the reader performs. Imperative, one instruction per sentence, ≤ 20 words per sentence.
- **Descriptive** — how something works or is structured. ≤ 25 words per sentence.

Complete when: every section is tagged procedure or descriptive, and you have the full source text in hand.

## Step 2 — Rewrite

Read [`rules.md`](rules.md) in full, then rewrite the document rule by rule. For each word, check [`dictionary.csv`](dictionary.csv): if it appears in the `keyword` or `Not approved` column, replace it with the `Approved meaning/ALTERNATIVES` entry and match the style of the `APPROVED EXAMPLE`. Preserve the meaning, the heading structure, and every technical fact — STE simplifies language, never content. When a required word is missing from the approved vocabulary and no plain synonym exists, keep it and mark it for review; do not invent a substitute that changes the meaning.

Complete when: every sentence has been reworked against the rules in `rules.md`, and no original fact, warning, or step has been dropped.

## Step 3 — Verify

Run these checkable rules (the automatable subset, from the ASD-STE100 text linter) across the rewritten text. Fix every hit, then re-run until clean:

- **STE-1.1** — no word from the `Not approved` column of [`dictionary.csv`](dictionary.csv) remains in the text (each has been replaced with its approved alternative).
- **STE-1.2** — each word is used only as one part of speech (no word that is both a noun and a verb in the same document).
- **STE-2.1** — no noun cluster longer than three nouns in a row.
- **STE-6.7** — no paragraph longer than 6 sentences; single-sentence paragraphs no more than once per 10 paragraphs.
- **STE-8.11** — no semicolons (split into separate sentences instead).
- **Sentence length** — procedure sentences ≤ 20 words, descriptive ≤ 25 words.

Complete when: every check above passes on the whole document, exhaustively — not a sample.

## Step 4 — Deliver

Return the rewritten document. Below it, add a short **Review notes** list containing only: words kept because no approved synonym exists (Step 2), and anything you could not verify without the official Dictionary. If nothing needs review, say so.
