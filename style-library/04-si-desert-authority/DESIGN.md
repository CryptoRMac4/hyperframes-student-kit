# SI Desert Authority: Design Spec

> Sources of truth: the Sonoran Intelligence brand system (colors, voice) and the live sonoranintel.com `site/css/main.css` (fonts, kicker and wordmark treatment). Ryan ruled on 2026-09-13 that SI videos use Barlow Condensed + Barlow to match the live site. Logo mark: `assets/sic-logo.png`, copied from `sonoranintel.com/images/sic-logo.png`.

## Style Prompt

Grounded, warm, quietly confident. These cards should feel like they come from a consultancy that has done the work for decades: flat earth-tone surfaces, big condensed type, generous space, and no tech clichés. The audience is local business owners (roofers, plumbers, clinics), so every card talks about calls, jobs, reviews, and rankings in plain words. Tier1 cards take over the frame with saguaro, sand, or bone. Tier2 cards sit on a solid plate in a corner or the lower band so the speaker's face stays clear. Terracotta shows up once per card as a thin marker, and that restraint is why it lands.

## Colors

| Token | Hex | Role |
|---|---|---|
| `--saguaro` | `#2D3A2E` | Dark takeover surface (thesis, stat, score-gauge, end-card), tier2 dark plate, ink on light |
| `--sand` | `#E8D5B7` | Light takeover surface (section, overview, ranking-climb), eyebrows and secondary text on saguaro |
| `--bone` | `#F5EDE0` | Lightest surface (quote, before-after), text on saguaro, tier2 light plate. Replaces white. |
| `--mesquite` | `#3D2E1F` | Headlines and body on sand/bone. Replaces black. |
| `--adobe` | `#8B6F47` | Eyebrows, rank numbers, hairlines on light surfaces |
| `--terracotta` | `#C8682E` | THE accent: one underline, rule, marker, edge bar, or base line per card. Never carries text. |
| `--terracotta-deep` | `#8F4A1E` | Fill for any text-bearing terracotta surface (end-card CTA): bone text stays ~5.7:1 |

Derived alphas only (opacity, never new hues): `--saguaro-plate` 94%, `--bone-plate` 96%, `--bone-dim` 64%, `--bone-line` 16%, `--adobe-line` 32%, `--mesquite-dim` 72%. Never pure white or black.

### Colorblind rule (Ryan is red/green colorblind)

- Any terracotta surface carries **bone** text only. Never mesquite, saguaro, or ink on terracotta. Text-bearing terracotta surfaces use `--terracotta-deep` (bone ~5.7:1), because bone on standard terracotta is only ~3.3:1. Never lighten it.
- Never encode meaning by hue alone. Before/after differ by **position, label, size, and weight**. The client row in ranking-climb differs by **fill luminance, weight, the YOU tag, and position**. The audit grade is **words** in a chip, not a color.
- The test is "would this still read if orange and brown were the same hue?", not just "does the contrast ratio pass?"

## Typography

- **Barlow Condensed 700**: headlines, stat numbers, names, wordmark. **600**: eyebrows, quote text, section kicker.
- **Barlow 400 / 500 / 600**: supporting copy, labels, list items, CTA.
- Vendored OFL woff2 in `fonts/`, loaded by `@font-face` in `tokens.css`. No CDN at render.
- Every number uses `font-variant-numeric: tabular-nums lining-nums`. Count-ups overlay an invisible ghost of the final text, so the box is sized in the real font and never reflows.
- **Eyebrow** (from the live site `.kicker`): uppercase, tracked 0.22-0.24em, led by a 56px x 3px rule in the same color. Sand on saguaro, adobe on sand/bone.
- **Wordmark** (from the live site nav): Barlow Condensed 700, uppercase, tracked 0.09em, bone.

