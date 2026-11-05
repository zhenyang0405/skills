# Content Creation Skills: Market Survey and Our Design (Nov 2026)

Research into the agent skills that exist for content creators, mainly for **YouTube, Shorts,
TikTok and Instagram Reels**, to decide what to build for a beginner tech/AI creator. It is the
groundwork for the [`content` pack](../skills/content/README.md).

- **Date:** 2026-11-05
- **Method:** the GitHub search API (stars, license, last push), web search for platform guidance,
  and a full read of 14 of the most relevant repos, downloaded with `scripts/fetch-reference.sh`
  (never installed or run).
- **Star counts** are a snapshot from GitHub search on the date above. They measure popularity, not quality.

---

## 1. Key findings

1. **There are hundreds of creator skills, but almost none are built for a beginner.** Nearly all
   assume you already have a channel, a niche, a voice and analytics. None start with "what
   should my channel be about and how do these platforms even work?", which is where a beginner gets stuck.
2. **The best ones share a loop:** shared voice/context file → ideas from outliers and real
   questions → several hooks scored → beat-by-beat script with on-screen plan → human posts →
   read retention against your own baseline → log the lesson. That loop is what our pack implements.
3. **Most "viral" skills are formula lists with invented numbers.** Repos regularly cite stats like
   "82% of viewers…", "the first 1.7 seconds", "+25-40% watch time" with no source. No platform
   publishes retention or CTR benchmarks. Skills that repeat them teach beginners to chase fake targets.
4. **Good evidence habits are rare, but they exist:** outliers measured as a multiple of a
   channel's *own* median with minimum sample sizes; placeholders instead of invented facts;
   "verify the code before it goes on screen"; one change per experiment. We kept all of these.
5. **Tech/AI creators are underserved.** Only one repo (`arome3/code-to-content`) treats the
   creator's own code and projects as raw material, and none handle the specific risks of AI
   content: wrong benchmark screenshots, hype, secrets visible in screen recordings, and YouTube's
   inauthentic-content rules aimed at automated AI channels.
6. **Supply-chain and conduct risks show up here too:** one popular repo writes an advertisement
   for its paid product into every `SKILL.md`; several auto-publish to TikTok/Instagram after a single
   "yes"; several need paid scraping APIs or a logged-in session (against platform terms). Same rule
   as the rest of this repo: study, don't install.

---

## 2. What's in the market

### 2.1 All-in-one platform suites

