#!/usr/bin/env bash
# Git/GitHub 팀 협업 미션: STEP 1 초기 파일/폴더 생성
# 사용: Git 저장소 내부에서 bash init-team-repo.sh
# 기존 파일은 덮어쓰지 않으며, commit/push 및 GitHub 설정은 수행하지 않습니다.
set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo 'ERROR: Git이 설치되어 있지 않습니다.' >&2
  exit 1
fi

if ! ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo 'ERROR: Git 저장소 내부에서 실행하세요. (Organization 저장소를 clone한 뒤 실행)' >&2
  exit 1
fi

cd "$ROOT"

# 표준 입력으로 받은 heredoc 내용을 신규 파일에만 기록합니다.
# 파일이 이미 존재한다면 본문을 소비한 후 변경 없이 건너뜁니다.
create_file() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    cat >/dev/null
    printf 'SKIP   %s (기존 파일 유지)\n' "$path"
  else
    cat > "$path"
    printf 'CREATE %s\n' "$path"
  fi
}

mkdir -p .github/ISSUE_TEMPLATE docs src team

create_file 'README.md' <<'EOF'
# 팀 Git 협업 실습

3~5명이 GitHub Flow, PR 리뷰, 충돌 해결, Git 복구 명령을 연습하는 팀 프로젝트입니다.

## 결과물
- 선택 유형: 팀 소개 (`team/`)
- 팀원 소개: 각 팀원의 첫 PR이 병합되면 아래에 링크를 추가합니다.

## 팀원
| GitHub ID | 담당 파일 |
|---|---|
| (작성 예정) | `team/<github-id>.md` |

## 협업 방식
- `main`은 안정적인 상태로 유지합니다.
- 작업은 Issue → `feature/*` 브랜치 → PR → 리뷰·수정 → 승인 → Merge 순서로 진행합니다.
- [협업 규칙](docs/CONTRIBUTING.md)을 따릅니다.
EOF

create_file 'docs/CONTRIBUTING.md' <<'EOF'
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
EOF

create_file '.github/ISSUE_TEMPLATE/task.md' <<'EOF'
---
name: 작업(Task)
about: 팀 미션 작업을 등록합니다.
title: ""
labels: ""
assignees: ""
---

## 목적
<!-- 왜 필요한 작업인가요? -->

## 작업 내용
- [ ]

## 완료 조건
- [ ] PR로 병합되어 있음
- [ ] 검증 내용 또는 결과 링크가 남아 있음
EOF

create_file '.github/PULL_REQUEST_TEMPLATE.md' <<'EOF'
## What (무엇을 변경했는가?)
-

## Why (왜 변경했는가?)
-

## How (어떻게 검증했는가?)
-

## 연결 Issue
Closes #이슈번호

## 리뷰 시 확인할 사항
-
EOF

create_file 'docs/conflict-resolution.md' <<'EOF'
# Git 충돌 해결 기록

팀 전체 2건 이상 작성합니다. 최소 1건은 같은 hunk의 서로 다른 수정 또는 파일 이동/삭제와 내용 수정이 얽힌 비자명 충돌이어야 합니다.

## 사례 1
- 참여자 / 역할:
- Issue / PR 링크:
- 충돌 파일 및 충돌 전 두 브랜치의 차이:
- 재현 절차 및 명령어:
- 충돌 마커 / 에러 메시지:
- 해결 방식과 이유:
- 검증 명령 / 결과:
- 주의점:

## 사례 2
- 참여자 / 역할:
- Issue / PR 링크:
- 충돌 파일 및 충돌 전 두 브랜치의 차이:
- 재현 절차 및 명령어:
- 충돌 마커 / 에러 메시지:
- 해결 방식과 이유:
- 검증 명령 / 결과:
- 주의점:
EOF

create_file 'docs/troubleshooting-log.md' <<'EOF'
# Git 트러블슈팅 실습 기록

네 시나리오 모두 수행합니다. 모든 팀원은 최소 1개 시나리오의 해결 기록에 참여하고 자신의 이름 및 역할을 남깁니다.

실습은 안전한 개인 브랜치에서 수행합니다. 이미 공유된 커밋에 대한 amend/reset 및 무단 강제 Push를 금지합니다.

