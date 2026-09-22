// Max-length slot stress test for 03-lbw-deep-surrender (runs on the Mini, from the kit root).
// usage: ssh mac-mini-remote 'cd ~/Developer/hyperframes-student-kit && node - ' < lbw03-stress.mjs
// Fills every text slot with copy at (or just under) its style.json maxChars, snapshots the
// hero frame, and writes tmp/lbw03/stress-out/<card>.png. Nothing is written into the pack.
import { readFileSync, writeFileSync, mkdirSync, cpSync, rmSync, readdirSync, copyFileSync } from "node:fs";
import { execSync } from "node:child_process";
import { join } from "node:path";

process.env.PATH = "/opt/homebrew/bin:/usr/local/bin:" + process.env.PATH;
const P = "style-library/03-lbw-deep-surrender";
const OUT = "tmp/lbw03/stress-out";
rmSync(OUT, { recursive: true, force: true });
mkdirSync(OUT, { recursive: true });
const manifest = JSON.parse(readFileSync(join(P, "style.json"), "utf8"));
const limits = Object.fromEntries(manifest.cards.map((c) => [c.file, Object.fromEntries(c.slots.map((s) => [s.name, s.maxChars]))]));

const specs = [
  ["cards/tier1/t1-thesis.html", 3.5, false, {
    eyebrow: "Why slow breathing matters",
    headline: "Slow breathing is a skill you can practice and improve every day",
    support: "A few steady minutes can quietly change how the rest of your day feels" }],
  ["cards/tier1/t1-stat.html", 3.6, false, {
    kicker: "Breaths in a single day", stat: "20,000",
    label: "breaths an average adult takes each day, almost all unnoticed",
    source: "Rough estimate at fourteen per minute" }],
  ["cards/tier1/t1-section.html", 3.4, false, {
    label: "Module", number: "12",
    title: "How Your Nervous System Responds to Breath",
    subtitle: "The quiet shift from stress to rest, and why it happens so reliably" }],
  ["cards/tier1/t1-quote.html", 3.8, false, {
    quote: "The breath is the bridge between body and mind. Slow it down, and everything else begins to slow down along with it.",
    name: "Alexandra Montgomery Reyes", role: "Lead Facilitator, Liquid Breathwork Training" }],
  ["cards/tier1/t1-overview.html", 4.4, false, {
    eyebrow: "Inside this lesson", title: "Your path through this lesson",
    items: ["Why slow breathing calms the body fast", "The simple science of carbon dioxide", "Guided practice with the 4-4-6 pattern", "How to keep a daily practice going"] }],
  ["cards/tier2/t2-lower-third.html", 3.0, true, {
    name: "Alexandra Montgomery Reyes", role: "Lead Facilitator, Liquid Breathwork Training" }],
  ["cards/tier2/t2-label.html", 2.6, true, { eyebrow: "Technique of the week", text: "Resonance Frequency Breath" }],
  ["cards/tier2/t2-list.html", 3.9, true, {
    eyebrow: "Three minutes before you begin", headline: "Three things to do before practice",
    items: ["Find a quiet, comfortable seat", "Loosen any tight clothing now", "Set a timer for ten minutes", "Rest your hands on your belly"] }],
  ["cards/tier2/t2-definition.html", 3.4, true, {
    term: "Hyperventilation", kind: "noun, physiology",
    definition: "Breathing faster or deeper than your body needs, which lowers carbon dioxide and can leave you dizzy or tingly." }],
  ["cards/custom/c-caption-box.html", 1.5, true, {
    text: "When your mind starts to wander, gently bring your attention back to the breath." }],
  ["cards/custom/c-end-card.html", 4.6, false, { cta: "Book a first class at liquidbreathwork.com" }],
];

for (const [file, at, bg, slots] of specs) {
  const base = file.split("/").pop().replace(".html", "");
  let html = readFileSync(join(P, file), "utf8");
  const report = [];
  for (const [name, value] of Object.entries(slots)) {
    const max = limits[file]?.[name];
    if (Array.isArray(value)) {
      const re = new RegExp(`(<ul[^>]*data-slot="${name}"[^>]*>)[\\s\\S]*?(</ul>)`);
      if (!re.test(html)) throw new Error(`${base}: list slot ${name} not found`);
      html = html.replace(re, `$1${value.map((v) => `<li>${v}</li>`).join("")}$2`);
      report.push(`${name}[${value.map((v) => v.length).join(",")}]/${max}`);
    } else {
      const re = new RegExp(`(<(\\w+)[^>]*data-slot="${name}"[^>]*>)[\\s\\S]*?(</\\2>)`);
      if (!re.test(html)) throw new Error(`${base}: slot ${name} not found`);
      html = html.replace(re, `$1${value}$3`);
      report.push(`${name}=${value.length}/${max}${value.length > max ? " OVER" : ""}`);
    }
  }
  const T = `tmp/lbw03/stress-${base}`;
  rmSync(T, { recursive: true, force: true });
  mkdirSync(T, { recursive: true });
  cpSync(join(P, "fonts"), join(T, "fonts"), { recursive: true });
  copyFileSync(join(P, "tokens.css"), join(T, "tokens.css"));
  html = html.replace("../../tokens.css", "tokens.css");
  if (bg) {
    copyFileSync("/tmp/lbw03/f20.jpg", join(T, "speaker.jpg"));
    html = html.replace("<body>", `<body><img src="speaker.jpg" alt="" data-layout-ignore style="position:absolute;left:0;top:0;width:1920px;height:1080px">`);
  }
  writeFileSync(join(T, "index.html"), html);
  execSync(`npx hyperframes snapshot ${T} --at ${at} --no-end -o ${T}/snaps --describe false`, { stdio: "ignore" });
  const frame = readdirSync(join(T, "snaps")).find((f) => f.startsWith("frame-00"));
  copyFileSync(join(T, "snaps", frame), join(OUT, `${base}.png`));
  console.log(`${base}: ${report.join("  ")}`);
}
