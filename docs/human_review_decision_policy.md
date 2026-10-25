\# Human Review Decision Policy



\## Purpose



This document defines how the Healthcare Document Intelligence RAG system decides whether retrieved evidence can support an automatic operational answer, requires human review, or should be rejected.



The objective is not to maximise answer volume.



The objective is to provide useful operational evidence while maintaining clear boundaries, traceability, lifecycle control, and human accountability.



\---



\## Decision Outcomes



The system supports three decision outcomes:



1\. AUTO\_ANSWER

2\. REVIEW\_REQUIRED

3\. ABSTAIN



\---



\# 1. AUTO\_ANSWER



AUTO\_ANSWER means the system has sufficient approved evidence to generate a grounded operational response without mandatory human review.



An AUTO\_ANSWER decision should only be made when:



\- the user question is within the approved operational-policy scope;

\- retrieved evidence comes from Active documents;

\- relevant evidence has been retrieved;

\- there is no known lifecycle conflict;

\- there is no significant ambiguity between multiple competing documents;

\- the question does not request prohibited clinical or prescribing advice;

\- the question does not require live external information;

\- the answer can be grounded directly in retrieved evidence;

\- citations can be provided.



Example:



> What operational guidance applies during severe winter pressure?



If the Active Winter Pressure Plan is retrieved with strong relevant evidence, the question may be eligible for AUTO\_ANSWER.



\---



\# 2. REVIEW\_REQUIRED



REVIEW\_REQUIRED means the question is within scope and some relevant evidence exists, but the system should not automatically present the result as authoritative without human inspection.



Human review may be required when:



\- several documents provide plausible but different guidance;

\- retrieved evidence is ambiguous;

\- the top retrieval result is not clearly stronger than alternatives;

\- cross-document reasoning is required;

\- a lifecycle conflict is detected;

\- operational guidance may have significant organisational consequences;

\- evidence appears incomplete;

\- retrieved documents contain potentially conflicting instructions;

\- the system cannot confidently identify one authoritative source.



Example:



> What responsibilities belong to operational leadership during a period of pressure?



Several operational or governance documents may plausibly contain relevant responsibilities.



The question is not necessarily unsafe, but the evidence may require human confirmation.



\---



\# 3. ABSTAIN



ABSTAIN means the system should not attempt to generate a substantive answer from the available corpus.



The system should abstain when:



\- the query is outside the approved operational scope;

\- the user requests medication or prescribing advice;

\- the user requests antibiotic dosing;

\- the question requires current external information not contained in the corpus;

\- no eligible Active evidence is available;

\- retrieval produces no acceptable evidence;

\- available evidence is insufficient to support the requested conclusion.



Example:



> What antibiotic dose should be used for a patient with sepsis?



This question is outside the approved operational-policy scope.



The system should return ABSTAIN rather than retrieving a loosely related infection-control document.



\---



\# Decision Hierarchy



The decision hierarchy should be conservative.



\## Step 1 — Scope



If the query is out of scope:



ABSTAIN



Do not continue to normal retrieval-based answering.



\---



\## Step 2 — Evidence Availability



If the query is in scope but no eligible evidence is retrieved:



ABSTAIN



\---



\## Step 3 — Lifecycle Safety



Evidence from Draft, Superseded, or Archived documents must not be treated as normal authoritative evidence.



If lifecycle ambiguity cannot be resolved automatically:



REVIEW\_REQUIRED



\---



\## Step 4 — Evidence Clarity



If one clearly relevant Active source supports the query:



AUTO\_ANSWER may be permitted.



If several plausible sources exist and authority is unclear:



REVIEW\_REQUIRED



\---



\## Step 5 — Cross-Document Reasoning



Questions that explicitly require combining multiple operational domains should normally receive:



REVIEW\_REQUIRED



until the system has stronger evidence-combination and verification controls.



\---



\# Initial Conservative Rules



The first implementation should deliberately favour safety over automation.



\### AUTO\_ANSWER



Possible when:



\- query is in scope;

\- at least one eligible result exists;

\- all returned evidence used for answering is Active;

\- the expected operational topic is clearly represented;

\- no explicit cross-document requirement exists;

\- no lifecycle ambiguity is present.



\### REVIEW\_REQUIRED



Use when:



\- query is in scope;

\- evidence exists;

\- multiple operational domains must be combined;

\- source authority is ambiguous;

\- evidence is incomplete or potentially conflicting;

\- a lifecycle-sensitive case requires confirmation.



\### ABSTAIN



Use when:



\- query is out of scope;

\- no eligible evidence exists;

\- the question requires unsupported clinical advice;

\- the question requires unsupported live/current external information.



\---



\# Human Reviewer Responsibilities



A human reviewer should be able to inspect:



\- original user question;

\- decision outcome;

\- decision reason;

\- retrieved document IDs;

\- document titles;

\- document versions;

\- document status;

\- relevant chunks;

\- retrieval scores;

\- citations;

\- any lifecycle warning;

\- any scope warning.



The reviewer should then be able to:



\- approve;

\- reject;

\- override;

\- request better evidence;

\- escalate to the appropriate operational owner.



\---



\# Auditability



Every decision should eventually record:



\- query ID;

\- question;

\- timestamp;

\- scope decision;

\- evidence used;

\- document lifecycle status;

\- retrieval method;

\- decision outcome;

\- decision reason;

\- reviewer action, if applicable.



This allows the system to demonstrate why an answer was automated, reviewed, or rejected.



\---



\# Governance Principle



The system is an operational evidence assistant.



It is not an autonomous decision-maker.



Human accountability remains with the authorised NHS operational or governance professional.



The system should prefer:



transparent uncertainty



over



unsupported confidence.

