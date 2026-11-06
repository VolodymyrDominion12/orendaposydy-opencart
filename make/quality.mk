# ---------------------------------------------------------------------------
# Цілі якості: міграції БД, аудит схеми, EXPLAIN, профіль запитів, lint PHP 7.3 + 8.3,
# smoke і мобільний аудит. Правила — AGENTS.md §4–8.
#
# Підключається з Makefile одним рядком (наприкінці файлу):
#   include make/quality.mk
# ---------------------------------------------------------------------------

.PHONY: lint test-smoke test-mobile mobile-setup verify \
        core-report core-apply core-verify core-package core-prod-remove core-rollback \
        db-check db-schema-snapshot db-schema-diff db-explain db-profile \
        migrate migrate-status migrate-down migrate-print migrate-new

# ===========================================================================
# Міграції БД (db/migrations)
# ===========================================================================
migrate: ## Застосувати очікувані міграції (V=NNNN — до цієї версії)
	@bash tools/migrate.sh up $(V)

migrate-status: ## Які міграції застосовані / очікують
	@bash tools/migrate.sh status

migrate-down: ## Відкотити міграцію: make migrate-down V=0001
	@test -n "$(V)" || { echo "  Вкажіть версію: make migrate-down V=0001"; exit 1; }
	@bash tools/migrate.sh down $(V)

migrate-print: ## SQL міграції для phpMyAdmin на прод: make migrate-print V=0002 > /tmp/m.sql
	@test -n "$(V)" || { echo "  Вкажіть версію: make migrate-print V=0002" >&2; exit 1; }
	@bash tools/migrate.sh print $(V)

migrate-new: ## Створити міграцію з шаблону: make migrate-new NAME=kristal_redirect
	@test -n "$(NAME)" || { echo "  Вкажіть назву: make migrate-new NAME=kristal_redirect"; exit 1; }
	@bash tools/migrate.sh new "$(NAME)"

# ===========================================================================
# Якість: БД, запити, тести
# ===========================================================================
db-check: ## Аудит індексів/PK/рушіїв проти baseline (UPDATE=1 — прийняти поточний стан)
	@bash tools/db-check.sh

db-schema-snapshot: ## Записати поточну схему в db/schema.sql
	@bash tools/db-schema.sh snapshot

db-schema-diff: ## Порівняти схему бази зі знімком db/schema.sql
	@bash tools/db-schema.sh diff

db-explain: ## EXPLAIN із підсвіткою: make db-explain SQL="SELECT ..." або FILE=x.sql
	@bash tools/db-explain.sh

db-profile: ## Запити БД однієї сторінки: make db-profile URL=/mebli [BUDGET=100 MAXMS=50]
	@bash tools/db-profile.sh

lint: ## Перевірка PHP під 7.3 (прод) + 8.3 (наперед) (змінені файли; ALL=1 — усі наші)
	@bash tools/lint-php.sh

test-smoke: ## Smoke вітрини з tests/smoke/ (BASE=https://... — інший сайт)
	@bash tools/test-smoke.sh

test-mobile: ## Мобільний аудит: CWV, вага, 360px, тач-зони, зображення (URL=/x — одна сторінка)
	@bash tools/test-mobile.sh

mobile-setup: ## Один раз: встановити Playwright + Chromium для test-mobile
	@bash tools/test-mobile.sh --setup

verify: ## Усі перевірки перед «готово»: lint + db-check + схема + міграції + smoke + мобільний
	@bash tools/verify.sh

# ===========================================================================
# Оновлення ядра OpenCart 3.0.3.2 → 3.0.4.1 (фіча 018). Без APPLY=1 — лише показ.
# ===========================================================================
core-report: ## 018: звіт src/ проти ядра 3.0.4.1 → specs/018-platform-upgrade/core-report.md
	@bash tools/core-upgrade.sh report

core-apply: ## 018: бекап + ядро 3.0.4.1 + vendor + видалення залишків (APPLY=1)
	@APPLY=$(APPLY) bash tools/core-upgrade.sh apply

core-verify: ## 018: перевірити, що src/ = ядро 3.0.4.1 і vendor на місці
	@bash tools/core-upgrade.sh verify

core-package: ## 018: ZIP ядра + vendor для файлового менеджера cPanel
	@bash tools/core-upgrade.sh package

core-prod-remove: ## 018: видалити залишки на проді через FTP (APPLY=1)
	@APPLY=$(APPLY) bash tools/core-upgrade.sh prod-remove

core-rollback: ## 018: повернути код src/ з бекапу: make core-rollback BK=backups/core-018-….tar.gz APPLY=1
	@BK=$(BK) APPLY=$(APPLY) bash tools/core-upgrade.sh rollback
