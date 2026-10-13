# 협업 규칙

## 1. 브랜치
- 기본 브랜치: `main` (직접 Push 금지)
- 작업 브랜치: `feature/<issue-number>-<short-description>`
- 최신 `main`에서 분기하여 작업합니다.

## 2. 커밋 메시지
- 형식: `<type>: <구체적인 변경 내용>`
- 타입 예: `feat`, `fix`, `docs`, `refactor`, `chore`
- 좋은 예: `docs: add member profile`
- 금지 예: `update`, `fix`, `temp`, `final`

## 3. Issue 및 PR
1. 모든 작업은 Issue를 먼저 만듭니다.
2. feature 브랜치에서 Commit하고 Push합니다.
3. PR 본문에 What(변경), Why(이유), How(검증)를 적습니다.
4. `Closes #<issue-number>`로 해당 Issue를 연결합니다.
5. 타인의 실질적 리뷰와 작성자 상호작용(답글 또는 수정)을 남깁니다.
6. 최소 1명의 Approve 후 `main`으로 병합합니다.

## 4. 리뷰 규칙
- 각 PR에 구체적인 질문, 개선 제안, 리스크 지적 등의 실질 코멘트를 1개 이상 남깁니다.
- 작성자는 코멘트에 답하거나 수정 후 이를 설명합니다.
- 단순 `LGTM`, `좋아요`만으로는 실질 코멘트 조건을 충족하지 않습니다.

## 5. 충돌 대응
- 충돌을 겪은 PR 작성자가 상황을 공유하고, 관련 팀원과 해결 방향을 확인합니다.
- 충돌 원인·재현 절차·해결 명령·검증 결과를 `docs/conflict-resolution.md`에 기록합니다.
- 공유 브랜치의 강제 Push 및 무단 히스토리 재작성은 금지합니다.

## 6. GitHub 설정 (관리자 확인)
- `main`: PR 병합 필수, Approve 최소 1명, 직접 Push 금지
- 보호 규칙과 관리자 우회 여부는 GitHub Settings에서 별도로 확인합니다.
