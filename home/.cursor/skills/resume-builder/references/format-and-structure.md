# Resume Format & Structure Reference

## Source: Harvard Career Services, r/EngineeringResumes, The Tech Resume Inside Out

---

## Page Layout Specifications

### Page Size
- **US Letter:** 8.5 x 11 inches (for US/international applications)
- **A4:** 210 x 297 mm (for European applications — rarely needed)

### Margins
- **Recommended:** 0.75 inches (1.9 cm) all sides
- **Minimum:** 0.6 inches — anything less feels cramped and hurts readability
- **Maximum:** 1.0 inch — wastes valuable space
- **NEVER use headers/footers** — reduce margins instead and write in the body (ATS may not parse headers/footers)

### Fonts
Use universally supported, ATS-safe fonts:

| Font | Recommendation | Notes |
|------|---------------|-------|
| **Calibri** | PREFERRED | Modern, clean, excellent readability, default in Word |
| **Arial** | Good alternative | Clean sans-serif, universally supported |
| **Garamond** | Acceptable | Classic serif, slightly more traditional |
| **Times New Roman** | Avoid if possible | Technically fine for ATS but feels dated |

**NEVER use:** decorative fonts, handwriting fonts, or anything not installed by default on Windows/Mac.

### Font Sizes
| Element | Size | Weight |
|---------|------|--------|
| Name | 16pt | Bold |
| Section headings | 11.5pt | Bold |
| Body text / bullets | 10.5pt | Regular |
| Technology lines | 9.5pt | Italic, gray (#505050) |
| Contact info | 10.5pt | Regular |

**Minimum readable size:** 10pt. Never go below this.

### Spacing
| Element | Spacing |
|---------|---------|
| Line spacing (body) | 13pt |
| Between section heading and content | 4pt after heading |
| Before section heading | 10pt |
| Before each experience block | 7pt |
| Between bullets | 2pt after, 1pt before |
| After technology line | 1pt |

### Visual Separators
- Use **bottom borders** on section headings (solid line, 8pt weight, black)
- Do NOT use tables as dividers
- Do NOT use horizontal rules/lines between experiences — spacing alone is sufficient

---

## Section Order

### For Experienced Engineers (3+ years)
```
1. Name (centered, bold, 16pt)
2. Contact Information (centered, one line)
3. TECHNICAL SKILLS
4. PROFESSIONAL EXPERIENCE
5. PROJECTS & CONTRIBUTIONS (optional)
6. EDUCATION
```

### For Junior Engineers / Recent Graduates
```
1. Name (centered, bold, 16pt)
2. Contact Information (centered, one line)
3. EDUCATION (first, with GPA if >3.5, relevant coursework)
4. TECHNICAL SKILLS
5. EXPERIENCE (internships, part-time, freelance)
6. PROJECTS
```

### Why This Order?
Harvard Career Services states: "List headings in order of importance." For experienced engineers, your skills and experience are what get you hired. For new graduates, your education is your strongest asset.

---

## Contact Information Format

**Include:**
- Full name
- Professional email (Gmail/Outlook — NOT AOL/Hotmail/Yahoo due to implicit bias)
- GitHub profile URL (only if it has content — don't link an empty GitHub)

**Consider including (context-dependent):**
- LinkedIn profile URL — note: r/EngineeringResumes wiki says this is unnecessary ("they can Google you"), but it remains standard in most US applications
- Phone number — wiki says unnecessary ("recruiters email you first"); non-local area codes can cause bias
- Citizenship/visa status near name — if not obvious from work history

**Do NOT include:**
- Physical address or ZIP code (location bias risk)
- Location/city unless applying to that specific city (non-local bias risk)
- Photo (never in US/UK)
- Age, gender, marital status, nationality
- References section or "available upon request"

**URL formatting (per r/EngineeringResumes wiki):**
- Write URLs in plain text — no masking as hyperlink text
- Do NOT preface with "Email:", "GitHub:", "Portfolio:"
- Do NOT include https://www.
- Do NOT underline, italicize, or color URLs (links should NOT stand out visually)
- URLs should still be clickable hyperlinks in the document — just styled as black, regular text

**Format:** Single line, centered, separated by pipes ( | )
```
name@gmail.com   |   github.com/username   |   linkedin.com/in/profile
```

---

## Experience Section Format

Each experience block should follow this structure:

```
**Job Title**,  Company Name  –  Location (Remote)          Dates
• [Action Verb] + [What you did] + [Domain context] + [Impact]
• [Action Verb] + [What you did] + [Technical detail] + [Result]
• ...
Technologies: list, of, technologies, used
```

### Date Formatting (per r/EngineeringResumes wiki)
- **Use "Present"** for current roles — NOT "Current", "Now", or "Ongoing"
- **Use en dashes (–)** not hyphens (-) or the word "to": "Mar 2025 – Present"
- **Space before and after en dashes:** "Mar 2012 – Mar 2022", NOT "Mar 2012–Mar 2022"
- **Right-align dates** to the right margin using tab stops
- **Only graduation date for education** — no start dates, no date ranges
- Use months, NOT seasons/semesters ("March 2022", not "Winter 2022")
- No specific days ("January 2023", not "January 1, 2023")
- Don't abbreviate years ('23) — use full year (2023)
- Don't use digit abbreviations (9/2013) — use month names
- **Standard abbreviations:** Jan, Feb, Mar, Apr, May, June, July, Aug, Sept, Oct, Nov, Dec (no periods)
- Bullet points should not extend further right than the dates

### Location Format
- "Miami, FL (Remote)" — include remote if applicable
- "Mexico City (Remote)" — for international
- "Venezuela" — country alone is fine for non-US

### Technology Lines
- Placed after all bullets for each experience
- Slightly smaller font (9.5pt), italic, gray color
- Prefix with "Technologies:" (bold italic)
- List only technologies actually used in that role
- Also duplicate key technologies in the Skills section at the top

---

## Page Count Guidelines

| Experience Level | Recommended Pages |
|---|---|
| 0-3 years | 1 page (strict) |
| 3-7 years | 1-2 pages |
| 7+ years | 2 pages |
| 15+ years / executive | 2 pages (still not 3) |

**If going to 2 pages:**
- The most important, recent content should be on page 1
- Older/less relevant roles can have fewer bullets
- Never leave page 2 less than half full — if it's sparse, condense to 1 page

---

## ATS Format Requirements

These ensure your resume is correctly parsed by Applicant Tracking Systems:

1. **Single column layout** — no multi-column, no sidebars, no text boxes
2. **No tables for layout** — tables can scramble content order in ATS
3. **No images, icons, or graphics** — ATS cannot parse these
4. **No headers/footers** — many ATS skip these entirely
5. **Standard section headings** — use exactly: "Technical Skills", "Professional Experience", "Education", "Projects"
6. **Submit as .docx or .pdf** — both are fine for modern ATS (the "PDF breaks ATS" myth is outdated)
7. **No text in text boxes** — content inside text boxes is often invisible to ATS
8. **Consistent date format** — ATS parses dates; inconsistency causes errors

---

## PDF Conversion & Delivery

### Always Deliver Both Formats
- **.docx** — for future editing by the user
- **.pdf** — for sending to employers, uploading to job portals, and sharing

### Conversion Process
```bash
# Convert using LibreOffice (preserves all formatting)
python scripts/office/soffice.py --headless --convert-to pdf resume.docx

# Verify PDF is text-based (ATS can extract content)
pdftotext resume.pdf -

# Check page count
pdfinfo resume.pdf
```

### Verification After PDF Conversion
1. **Text extractability:** Run `pdftotext` — if content comes out readable, the PDF is ATS-compatible
2. **Page count:** Confirm it matches the .docx (margins may shift slightly)
3. **Name rendering:** Verify name and special characters/accents render correctly
4. **Visual fidelity:** PDF should look identical to Word — same fonts, spacing, alignment
5. **File size:** A 2-page text-based resume PDF should be under 200KB

### Why PDF Is the Preferred Delivery Format
- **Format preservation:** .docx renders differently on different OS/Word versions/fonts. PDF is identical everywhere.
- **ATS compatibility:** All modern ATS parse text-based PDFs correctly. The "ATS can't read PDFs" myth is outdated.
- **Professionalism:** PDF is the standard for business documents. .docx suggests a draft.
- **Portal compatibility:** Many job portals request or prefer PDF.
- **No accidental edits:** Recipients cannot modify a PDF.
