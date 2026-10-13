# 04. Git 이력 수정과 작업 복구

> **학습 목표:** `amend`, `reset --soft`, `revert`, `stash`가 각각 어떤 상태를 바꾸는지 설명하고, 안전한 브랜치에서 실습할 수 있다.
>
> **필요한 시점:** 미션의 Git 트러블슈팅 4종 실습과 기록 작성 시.

## 1. 먼저 구분할 세 가지 대상

```text
Working Tree ──git add──▶ Index ──git commit──▶ Commit (Repository)
실제 작업 파일             다음 커밋 내용          이미 기록된 이력
```

여기에 현재 브랜치의 커밋을 가리키는 **HEAD**가 있다.

```text
A ── B ── C  ← feature/test (HEAD)
```

- `HEAD`: 현재 체크아웃한 커밋. 일반적으로 현재 브랜치가 가리키는 커밋이다.
- `HEAD~1`: HEAD 커밋의 **첫 번째 부모**. 위에서는 B이다.
- `git status`: 작업 전후의 Index·Working Tree 상태를 확인하는 기본 명령.

## 2. `git commit --amend` — 최근 커밋 교체

**상황:** 마지막 커밋 메시지를 잘못 작성했거나, 직전 커밋에 파일을 빠뜨렸다.

```bash
git commit --amend -m "docs: correct profile description"
```

```text
실행 전: A ── B ── C   (잘못된 메시지)
실행 후: A ── B ── C'  (새 메시지의 새 커밋)
```

이 명령은 C의 내용을 제자리에서 수정하는 것이 아니라 **새 커밋 C'로 대체**한다. 커밋 해시가 달라진다.

빠뜨린 파일을 포함하려면 먼저 `git add <파일>` 후 `git commit --amend --no-edit`를 사용할 수 있다. 다만 이때도 새 커밋이 생성된다.

**안전 기준:** 이미 다른 사람이 받아간 커밋이라면 공유 이력 충돌을 유발할 수 있으므로 이번 미션에서는 **Push 전 개인 브랜치 커밋**에만 실습한다.

## 3. `git reset --soft HEAD~1` — 커밋 취소, 변경 유지

**상황:** 방금 만든 로컬 커밋을 취소하고 파일 변경 내용은 다시 커밋하고 싶다.

```bash
git reset --soft HEAD~1
git status
git diff --cached
```

```text
전:  A ── B ── C ← HEAD
후:  A ── B      ← HEAD
              (C의 변경 내용은 Index·Working Tree에 남음)
```

정확히 말하면 `--soft`는 **현재 브랜치 참조(HEAD가 가리키는 커밋 위치)만 이동**한다. Index와 Working Tree는 변경하지 않는다. 이전에 스테이징해 둔 내용이 있으면 그것도 그대로 남는다.

| 옵션 | 브랜치 위치 | Index | Working Tree |
|---|---|---|---|
| `--soft` | 이동 | 그대로 | 그대로 |
| `--mixed` | 이동 | 대상 커밋에 맞춤 | 그대로 |
| `--hard` | 이동 | 대상 커밋에 맞춤 | 대상 커밋에 맞춤 |

`--hard`는 미커밋 작업을 손실시킬 수 있어 **본 미션 실습에 불필요**하다. `reset`으로 참조가 사라진 커밋도 즉시 완전히 삭제되는 것은 아니며, 일정 기간 `reflog`에서 복구할 수 있는 경우가 있다.

**안전 기준:** Push 전 개인 브랜치에서 실행한다. 공유 브랜치의 커밋을 `reset`해 강제 Push하는 방법은 피한다.

## 4. `git revert` — 취소 이력을 새 커밋으로 기록

**상황:** 이미 Push되어 공유된 커밋의 변경 효과를 되돌리고 싶다.

```bash
git revert <commit-hash>
git log --oneline -3
```

```text
A ── B ── C ── D ← HEAD
              └─ D: C의 변경 효과를 되돌리는 새 커밋
```

