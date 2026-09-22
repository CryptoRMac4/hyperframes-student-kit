# LBW Deep Surrender · Design Spec

> Source of truth: the Liquid Breathwork "Deep Surrender" brand system (the site's DESIGN.md, extracted from its CSS). This pack translates that web system to 1920x1080 video. Where the two ever disagree, the website wins.

## Style Prompt

Deep water at night. Every card should feel still, weighted, and unhurried, the visual equivalent of a long exhale. Copy surfaces out of soft focus the way something rises through water, hairlines draw open like an inhale, and nothing ever bounces, snaps, or sizzles. Takeovers sit on the Abyss to Deep Water gradient with a slow drifting depth light. Overlays are frosted Undertow glass with a thin gold edge, parked where they never touch the speaker's face. The feeling to protect is surrender, not intensity: this brand is the calm alternative to catharsis-selling competitors, so urgency is off-brand by definition.

## Colors

| Token | Hex | Role in video |
|---|---|---|
| Abyss | `#0a1628` | Takeover ground, caption text, gradient endpoints |
| Deep Water | `#131f38` | Gradient midpoint |
| Undertow | `#1a2a4a` | Glass panels at 72%, depth light, pacer orb |
| Cream | `#f5f0e8` | Headlines and primary copy on dark; caption box fill |
| Warm Sand | `#d4c5a9` | Eyebrows, secondary copy, wordmark, stat labels |
| Gold | `#c9a96e` | Accent only: hairlines, list markers, quote mark, progress arc, CTA border |

- Never pure white or pure black. Cream and Abyss are the endpoints.
- **Gold is sacred.** No gold headlines, no gold fills, no gold body text. If a card has more than two gold marks, remove one.
- **Contrast is absolute.** Dark ground takes Cream or Warm Sand text. The one light surface (caption box) takes Abyss text.
- **Colorblind safe.** Ryan is red/green colorblind. Meaning is never carried by hue alone: breath phases are named in words and shown by size, list order is numbered, emphasis is weight or italic.
- Use the opacity ramps in `tokens.css` (`--cream-60`, `--gold-20`, `--undertow-72`); never invent mixed colors.

## Typography

Two families, and only two. Both vendored as OFL woff2 in `fonts/` (latin subset, variable weight), so renders never hit a font CDN.

| Role | Face | Size at 1080p | Notes |
|---|---|---|---|
| Stat numeral | Playfair Display 700 | 280px | tabular figures |
| Thesis headline | Playfair Display 700 | 104px | line-height 1.14 |
| Section / end titles | Playfair Display 700 | 84px | |
| Pull quote | Playfair Display 600 italic | 68px | the only italic in the pack |
| Tier2 headline, term, name | Playfair Display 700 | 52px | |
| Body, list items | Inter 400/500 | 34px | line-height 1.45 |
| Caption | Inter 500 | 44px | Abyss on Cream |
| Eyebrow | Inter 600 uppercase | 22px | tracking 0.22em, Warm Sand |
| Source line | Inter 500 uppercase | 18px | tracking 0.22em |

- Wordmark is the site logo: `LIQUID BREATHWORK` in Playfair Display 700, Warm Sand, tracking 0.05em. Never the old drip-letter logo.
- **No orphan lines.** Every multi-line text element has `text-wrap: balance` and a measured `max-width`, and every slot has a `maxChars` in `style.json` sized so the longest legal string still splits evenly. If a filled slot wraps with one or two words alone, rewrite the copy; never add `<br>` or shrink the font.
- Capitalize "Breathwork". No em dashes anywhere in slot copy.

## Motion

Breath-paced. Two families of ease, nothing else.

| Use | GSAP ease | Typical duration |
|---|---|---|
| Copy surfacing (opacity + 12 to 24px rise + blur 6 to 10px clearing) | `expo.out` | 1.2 to 1.8s |
| Hairlines drawing open, anything that inhales or exhales | `sine.inOut` | 1.4 to 1.6s |
| Exits (fade, 8 to 12px drift, soft blur) | `sine.inOut` | 0.6 to 0.8s |

- Stagger between sibling elements: 0.25 to 0.6s. List items reveal one by one, roughly one per spoken beat.
- Ambient: tier1 grounds carry two depth-light pools that drift about 140px across the whole card on `sine.inOut`, so the frame is never static. A fixed-seed grain at 5% prevents gradient banding after H.264 compression.
- Banned: `back.*`, `elastic.*`, `bounce.*`, `steps()`, flashes, shakes, fast scale pops, water ripples, droplets, splash or drip effects.
- Timing: tier1 5 to 6s, tier2 4 to 5s including exit, caption 3s, end card 6s, breath pacer = its breath cycles plus 2s.
- The breath pacer is the only card whose motion carries meaning: inhale grows the orb, hold keeps it still, exhale shrinks it, always on `sine.inOut`, with the phase named in words and a count.

## Safe zones and speaker clearance

- Title-safe margins: 144px left and right, 96px top and bottom (`--safe-x`, `--safe-y`).
- Tier2 cards are transparent outside their panel and never cover the face. Reference framing (LBW talking head): face occupies roughly x 520 to 930, y 180 to 680, speaker slightly left of center, open wall on the right.
  - `lower-third`: bottom-left band, top edge below y 830.
  - `label`: bottom-right band.
  - `list`, `definition`: right column, x 1176 to 1776.
  - `caption-box`: top-center, above the head, two lines max.
- If a shoot frames the speaker on the right, mirror the side cards (swap `right` for `left` on `.panel`); keep the face clear before anything else.

## Card kinds in this style

- **tier1 takeovers:** `thesis`, `stat`, `section` (numbered chapter), `quote` (with attribution), `overview` (3 to 4 item agenda)
- **tier2 overlays:** `lower-third`, `label`, `list` (2 to 4 items, one by one), `definition`
- **custom:** `breath-pacer` (configurable inhale / hold / exhale guide), `caption-box` (locked lesson caption look), `end-card` (wordmark plus one CTA)

## What NOT to do

- No ripple, droplet, splash, or drip gimmicks, and no synthesized water sounds. Ryan rejected them.
- No drip-letter logo. The wordmark is type.
- No gold text blocks or gold fills; no third typeface; no pure white or black.
- No bouncy or elastic easing, no fast sizzle, no rapid cuts inside a card.
- No light-on-light or dark-on-dark text, and no element that tone-on-tone blends into its ground.
- No hanging one or two word last lines.
- Never claim accreditation, and never call Liquid Breathwork a "studio" in sample copy.
- Never let a tier2 panel cross the speaker's face, even at its entrance position.
