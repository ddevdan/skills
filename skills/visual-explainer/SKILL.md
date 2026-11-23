---
name: visual-explainer
description: Turn text, a concept, a system, or a process into a low-text diagram the user understands at a glance, rendered as a self-contained HTML/SVG page. Use when the user asks to explain something visually, to diagram or map it, or says they would rather not read the text.
---

# Visual explainer

You turn material into a picture the user reads in seconds. The picture carries the structure: what exists, what connects, what comes first. Words stay, as **labels** on the marks they name, and carry what a picture cannot: names, numbers, forces, "not", "if".

The reader is the user, again and again. Keep the **house vocabulary** identical across every explanation, so each new diagram reads faster than the last.

## House vocabulary

| Mark | Means | Label |
|---|---|---|
| Rounded box | A thing, actor, or component | Noun, 1–4 words |
| Arrow | One relation per diagram: _acts on_, _flows to_, or _then_ (time). Pick one and use it for every arrow. | Verb, 1–3 words |
| Large light container | Group, or part-of | Group name, top-left |
| Dashed outline | Optional, sometimes, or hypothetical | As the solid version |
| Numbered circle | Reading order of steps | The number |
| Accent colour (exactly one) | The one path, difference, or bottleneck the spine is about | — |
| Neutral grey | Everything else | — |
| Icon | A concrete object, always beside its label | Same as the box |

## Steps

1. **Spine.** Write the takeaway as one sentence of at most 15 words. It becomes the diagram's title. Rewrite abstract nouns as actors doing observable actions ("the cache serves an old copy", in place of "eventual consistency"). Done when you have the sentence and the list of actors and actions it involves.

2. **Shape.** Pick the layout from what the spine describes:

   | Content | Layout |
   |---|---|
   | One-way process | Left-to-right row of numbered steps |
   | Cycle | A ring, arrows running round it. Draw the ring even when a line feels easier: a line hides that it repeats. |
   | System | Containers for the parts, arrows for how they interact |
   | Comparison | Side-by-side columns aligned row by row; the difference in accent |
   | Hierarchy | Top-down tree, or nested containers |
   | Quantity | A chart: bars for separate categories, a line for change over a continuum |

   Mixed material takes the layout of the spine; the rest goes into zoom cards (step 3). Draw the schematic, not the scene: place marks by meaning, not by physical look.

3. **Layers.** With more than about 6 primary nodes, split: an overview of at most 6 nodes on top, then one zoom card per node that needs detail, below it, in the same vocabulary. Each zoom card has its own one-line spine as its title.

4. **Words.** Put each label on or beside its mark. Use a legend only when marks carry values a label cannot index, such as a colour scale. Reach for words wherever the picture cannot carry the meaning: causes and forces, negation, conditions, exact numbers. Budget: node 1–4 words, arrow 1–3 words, callout at most 12 words, at most 3 callouts. Sentences live only in callouts and the title.

5. **Render.** Write one self-contained HTML file with inline SVG and inline CSS, on a fixed white background, into a temp or scratch directory (the user's repo only when asked). If an `artifact-diagramming` skill is installed, follow its SVG mechanics.

6. **Check.** Render the page, screenshot it with whatever browser tool you have, and look at the image. Done when every item holds:
   - The title is the spine sentence.
   - Every label is within budget, and sentences appear only in callouts and the title.
   - Every arrow carries the same relation.
   - Exactly one element or path is in the accent colour.
   - Labels are readable at 100% zoom and nothing overlaps.
   - Reading order is clear from position or numbers alone.

   Fix and re-render until the list holds. With no way to view the image, say so in the hand-over.

7. **Hand over.** Open the file in the user's browser. Reply with the file path and the spine sentence, then ask the user to say in a few words what they take from the diagram. Their restatement, not their approval, tells you whether it worked: what they miss or misread is the next fix.
