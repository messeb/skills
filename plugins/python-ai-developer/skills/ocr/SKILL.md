---
description: OCR and document extraction in Python — choosing between Tesseract, PaddleOCR, docTR, Surya, cloud OCR services, and vision-language models; the preprocessing that determines accuracy; PDF handling (text layer vs raster); layout, tables, and reading order; the OCR-then-LLM pipeline; measuring character and word error rate; performance and cost; and a decision table per document class.
---

# OCR and document extraction

Goal of this skill: get accurate, structured data out of scans and PDFs by choosing the right engine per document class and fixing the input before blaming the model.

Use this skill for invoices, forms, contracts, IDs, receipts, handwriting, and archive scans.

---

## 1. First: is it actually a scan?

A large share of "OCR problems" are PDFs that already contain text.

```python
import pymupdf                       # PyMuPDF

doc = pymupdf.open(path)
page = doc[0]
text = page.get_text()
if len(text.strip()) > 50:
    ...                              # digital PDF — extract directly, no OCR
else:
    ...                              # scanned — rasterise and OCR
```

Rule: **always try the text layer first.** It is free, instant, and exact. Rasterising a digital PDF and OCR-ing it throws away perfect data and introduces errors. Note that some PDFs have a *partial* text layer (a scanned page inserted into a digital document) — decide per page, not per document.

---

## 2. Choosing an engine

| Engine | Type | Strengths | Weaknesses |
|--------|------|-----------|------------|
| **Tesseract** (`pytesseract`) | Classical, local | Free, mature, 100+ languages, fast on clean text | Poor on noisy scans, layout, and handwriting; very sensitive to preprocessing |
| **PaddleOCR** | Deep learning, local | Strong accuracy, good detection, table and layout models, CJK excellent | Heavier install; version churn |
| **docTR** | Deep learning, local | Clean PyTorch/TF API, good detection + recognition split | Smaller ecosystem |
| **Surya** | Deep learning, local | Strong layout, reading order, and multilingual line detection | GPU strongly preferred |
| **EasyOCR** | Deep learning, local | Simple API, many languages | Slower; weaker on dense documents |
| **Cloud OCR** (AWS Textract, Google Document AI, Azure Document Intelligence) | Managed | Best-in-class on forms, tables, key-value pairs; handwriting | Cost per page; data leaves your perimeter |
| **Vision-language models** (the providers in `llm-providers`) | Managed LLM | Handles messy layouts, reasons about content, outputs structure directly | Hallucinates plausible values; per-page cost; no character-level confidence |

### Decision table by document class

| Document | Start with |
|----------|-----------|
| Digital PDF | Text layer extraction — no OCR |
| Clean printed scan, one language | Tesseract; escalate to PaddleOCR if CER is too high |
| Dense multi-column layout, reading order matters | Surya or PaddleOCR layout models |
| Forms and key-value documents at volume | Cloud document AI (purpose-built, usually cheapest per correct field) |
| Tables that must retain structure | Cloud table extraction, or PaddleOCR table models |
| Handwriting | Cloud OCR; local engines remain weak |
| Low volume, high variability, messy layouts | A vision-language model with provenance requirements |
| Regulated data that cannot leave the perimeter | Local engines only — this constraint outranks accuracy |

**The default worth trying first**: text layer → local engine → cloud/VLM escalation only for pages that fail a confidence or validation threshold. This keeps the per-page cost near zero for the common case.

---

## 3. Preprocessing decides accuracy

For classical engines, preprocessing usually moves accuracy more than switching engines.

```python
import cv2, numpy as np

def preprocess(img: np.ndarray) -> np.ndarray:
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray = cv2.fastNlMeansDenoising(gray, h=10)
    gray = deskew(gray)                                   # angle from minAreaRect / Hough
    return cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                 cv2.THRESH_BINARY, 31, 11)
```

| Step | Why |
|------|-----|
| **300 DPI rasterisation** | The single biggest factor for Tesseract; 150 DPI roughly doubles the error rate |
| Deskew | A 2° tilt breaks line segmentation |
| Denoise | Removes scanner speckle that becomes phantom characters |
| Adaptive threshold | Handles uneven lighting and shadowed photos |
| Crop to the content region | Removes borders and staple marks |
| Correct orientation | A sideways page yields nothing usable |
| **Do not** upscale beyond the source resolution | Interpolated pixels add no information |

Deep-learning engines are far less preprocessing-sensitive; rasterisation DPI and orientation still matter.

---

## 4. Pipeline shape

```text
ingest → per-page classify (text layer? orientation? language?)
       → rasterise (300 DPI) if needed
       → preprocess
       → detect layout / regions
       → recognise text (+ confidence, + bounding boxes)
       → post-process (dictionary, regex repair, checksum validation)
       → structure (LLM extraction with provenance)
       → validate (business rules) → route low confidence to review
```

