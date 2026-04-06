# 30-Day Optimization Plan (Ruby SDK)

## Outcome Target

- Deliver a polished Ruby SDK that is easy to adopt, predictable in production, and validated with measurable gates.
- Keep first API success under 10 minutes and first SSE integration under 30 minutes.

## P0 (Day 1-14): Reliability and Contract Hardening

| Workstream | Task | Files | Acceptance |
| --- | --- | --- | --- |
| API Contract Alignment | Align methods/paths with backend contract and docs | `lib/ai_sandbox_sdk/client.rb`, `openapi/ai-sandbox-v1.yaml`, `docs/INTEGRATION.md` | 11 API operations validated with no mismatch |
| Safe Retry Policy | Keep default retries safe for write operations and document controls | `lib/ai_sandbox_sdk/client.rb`, `README.md` | No duplicate non-idempotent writes in fault test |
| Error Observability | Standardize API error usage and troubleshooting guidance | `lib/ai_sandbox_sdk/api_error.rb`, `README.md`, `docs/INTEGRATION.md` | Error guide includes status/body troubleshooting path |
| QA Baseline | Add tests for retries, stream parser behavior, and payload serialization | `lib/**/*.rb`, `test/*` (new), `ai-sandbox-sdk-ruby.gemspec` | CI tests pass with critical-path coverage target |
| CI/CD Guardrails | Add workflow for lint/test/build release gates | `.github/workflows/ci.yml` (new), `*.gemspec` | PR checks required before merge |

## P1 (Day 15-30): Developer Experience and Growth

| Workstream | Task | Files | Acceptance |
| --- | --- | --- | --- |
| Example Expansion | Extend quickstart to full path including SSE and KB calls | `examples/quickstart.rb`, `README.md` | Example runs with env vars only |
| Visual Docs Upgrade | Add troubleshooting matrix and operational playbook | `README.md`, `docs/INTEGRATION.md` | Reduced onboarding questions in pilot phase |
| Release Quality | Add release checklist and compatibility notes | `CHANGELOG.md`, `CONTRIBUTING.md` | Every release includes impact summary |
| Security Posture | Add secret/dependency scanning in workflow | `.github/workflows/ci.yml`, `SECURITY.md` | No unresolved high-severity issue at release gate |

## Language File Checklist

- `README.md`
- `docs/INTEGRATION.md`
- `docs/30D_OPTIMIZATION_PLAN.md`
- `lib/ai_sandbox_sdk/client.rb`
- `lib/ai_sandbox_sdk/api_error.rb`
- `lib/ai_sandbox_sdk.rb`
- `examples/quickstart.rb`
- `openapi/ai-sandbox-v1.yaml`
- `ai-sandbox-sdk-ruby.gemspec`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `SECURITY.md`

## Definition of Done (DoD)

- [ ] 11/11 API operations pass production integration validation.
- [ ] SSE helper parses chunk events and ends on `[DONE]`.
- [ ] Retry defaults avoid duplicate non-idempotent write operations.
- [ ] CI pipeline enforces lint + test + package quality gates.
- [ ] Quickstart runs from clean environment with required env vars only.
