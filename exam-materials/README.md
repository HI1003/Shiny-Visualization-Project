# STATS125 exam materials

This directory contains the four selected past-exam question groups and six matching question/solution PDFs from 2024 S2, 2025 S1 and 2026 S1. The user authorised their inclusion in the public project on 16 November 2026 so recipients can clone the complete reviewed app.

Run `Rscript Start-Shiny.R` from the repository root. The app discovers `bank.json` and resolves its `pdfs/` paths relative to this directory. No computer-specific G: drive or separate configuration is required. First-time package installation requires internet access.

The app checks source PDF fingerprints when loading the bank. Keep the files together when copying the project. A custom `STATS125_EXAM_BANK` environment variable overrides the default bank. Clear an obsolete override if it points to another computer's files.

Each available question appears in its module's **3. Optional past-exam questions** section. Its metadata identifies the year, semester, question, source pages and adaptation. See `review/PAST_EXAM_SELECTION.md` for selection details.