## 1. git commit --amend (최근 커밋 메시지 수정)
- 참여자 / 역할:
- 발생시킨 상황 / 기대한 복구:
- 재현 절차 및 실제 실행 명령:
- 실행 전 `git log` / `git status`:
- 실행 후 `git log` / `git status`:
- 결과 / 검증:
- 주의점:

## 2. git reset --soft HEAD~1 (로컬 커밋 취소, 변경 유지)
- 참여자 / 역할:
- 발생시킨 상황 / 기대한 복구:
- 재현 절차 및 실제 실행 명령:
- 실행 전 `git log` / `git status`:
- 실행 후 `git log` / `git status`:
- 결과 / 검증:
- 주의점:

## 3. git revert (원격에 Push한 커밋 변경 취소)
- 참여자 / 역할:
- 원격 브랜치와 취소 대상 커밋(해시/링크):
- 발생시킨 상황 / 기대한 복구:
- 재현 절차 및 실제 실행 명령:
- 실행 전 이력 / 파일 내용:
- 실행 후 이력 / 파일 내용:
- 결과 / 검증:
- 주의점:

## 4. git stash / git stash pop (작업 임시 보관·복원)
- 참여자 / 역할:
- 발생시킨 상황 / 기대한 복구:
- 재현 절차 및 실제 실행 명령:
- 실행 전 `git status` / 작업 내용:
- 실행 후 `git status` / 복원 확인:
- 결과 / 검증:
- 주의점:
EOF

create_file 'SUBMISSION.md' <<'EOF'
# 팀 미션 제출물 인덱스

- GitHub 저장소 URL: (작성 예정)
- 결과물 유형: 팀 소개
- Git 히스토리 증빙: (텍스트 파일 또는 스크린샷 링크 예정)

## 팀원별 Issue / PR / 리뷰 및 기여
| GitHub ID | 본인 Issue 링크 | 병합 PR 2개 이상 | 타인 PR 리뷰 2개 이상 | 피드백 반영 링크 | 결과물 커밋 | 트러블슈팅 참여 |
|---|---|---|---|---|---|---|
| (작성 예정) | | | | | | |

## 문서 및 결과물
- [협업 가이드](docs/CONTRIBUTING.md)
- [충돌 해결 2건](docs/conflict-resolution.md)
- [Git 트러블슈팅 4종](docs/troubleshooting-log.md)
- [README 및 팀 소개](README.md)

## 최종 확인
- [ ] 전원 PR 2개 이상 생성·병합
- [ ] 전원 타인 PR 실질 리뷰 2개 이상
- [ ] 전원 본인 PR의 피드백 반영 1회 이상
- [ ] 전원 결과물 기여 커밋 1개 이상
- [ ] 전원 트러블슈팅 기록 최소 1건 참여
- [ ] 충돌 2건(비자명 충돌 최소 1건 포함)
- [ ] 트러블슈팅 4종 전체 완료
- [ ] `git log --oneline --graph --all` 증빙 확보
EOF

create_file '.gitignore' <<'EOF'
# macOS / editor
.DS_Store
.vscode/
.idea/

# Python (유틸 함수 결과물 선택 시에도 사용 가능)
__pycache__/
*.py[cod]
.venv/
venv/
.pytest_cache/

# secrets
.env
.env.*
!.env.example
EOF

create_file 'src/.gitkeep' <<'EOF'
EOF

create_file 'team/.gitkeep' <<'EOF'
EOF

cat <<'EOF'

파일 생성 완료. 다음 작업은 자동 실행하지 않았습니다.
  1. README.md의 결과물 유형과 docs/CONTRIBUTING.md의 규칙을 팀에서 확인
  2. git status
  3. git add . && git commit -m "chore: initialize team repository"
  4. git push -u origin main
  5. GitHub Settings에서 main 보호 규칙(직접 Push 금지/PR/승인 1명) 설정
  6. 팀원 각자가 Issue -> feature Branch -> PR -> Review -> Merge 실습

참고: .github/CODEOWNERS는 1차 PR 병합이 끝난 뒤 팀에서 정해 추가합니다.
EOF
