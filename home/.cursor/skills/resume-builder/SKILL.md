---
name: resume-builder
description: "Use this skill whenever the user wants to create, improve, optimize, review, or rewrite a resume, CV, curriculum vitae, or hoja de vida. Triggers include: any mention of 'resume', 'CV', 'curriculum', 'hoja de vida', 'job application', 'ATS optimization', 'resume review', 'cover letter', or requests to prepare documents for job applications. Also use when the user asks to tailor a resume to a specific job description, improve bullet points, add metrics/quantification, check ATS compatibility, translate a resume between languages, or create multiple versions of a resume. Use this skill even if the user just says 'help me get hired', 'optimize my application', 'I need to update my resume', or 'review my experience section'. Do NOT use for LinkedIn profile optimization, portfolio websites, or general document formatting unrelated to job applications."
disable-model-invocation: true
---

# Resume / CV Builder — Harvard Standards & ATS Best Practices

## Overview

This skill creates professional, high-standard resumes following Harvard Career Services guidelines, r/EngineeringResumes community best practices, and modern ATS (Applicant Tracking System) knowledge. It produces resumes that are optimized for both human recruiters (who spend 5-20 seconds scanning) and ATS parsing systems.

**Before starting any resume work, read the relevant reference files:**
- `references/format-and-structure.md` — Page layout, fonts, spacing, section ordering
- `references/bullet-writing-guide.md` — XYZ/STAR formula, action verbs, quantification
- `references/ats-and-keywords.md` — ATS truths vs myths, keyword strategy
- `references/common-mistakes.md` — What to avoid, anti-patterns

---

## Quick Decision Framework

| User Request | Action |
|---|---|
| "Create my resume from scratch" | Full build: gather info → structure → write → format → deliver |
| "Improve/optimize my existing resume" | Analyze current → identify issues → rewrite bullets → reformat |
| "Tailor resume to job description" | Extract keywords from JD → map to user's experience → rewrite targeted bullets |
| "Review my resume" | Audit against checklist → provide specific feedback with examples |
| "Create multiple versions" | Build base resume → create variants (1-page, 2-page, language versions) |
| "Make it ATS-friendly" | Check format compliance → ensure parseable structure → add relevant keywords naturally |

---

## Core Process

### Step 1: Gather Information

Before writing anything, collect:

1. **Full work history** — titles, companies, locations, dates, AND the domain/industry context of what each company does and what systems the user built
2. **Technical skills** — languages, frameworks, databases, tools, cloud, architecture patterns
3. **Education** — degrees, institutions, dates
4. **Projects** — personal, academic, open source
5. **Target market** — US/international (English), LATAM/Spain (Spanish), or both
6. **Target roles** — what kind of positions they're applying for
7. **Page preference** — 1 page (junior/mid), 2 pages (6+ years senior), or flexible

**CRITICAL: Ask about domain context for each role.** The difference between "developed web applications" and "developed fintech credit management systems handling card issuance, payment links, and transaction processing" is the difference between a generic and a compelling resume. Always ask:
- What industry/domain was this? (fintech, legaltech, healthcare, logistics, security, etc.)
- What kind of data did you handle? (sensitive PII, financial, legal, medical)
- Who were the end users? (B2B, B2C, internal, government)
- What was the business impact?

### Step 2: Structure the Resume

Follow the section order recommended by Harvard Career Services and r/EngineeringResumes:

```
1. Name & Contact Information (centered)
2. Technical Skills (for engineering/tech roles — put skills FIRST)
3. Professional Experience (reverse chronological)
4. Projects & Contributions (if relevant)
5. Education (at bottom for experienced professionals)
```

**Why Skills first?** For tech roles, recruiters and hiring managers scan for specific technologies. Putting skills at the top gives them what they need in the first 5 seconds. Harvard recommends ordering headings "in order of importance" — for engineers, skills ARE the most important first-scan item.

**Education placement:** Harvard puts education first for students. For professionals with 3+ years experience, move education to the bottom. The experience section becomes the centerpiece.

### Step 3: Write Content

Read `references/bullet-writing-guide.md` for the complete guide. Key principles:

**Every bullet must follow the XYZ formula:**
> "Accomplished [X] as measured by [Y] by doing [Z]"

Or condensed: **Action Verb + What You Did + Technical Context + Business Impact**