| Repo | ★ | License | What it is | Best idea | Weakness |
|---|---|---|---|---|---|
| [Jakeschincariol/instagram-agent-skill](https://github.com/Jakeschincariol/instagram-agent-skill) | 4.9k | MIT | 13 skills that run an Instagram account (reels, carousels, captions, DMs, audit, viral research) | On-screen text written as its own script; hook scorer that publishes its own accuracy (good at real vs bad hooks, near coin-flip at hit vs miss) | Instagram only; leans on its own scoring tools |
| [Jakeschincariol/youtube-agent-skill](https://github.com/Jakeschincariol/youtube-agent-skill) | 4.6k | MIT | 11 short YouTube skills: script, package, retention, shorts, viral, plan, SEO | First 15 s must confirm the click, open a question and prove the payoff; title + thumbnail as one unit; retention leak / cliff / slide | Tied to small Python scorers; assumes an existing channel |
| [AgriciDaniel/claude-youtube](https://github.com/AgriciDaniel/claude-youtube) | 671 | MIT | One orchestrator with 14 sub-skills (audit, SEO, script, strategy, ideate, monetize…) and long reference guides | Positioning statement, pillar framework, composite-scored ideas with urgency windows | Very large; DataForSEO paid API; reference files carry unverified benchmarks |
| [Jakeschincariol/x-agent-skill](https://github.com/Jakeschincariol/x-agent-skill) | 73 | MIT | Same design for X | — | Text platform |

### 2.2 Short-form scripting and hooks

| Repo | ★ | License | What it is | Best idea | Weakness |
|---|---|---|---|---|---|
| [vyralcontent/content-skills](https://github.com/vyralcontent/content-skills) | 197 | MIT | 7 skills: hooks, ideas, TikTok, Reels, Shorts, captions | "Stuck = missing angle, not missing topic"; "can you write 3 hooks in a minute?" as an idea test; test cheap first | **Every skill tells the agent to pitch the author's paid product**; unsourced "datasets show" claims |
| [artemnovitckii/content-skills](https://github.com/artemnovitckii/content-skills) | 124 | MIT | Craft: storytelling, viral hooks, anti-AI writing, "dumbify" | "But/therefore" beats; last line first; four ways hooks fail; specificity ladder; priority order accurate > clear > specific > voiced | No inputs or evidence steps |
| [rediumvex/viral-hooks-skill](https://github.com/rediumvex/viral-hooks-skill) | 119 | MIT | 100 hook formulas | — | A list, not a process |
| [Melvynx/video-agent-skills](https://github.com/Melvynx/video-agent-skills) | 97 | MIT | End-to-end short-video studio: outliers, script, clips, b-roll, editing, publish | Outlier = views ÷ own median with sample floors; `{{placeholders}}` for unknown facts; clip criteria for long → short | Paid per-call APIs; "remake" mode is close to copying; publishes right after a yes |

### 2.3 Research and trends

| Repo | ★ | License | What it is | Best idea | Weakness |
|---|---|---|---|---|---|
| [mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill) | 66.6k | MIT | Researches a topic across Reddit, X, YouTube, HN and the web for the last 30 days | Rewrite "how to use X" into how people actually discuss it; multi-source clusters beat single sources; "nothing solid" is a valid answer | Heavy engine with many API keys and browser-cookie access |
| [ScrapeCreators/social-media-research-skills](https://github.com/ScrapeCreators/social-media-research-skills) | 5.6k | MIT | Outlier finder, comment mining, trend discovery, competitor teardowns | Outlier tiers by multiple; comment taxonomy (questions, objections, confusion, requests); one loud comment ≠ a theme | Thin templates over a paid API |
| [bradautomates/head-of-content](https://github.com/bradautomates/head-of-content) | 298 | MIT | Parallel research agents per platform, then a content plan | Search adjacent audiences too; per-video teardown (hook, structure, pacing, CTA) | Paid keys; arbitrary scoring weights |

### 2.4 Text platforms and general marketing

| Repo | ★ | License | What it is | Best idea | Weakness |
|---|---|---|---|---|---|
| [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) `social` | 58k (whole repo) | MIT | The leading marketing set; `social` covers all platforms | A hook is visual + spoken + on-screen text; tutorials open on the result; drafts only, never auto-publish | B2B/SaaS framing |
| [sergebulaev/linkedin-skills](https://github.com/sergebulaev/linkedin-skills) | 5.6k | MIT | 12 LinkedIn skills | Story Bank interview; humanizer that checks for **over-correction** | Precise but uncheckable "our corpus" stats; paid scraping |
| [blacktwist/social-media-skills](https://github.com/blacktwist/social-media-skills) | 625 | MIT | 14 skills for text-first platforms around one context file | Benchmark only against your own average; pattern analysis refuses under 10 posts | Example hooks contain made-up stats; vendor tool can post |

### 2.5 Production, editing and workflow

| Repo | ★ | License | What it is | Note |
|---|---|---|---|---|
| [nateherkai/herk-edit-kit](https://github.com/nateherkai/herk-edit-kit) | 2.6k | unclear | 15 video-editing skills (cuts, captions, Shorts) | Editing, not ideas/scripts; license unclear, so not studied |
| [pexoai/pexo-skills](https://github.com/pexoai/pexo-skills) | 818 | MIT | Image, audio and video generation | Asset generation |
| [yanhua1010/self-media-content-workflow](https://github.com/yanhua1010/self-media-content-workflow) | 647 | MIT | Brief → research → write → publish → analytics pipeline (Chinese platforms) | Separate publish authorization; fact vs inference; one variable per experiment; style rules only after 3 repeated edits |
| [AgriciDaniel/claude-shorts](https://github.com/AgriciDaniel/claude-shorts) | 311 | MIT | Long-form to Shorts with Remotion rendering | Rendering pipeline |
| [arome3/code-to-content](https://github.com/arome3/code-to-content) | 7 | MIT | Turns a codebase into developer content | Mine TODOs, commits and decisions; cite `file:line`; **swap-the-name test** |

Also found: dozens of smaller TikTok/Reels kits (UGC ad scripts, slideshow generators,
AI-video prompt packs), Chinese-language creator skills (Douyin, Xiaohongshu, WeChat), and indexes
such as [UnderleveledBuilder/awesome-social-media-skills](https://github.com/UnderleveledBuilder/awesome-social-media-skills).
Most are prompt templates without process or evidence gates.

---

## 3. Platform facts the skills rely on

Checked November 2026. Official documentation is thin and third-party blogs disagree, so the skills
state only what is well supported and tell the agent to re-check limits on official pages.

- **All four platforms test new videos on a small audience and widen distribution based on
  behaviour**: did they stop, did they stay, did they act. Follower count matters less than it used to.
- **YouTube:** says recommendations aim for viewer satisfaction, measured partly by surveys as well
  as watch time. Shorts and long-form are evaluated separately. Since March 31, 2025, a Short view
  counts when it starts or replays, so "viewed vs swiped away" and average % viewed are the useful
  Shorts metrics. Studio's A/B test compares up to three titles and/or thumbnails by watch time.
  Realistic AI-generated or altered media must be disclosed (disclosure doesn't limit reach).
  "Repetitious content" was renamed "inauthentic content" in July 2025 and covers mass-produced,
  templated videos.
- **TikTok:** interactions, including watch time, weigh most for the For You feed. Creator Rewards
  pays only for original videos over one minute. Search is a major discovery path.
- **Instagram:** Adam Mosseri has named watch time, likes per reach and sends per reach as top
  signals, with sends mattering most for reaching non-followers. Originality is enforced (reposts and
  other apps' watermarks get less distribution). Trial Reels test a Reel on non-followers first.
- **Benchmarks:** "good retention is 65%"-style numbers are not in any official source. The
  skills compare each video against the creator's own median instead.

Sources: [Metricool, Shorts algorithm](https://metricool.com/youtube-shorts-algorithm/) ·
[Nitro Media Group, retention metrics](https://www.nitromediagroup.com/video-retention-short-vs-long-videos-platform-comparison/) ·
[DataSlayer, YouTube algorithm](https://www.dataslayer.ai/blog/youtube-algorithm-2025-how-to-get-your-videos-recommended) ·
[OutlierKit, viewer satisfaction](https://outlierkit.com/resources/youtube-viewer-satisfaction-algorithm-2026/) ·
[Tubefilter, test & compare titles](https://www.tubefilter.com/2025/07/16/youtube-feature-test-and-compare-titles-thumbnails/amp/) ·
[YouTube Help, channel monetization policies](https://support.google.com/youtube/answer/1311392) ·
[Social Samosa, inauthentic content](https://www.socialsamosa.com/news-2/youtube-clarifies-monetisation-policy-targeting-inauthentic-content-9493155) ·
[9to5Google, altered content disclosure](https://9to5google.com/2024/03/18/youtube-altered-content-disclosure/) ·
[TikTok Creator Academy, Creator Rewards](https://www.tiktok.com/creator-academy/article/creator-rewards-program) ·
[Kabo, Mosseri's ranking series](https://kabo.sh/guides/instagram-ranking-2026) ·
[SocialPilot, Reels algorithm](https://www.socialpilot.co/blog/instagram-reels-algorithm) ·
[vidIQ, faceless channels](https://vidiq.com/blog/post/start-faceless-channel-youtube/)

---

## 4. Our design: the `content` pack

Four skills, one per stage, no overlap. All four read one creator profile
(`my-context/references/creator.md`) and share a `content/` workspace. None of them publish.

| Skill | Stage | The gap it fills |
|---|---|---|
| `content-strategy` | Once, then every few months | Nobody else starts from zero: platform primer, angle and specific viewer, three pillars, a cadence that fits real hours, voice from real samples, 30-day plan with weekly learning goals |
| `content-ideas` | Weekly | Ideas from four evidence wells (own work first, then audience questions, outliers vs own median, verified news), gated (pillar fit, 3-hook test, swap-the-name, verified sources) and scored on Pull, Proof, Angle and Ease |
| `video-script` | Per video | Proof collected first; placeholders instead of invented facts; packaging first for long-form; five hooks of different types (frame + line + text); say/show table; read-aloud and AI-tells pass with over-correction check; code run or marked untested; secrets hidden; also cuts Shorts and reviews scripts |
| `content-retro` | 7-28 days after posting | Four-rung ladder (shown → stopped → stayed → acted), own-median multiples with sample sizes, one biggest leak, exactly one test, lessons promoted to the profile only after 3 repeats |

**Deliberately left out:** paid scraping APIs and logged-in sessions; auto-publishing; hook
"formula" lists in the hundreds (we use 9 types with tech examples and a failure check instead);
editing/rendering pipelines (separate problem, add later if needed); text-platform skills (planned
as `repurpose-post` if LinkedIn/X joins the plan).

**Tools the user already has that pair well:** Canva and Figma connectors for thumbnails, the
Hugging Face connector for trending models (an ideas source), and web search for verification.

---

## 5. Next steps

1. Fill `profile/PROFILE.md` and `my-context` (about me, goals, projects), then run
   `content-strategy` to create the creator profile.
2. Post 8-12 Shorts over the first month, then run `content-retro`'s monthly review. Rewrite any
   step of these skills that didn't help. A skill earns its place by improving real results.
3. Consider later: `repurpose-post` (LinkedIn/X), `thumbnail-brief` with image generation, a
   small local script for the outlier median maths if doing it by hand gets tedious.