| Use | Size @1080p |
|---|---|
| Hero stat | 340px |
| Section numeral | 520px |
| Before / after values | 250px / 380px |
| Thesis, section title | 124-132px |
| Overview, business names, query | 96-104px |
| Quote | 92px |
| Tier2 headline, name | 58-70px |
| Stat label | 56px |
| Body / list items | 36-46px |
| Eyebrow | 24-28px |
| Fine print | 22px |

### No orphan lines

Every multi-line headline, subhead, and caption uses `text-wrap: balance` (paragraphs and list items use `pretty`) with a `ch` or px max-width. The `maxChars` in `style.json` are sized so the sample copy splits into even lines. If filled copy leaves one or two words alone on a line, rewrite the copy rather than shrinking the type.

## Motion

- **Feel:** steady and confident. Firm ease-outs, with no elastic, bounce, glitch, neon, or HUD.
- **Eases (tokens, read by cards):** `--gsap-in` power3.out for entrances, `--gsap-wipe` power2.inOut for rules/wipes/strokes, `--gsap-out` power2.in for exits, `--gsap-count` power2.out for count-ups and fills.
- **Entrances:** 30-50px slides with autoAlpha (0.6-0.8s), mask reveals (section numeral, wordmark), clip-path wipes (label, list panel, grade chip), and a saguaro panel wipe on section.
- **Markers:** the terracotta underline or rule scales in from the left after its text lands (0.5-0.6s).
- **Numbers:** always count up from 0 (0.9-1.8s). The gauge ring, marker, and number share one duration and ease so they arrive together.
- **Signature motif:** a hairline horizon with two sun arcs that draw in (bone at 16%) on dark takeovers.
- **Holds:** a slow 6-8px upward drift so no frame goes dead.
- **Exits:** 0.45s, reversing the entrance direction. The end-card holds with no exit.
- **Lengths:** tier1 4.5-6.5s and tier2 3.5-5s, exits included. Root `data-duration` matches, and every timeline ends at its exit.

## Safe zones

- Title safe: 120px sides, 96px top/bottom. Tier1 content column starts at 180px.
- Tier2 placement is tuned for Ryan's framing (face left of center, about x 520-870, y 170-650). Lower-third and definition sit in the lower band (plate tops at y 814 and about y 707). The label sits top-right. The list is a right-third panel (x 1180-1800). If a speaker frames right of center, mirror the label and list.
- Proof composites over a real talking-head frame are in `preview/*.face-clearance.png`.

## Card kinds in this style

- **tier1 takeovers:** thesis, stat, section, quote, overview
- **tier2 support:** lower-third, label, list, definition
- **custom:** before-after (then vs now), score-gauge (audit score 0-100 plus grade words), ranking-climb (client climbs a 5-row local results list), end-card (logo mark, wordmark, tagline, one CTA)

## Voice for sample and filled copy

Operator tone and outcomes first: leads, calls, jobs, reviews, rankings. Keep "AI Visibility" jargon to a minimum. Short sentences. No em dashes, no hype words (unlock, 10x, game-changing), and no accreditation claims.

Default slot text is deliberately generic so no preview reads as a real claim: "Client Name, Business" / "City, AZ" on the quote, "Review source" as its label, "Source: add source" on the stat, "Client result, City" on before-after, "Your Business" and "Competitor A-D" on score-gauge and ranking-climb. Ryan never ships fabricated reviews, stats, or client results: fill these only with real, verifiable data, and leave a source empty rather than invent one. The quote card has no star graphics for the same reason.

## What NOT to do

- No second accent. Terracotta appears once per card. Arrows, checks, and nodes use saguaro or sand.
- No dark text on terracotta, and no lighter terracotta under bone text.
- No gradients that read as gradients, no glow, no glassmorphism, no drop shadows, no grain, no cold blue, no robot or brain imagery.
- No hue-only meaning: every comparison also differs by position, label, size, or weight.
- Tier2 never goes full-frame and never goes in the center band where a face sits.
- No `<br>` in slot text, and no shrinking the font to dodge a wrap. Rewrite the copy instead.