Keep **bounding boxes and per-token confidence** from the engine all the way through. They are what let you highlight a value in the UI, verify provenance, and route uncertain pages to human review. An OCR pipeline that discards coordinates cannot be audited.

### OCR-then-LLM

The strongest general pattern: a local engine produces text and coordinates cheaply; a model turns that text into structured records.

```python
async def extract_invoice(pdf: bytes) -> Invoice:
    pages = await to_images(pdf, dpi=300)
    ocr = [await run_ocr(p) for p in pages]                    # text + boxes + confidence
    text = "\n".join(p.text for p in ocr)
    invoice = await llm.parse(text, schema=Invoice)            # structured-output
    verify_provenance(invoice, text)                           # every value must be quotable
    return invoice
```

Why this beats sending page images to a VLM directly, for most production cases: it is far cheaper per page, the OCR output is auditable, and character-level confidence exists. Send the **image** to a VLM when layout carries meaning that flat text loses (stamps, checkboxes, signatures, handwritten annotations, complex tables) — and then require provenance anyway, because a VLM will produce a plausible invoice number for a blank page.

---

## 5. Post-processing

| Technique | Fixes |
|-----------|-------|
| Domain dictionary / fuzzy match against known values | Customer and product names |
| Regex + checksum validation (IBAN, VAT id, EAN) | Detects and often locates OCR digit errors |
| Character confusion repair in numeric fields (`O↔0`, `l↔1`, `S↔5`, `B↔8`) | The dominant OCR error class |
| Cross-field arithmetic (line items sum to total) | Catches a single wrong digit reliably |
| Confidence thresholding per field | Routes uncertain values to review instead of silently accepting |

Never "repair" a value the model or engine was uncertain about without recording that you did.

---

## 6. Measuring

Build a ground-truth set of 50–100 pages per document class and measure:

| Metric | Definition |
|--------|-----------|
| **CER** | Character error rate — edit distance ÷ character count |
| **WER** | Word error rate |
| **Field accuracy** | Per extracted field — the metric the business cares about |
| **Hallucination rate** | Values not supported by the source text |
| **Review rate** | Share of pages routed to a human |
| Cost and latency per page | Per engine, for the escalation decision |

Evaluate the **whole pipeline**, not the engine alone — preprocessing and post-processing changes move field accuracy more than engine swaps. Re-measure when any stage changes (`llm-testing-and-evals`).

---

## 7. Performance and operations

- OCR is **CPU-bound**: run it in a worker process pool or a dedicated worker container, never on the event loop (`async-and-background-work`).
- Rasterising is memory-hungry — process page by page and stream; a 500-page PDF rendered at once will exhaust the container.
- Cap page count and file size at the API boundary (`fastapi`); expansion attacks are real.
- Cache by content hash — the same document arrives repeatedly in most systems.
- Ship system dependencies explicitly in the image (`tesseract-ocr`, language packs, `poppler-utils`); a missing language pack fails silently as garbage output, not as an error (`containerization`).
- Personal data: scans contain identity documents. Encrypt at rest, set retention, and keep them out of logs.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| OCR-ing a PDF that has a text layer | Errors introduced into perfect data |
| Rasterising below 300 DPI for classical OCR | Error rate roughly doubles |
| Skipping deskew and orientation | Line segmentation fails; output is unusable |
| Discarding confidences and bounding boxes | No review routing, no provenance, no UI highlighting |
| Trusting VLM output without provenance | Plausible invented values on blank or unreadable pages |
| One engine for every document class | Paying cloud prices for clean text, or failing on handwriting |
| Loading whole PDFs into memory | Container OOM on large documents |
| Running OCR on the event loop | The API stalls for every concurrent user |
| Language pack missing from the image | Silent garbage output, no error |
| No ground-truth set | Accuracy claims are guesses; regressions invisible |
| Scans retained indefinitely | Identity documents accumulating past policy |

---

## 9. Checklist

- [ ] Text layer checked per page before any OCR
- [ ] Engine chosen per document class, with a documented escalation path
- [ ] Data-residency constraints checked before considering cloud OCR or VLMs
- [ ] Rasterisation at 300 DPI; deskew, denoise, threshold, orientation applied
- [ ] Bounding boxes and per-token confidence retained end to end
- [ ] Structured extraction requires verifiable provenance
- [ ] Post-processing: checksums, dictionaries, cross-field arithmetic
- [ ] Confidence thresholds route uncertain fields to human review
- [ ] Ground-truth set per document class; CER/WER and field accuracy measured on the whole pipeline
- [ ] OCR runs in worker processes; pages streamed, not batched into memory
- [ ] Page count and file size capped at the API boundary
- [ ] Results cached by content hash
- [ ] System dependencies and language packs pinned in the image
- [ ] Encryption at rest, retention policy, and no document content in logs
