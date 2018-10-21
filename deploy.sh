#!/usr/bin/env bash

# .secrets staging area에 추가
git add -A
git add -f .secrets

# eb deploy 실행
eb deploy --profile fc-8th-eb --staged

# .secrets staging area에서 제거
git reset HEAD .secrets
git reset

