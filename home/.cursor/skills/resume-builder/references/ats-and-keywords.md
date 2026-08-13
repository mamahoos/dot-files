# ATS & Keywords Reference — Truths vs Myths

## Source: The Tech Resume Inside Out (Gergely Orosz), Amy Miller (ex-Amazon/Google recruiter), r/EngineeringResumes wiki, MIT CAPD, Harvard Career Services

---

## What ATS Actually Is

An Applicant Tracking System is a **database and workflow management tool** for recruiters. It is NOT an AI robot that rejects your resume. Understanding this distinction is critical.

**What ATS does:**
- Stores your application and resume in a database
- Tracks the status of your application through stages (Unviewed → Reviewed → Interview → Offer/Rejected)
- Allows recruiters to search/filter candidates by keywords
- Parses your resume to extract structured data (name, email, work history, skills)
- Some systems score relevance against the job description

**What ATS does NOT do (in most systems):**
- Automatically reject resumes based on a "score"
- Use AI to evaluate your qualifications
- Reject resumes because of PDF format
- Reject resumes because of specific fonts
- Count keyword density and reject below threshold

---

## ATS Myths — Debunked

### Myth 1: "75% of resumes are rejected by ATS before a human sees them"
**FALSE.** This statistic was fabricated by companies selling "ATS-beating" services. In reality, recruiters and inbound sourcers review resumes stored in the ATS. The high rejection rate comes from HUMAN screening (5-20 seconds per resume), not robots.

### Myth 2: "You need to hit a certain ATS score to get through"
**MOSTLY FALSE.** Some ATS systems can score relevance, but most don't auto-reject based on scores. Even low-scored resumes remain visible to recruiters. The score is a ranking aid, not a gatekeeper.

### Myth 3: "PDFs break ATS"
**FALSE for modern ATS.** All major ATS systems (Greenhouse, Workday, iCIMS, Lever) parse PDFs correctly. The only exception might be very old, legacy systems. Both .docx and .pdf are safe.

### Myth 4: "You need exact keyword matches"
**MOSTLY FALSE.** Modern ATS systems recognize synonyms and variations. "Software Engineer" matches "Software Developer". "Project Management" matches "managed projects". However, using the exact phrasing from the job description is still a good practice — not because ATS requires it, but because humans scan for familiar terms.

### Myth 5: "Put keywords in white text to trick the ATS"
**TERRIBLE IDEA.** This has never reliably worked and can get your application flagged or rejected. Many recruiters know about this trick and view it as dishonest.

### Myth 6: "ATS can't read tables or columns"
**PARTIALLY TRUE.** Old ATS systems struggle with complex table layouts, which can scramble content order. Modern systems handle simple tables better, but single-column layouts are still safest. Using tables for CONTENT (like skills) is fine; using tables for LAYOUT (multi-column resume) is risky.

---

## What Actually Matters for Getting Past Screening

Since humans (not robots) do the screening, optimize for HUMAN readability:

### 1. First-Scan Optimization (5-Second Test)
A recruiter spends 5 seconds on your resume initially. In that time, they should be able to identify:
- Your current/most recent job title
- Your most relevant technical skills
- Your years of experience level
- Whether you might be a fit

**This is why skills go at the top for engineers** — recruiters scan for specific technologies.

### 2. Keyword Strategy
Instead of "stuffing keywords," think about it as **matching language**:

- Read the job description carefully
- Note the specific technologies, methodologies, and tools mentioned
- Ensure these appear naturally in your resume if you actually have that experience
- Use the same terminology (if they say "CI/CD", use "CI/CD", not "continuous integration/continuous delivery" — or ideally both)

### 3. Relevant Section Headings
Use standard headings that both ATS parsers and humans expect:
- "Technical Skills" or "Skills" (not "What I Know" or "Toolbox")
- "Professional Experience" or "Experience" (not "Career Journey")
- "Education" (not "Academic Background")
- "Projects" (not "Things I've Built")

---

## Keyword Categories for Tech Resumes

When auditing a resume for keyword coverage, check these categories:

### Programming Languages
List all languages you actively use. Include version/standard if relevant:
- JavaScript (ES6+), TypeScript, Python, PHP, SQL, Java, C#, Go, etc.

### Frameworks & Libraries
Match what the job description asks for:
- React, Angular, Vue, NestJS, Laravel, Django, FastAPI, Express.js, Spring Boot, etc.

### Databases
Be specific about which ones you've used:
- PostgreSQL, MySQL, MSSQL, MongoDB, Redis, Elasticsearch, DynamoDB, etc.

### Cloud & Infrastructure
- AWS (specify services: S3, SES, SNS, Lambda, EC2, RDS)
- GCP, Azure (same — specify services)
- Docker, Kubernetes, Terraform, CI/CD

### Architecture & Methodology
These are HIGH-VALUE keywords for senior roles:
- Microservices, Hexagonal Architecture, DDD, CQRS, Event-Driven
- SOLID Principles, Design Patterns, TDD, Agile, Scrum
- REST API, GraphQL, gRPC, WebSocket

### Integration & Messaging
- Kafka, RabbitMQ, SQS, Redis Pub/Sub
- SAP, Salesforce, Stripe, Payment Gateways
- WhatsApp Business API, OpenAI API, Twilio

### Tools & Platforms
- Git, GitHub, GitLab, Bitbucket
- Jira, Confluence, Slack
- Figma, Postman

---

## Tailoring Strategy

When tailoring a resume to a specific job description:

### Step 1: Extract Requirements
Read the JD and highlight:
- Required technologies (MUST have these on your resume if you know them)
- Preferred technologies (nice to have)
- Soft skills they emphasize (leadership, communication, collaboration)
- Domain/industry keywords (fintech, healthcare, etc.)
- Seniority signals (mentoring, architecture decisions, cross-team)

### Step 2: Map to Your Experience
For each requirement, find where in your experience you've used it. If it's in your skills but not in any bullet, add it to a relevant bullet.

### Step 3: Reorder (Don't Rewrite Everything)
- Move the most relevant experience bullets to the TOP of each role
- Adjust the Skills section to lead with the most relevant category
- Ensure the job title alignment is clear

### Step 4: Don't Lie
Never add technologies or experiences you don't have. Tailoring means HIGHLIGHTING relevant experience, not fabricating it. You will be asked about everything on your resume in interviews.

---

## The Hiring Pipeline Context

Understanding where your resume sits in the process (from The Tech Resume Inside Out):

```
Applications (hundreds) → Resume Screen (5-20 sec) → Recruiter Call → Technical Screen → Onsite → Offer
```

The steepest dropoff is at the Resume Screen. From hundreds of applications, only a few dozen get a recruiter call. This is why your resume must:
1. Pass the 5-second scan test
2. Clearly show relevant skills and experience
3. Demonstrate impact, not just responsibilities
4. Be easy to read — recruiters are scanning dozens per day