**Example transformation:**
- BAD: "Responsible for developing web applications"
- GOOD: "Developed fintech web applications for credit management, card issuance, and transaction processing using React and NestJS, structured under Hexagonal Architecture and DDD"

### Step 4: Format and Deliver

Read `references/format-and-structure.md` for the complete guide. Use the `docx` skill to create the Word document. Key specs:

- **Font:** Calibri 10.5pt body, 16pt name, 11.5pt section headings
- **Margins:** 0.75 inches all sides
- **Line spacing:** 13pt
- **Format:** Single column, no tables for layout, no graphics
- **File format:** .docx (for editing) AND .pdf (for sending/uploading)

### Step 5: Convert to PDF (MANDATORY)

**Always deliver both .docx and .pdf versions.** The .docx is for future editing; the .pdf is for sending to employers.

PDF conversion rules:
- Convert using LibreOffice: `python scripts/office/soffice.py --headless --convert-to pdf resume.docx`
- **Verify the PDF is text-based** (not a scanned image) by extracting text: `pdftotext resume.pdf -` — if text comes out, ATS can parse it
- **Check page count** matches expectations: `pdfinfo resume.pdf`
- **Verify name and key content** appear correctly in extracted text (catches truncation or encoding issues)
- PDF preserves exact formatting regardless of the recipient's operating system, Word version, or installed fonts
- Both .docx and .pdf are accepted by all modern ATS systems (Greenhouse, Workday, iCIMS, Lever, etc.)

**Why PDF matters:**
- .docx can render differently depending on the recipient's Word version, OS, and installed fonts
- PDF guarantees the recruiter sees EXACTLY what you designed
- Many job application portals specifically request PDF
- ATS parses text-based PDFs just as well as .docx

---

## Language Guidelines

### For English Resumes
- Use active voice, no personal pronouns (no "I", "my", "we")
- Start every bullet with a strong action verb (see reference file)
- Use US English spelling for US-targeted roles
- Keep job titles in standard industry format

### For Spanish Resumes
- Maintain the same structure and principles
- Use professional Spanish — avoid colloquialisms
- Keep technical terms in English when they're industry standard (e.g., "backend", "frontend", "DevOps", "SOLID", "CQRS")
- Start bullets with action verbs in Spanish (Desarrolle, Implemente, Lidere, Disene, Construi, Optimice, Arquitecte)

### Bilingual Strategy
When creating both versions, ensure they are NOT literal translations. Each version should read naturally in its language while conveying the same information and impact.

---

## Checklist Before Delivery

Run this checklist against every resume before delivering:

**Format:**
- [ ] Name fits on one line without truncation (max 16pt)
- [ ] Single-column layout, no tables for layout, no graphics/icons
- [ ] Font is Calibri/Arial, minimum 10.5pt body, black color
- [ ] White space is balanced — not too cramped, not too sparse
- [ ] Dates use en dashes (–) not hyphens (-), with spaces around them
- [ ] Dates are right-aligned, bullets don't extend past dates
- [ ] URLs are plain text (no color, no underline, no "Email:" prefixes, no https://www.)

**Content:**
- [ ] No personal pronouns (I, my, we, our)
- [ ] Every bullet starts with a strong past-tense action verb
- [ ] No bullets end with periods (bullets are not sentences)
- [ ] Every experience describes the DOMAIN (industry, system type, data sensitivity)
- [ ] Metrics/quantification present where possible (use digits: 8, not "eight")
- [ ] Technologies listed per role AND in skills section
- [ ] No superfluous verbs (spearheaded, orchestrated, utilized, leveraged)
- [ ] No excessive adjectives/adverbs (excellent, innovative, strategically)
- [ ] Section names follow standard: "Experience", "Skills", "Projects", "Education"
- [ ] Dates are consistent format with "Present" for current role (not "Current"/"Now")
- [ ] Reverse chronological order within each section
- [ ] No spelling/grammar errors
- [ ] No internal company jargon or project names only insiders would understand

**Delivery:**
- [ ] PDF version generated from final .docx
- [ ] PDF is text-based (verified with pdftotext — text is extractable)
- [ ] PDF page count matches expectations
- [ ] All hyperlinks work and point to professional pages
- [ ] Both .docx and .pdf delivered to user