`revert`는 기존 커밋 C를 이력에서 제거하지 않는다. 그 변경 효과를 취소하는 **새 커밋 D를 추가**한다. 따라서 공유된 이력에 적합하다. 다만 이후 변경과 충돌할 수 있으며, 되돌리려는 커밋이 병합 커밋인 경우 추가 옵션과 판단이 필요하다(이 미션의 최소 범위 밖).

**팀 저장소 실습:** `main` 보호 규칙이 있으므로 **feature 브랜치에 잘못된 커밋을 Push → 같은 브랜치에서 `revert` → 다시 Push → PR에서 두 커밋 확인**처럼 수행한다. 이미 `main`에 병합된 변경을 취소해야 한다면 별도 되돌리기 PR을 만드는 것이 원칙이다.

## 5. `git stash` / `git stash pop` — 작업 임시 보관

**상황:** 수정 도중 다른 브랜치로 이동해야 하지만 아직 커밋하고 싶지 않다.

```bash
git status
git stash push -m "WIP: profile"
git stash list

git switch main
# 다른 작업 확인
git switch feature/profile

git stash pop
git status
```

- `git stash push`: 추적 파일의 Index·Working Tree 변경을 임시 보관하고 작업 상태를 정리한다.
- `git stash push -u`: **미추적 새 파일**도 함께 보관한다. 일반 stash는 미추적 파일을 기본 포함하지 않는다.
- `git stash apply`: 보관 내용을 적용하되 stash 항목은 남긴다.
- `git stash pop`: 보관 내용을 적용하고, **성공하면** stash 항목을 제거한다. 충돌로 실패하면 항목이 남을 수 있다.

주의: 일반 `pop`은 스테이징 상태를 항상 동일하게 복원하지 않는다. 필요한 경우 `--index`를 검토하고 `git status`로 확인한다.

## 6. 문제별 선택 기준

| 내가 처한 상황 | 선택 | 이유 |
|---|---|---|
| 마지막 로컬 커밋 메시지 오타 | `git commit --amend` | 마지막 커밋 교체 |
| 마지막 로컬 커밋을 없애고 다시 묶고 싶다 | `git reset --soft HEAD~1` | 변경을 스테이징 상태로 유지 |
| Push된 잘못된 변경을 취소해야 한다 | `git revert` | 기존 이력을 보존하며 취소 |
| 미완성 작업 때문에 브랜치를 바꾸기 어렵다 | `git stash` | 임시 보관 후 복원 |

### 미션 실습 전후의 최소 점검

```bash
git branch --show-current
git status
git log --oneline -3
# 선택한 명령을 실행한 뒤 다시
git status
git log --oneline -3
```

`main`이나 여러 사람이 작업하는 공유 브랜치에서는 히스토리 재작성(`amend`, `reset` 후 강제 Push)을 하지 않는다. 실습 브랜치는 기능 작업용 브랜치와 분리해도 좋다.

## 7. 트러블슈팅 기록 양식

`docs/troubleshooting-log.md`에 팀 전체 **4개 명령 시나리오 모두** 기록하고, **팀원마다 적어도 1개 기록에 참여**한다.

```md
### 시나리오: reset --soft HEAD~1
- 참여자 / 역할:
- 사전 상태: 브랜치, 최근 커밋, git status
- 목적: 어떤 잘못을 해결하려는가?
- 실행 명령:
- 사후 상태: 커밋 그래프, git status, 파일·스테이징 변화
- 판단: 기대 결과와 실제 결과가 일치했는가?
- 주의사항:
- 증빙 커밋/PR 또는 실행 로그 링크:
```

**확인 질문:** 왜 `amend` 후 해시가 변하는가? `reset --soft`와 `revert` 중 어느 것이 원격 공유 이력에 안전한가? 새 파일까지 stash하려면 어떤 옵션이 필요한가?

## 참고 자료

- [Git Reference — git-commit (`--amend`)](https://git-scm.com/docs/git-commit)
- [Git Reference — git-reset](https://git-scm.com/docs/git-reset)
- [Git Reference — git-revert](https://git-scm.com/docs/git-revert)
- [Git Reference — git-stash](https://git-scm.com/docs/git-stash)
