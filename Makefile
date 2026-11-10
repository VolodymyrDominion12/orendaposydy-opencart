# ---------------------------------------------------------------------------
# Локальна розробка OpenCart: orendaposydy.com
#
# Швидкий старт (після того, як забрали файли й дамп із хостингу):
#   make init      # створити .env (із вашими UID/GID)
#   make up        # підняти середовище
#   make import    # залити дамп із dumps/ і локалізувати
#
# Далі:  http://localhost:8090/
# ---------------------------------------------------------------------------

SHELL := /bin/bash
.DEFAULT_GOAL := help

B := \033[1m
N := \033[0m

.PHONY: help init up down destroy restart build ps logs logs-php logs-db shell db-shell \
        config localize-htaccess localize localize-admin login-admin \
        import dump db-tables \
        clear-cache clear-cache-all refresh-mods images-warm \
        deploy deploy-apply deploy-sql deploy-rollback package backup-list \
        sec-status sec-cleanup sec-rename-admin sec-retire-online sec-restore \
        backup-install backup-status backup-pull \
        check php-version url

# ===========================================================================
# Довідка
# ===========================================================================
help: ## Показати цю довідку
	@printf '$(B)Локальна розробка OpenCart — orendaposydy.com$(N)\n\n'
	@printf 'Стек: PHP 7.4 + Apache, MariaDB 10.6, Adminer, Mailpit\n\n'
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@printf '\n$(B)Типовий день:$(N)\n'
	@printf '  make up && make logs-php           # підняти й дивитись логи\n'
	@printf '  # ... правите файли в src/ ...\n'
	@printf '  make clear-cache                   # якщо правки у .twig/CSS не видно\n'
	@printf '  make deploy                        # подивитись, що поїде на прод\n'
	@printf '  make deploy-apply                  # залити\n\n'

# ===========================================================================
# Налаштування
# ===========================================================================
init: ## Створити .env з шаблону (з вашими UID/GID)
	@if [ -f .env ]; then \
		echo "  .env уже існує — не чіпаю."; \
	else \
		cp .env.example .env; \
		sed -i "s/^HOST_UID=.*/HOST_UID=$$(id -u)/; s/^HOST_GID=.*/HOST_GID=$$(id -g)/" .env; \
		chmod 600 .env; \
		echo "  Створено .env (HOST_UID=$$(id -u), HOST_GID=$$(id -g))"; \
	fi
	@mkdir -p dumps backups src
	@echo "  Теки src/, dumps/ і backups/ готові."

up: ## Підняти середовище
	docker compose up -d
	@echo ""
	@echo "  Вітрина:  http://localhost:$$(grep -E '^WEB_PORT=' .env 2>/dev/null | cut -d= -f2 || echo 8090)/"
	@echo "  Адмінка:  http://localhost:$$(grep -E '^WEB_PORT=' .env 2>/dev/null | cut -d= -f2 || echo 8090)/admin/"
	@echo "  База:     http://localhost:$$(grep -E '^ADMINER_PORT=' .env 2>/dev/null | cut -d= -f2 || echo 8091)/"
	@echo "  Пошта:    http://localhost:$$(grep -E '^MAILPIT_UI_PORT=' .env 2>/dev/null | cut -d= -f2 || echo 8026)/"

down: ## Зупинити середовище (дані зберігаються)
	docker compose down

destroy: ## Зупинити й ВИДАЛИТИ базу даних (обережно!)
	@printf 'Це видалить локальну базу даних. Продовжити? [y/N] '; \
	read -r a; case "$$a" in [yY]*) docker compose down -v ;; *) echo "  Скасовано." ;; esac

restart: ## Перезапустити контейнери
	docker compose restart
	@echo "  Перезапущено."

build: ## Перезібрати образ PHP (після правки docker/Dockerfile або docker/make-config.sh)
	docker compose build

ps: ## Стан контейнерів
	@docker compose ps

logs: ## Логи всіх сервісів (потоком)
	docker compose logs -f --tail=100

logs-php: ## Логи PHP/Apache
	docker compose logs -f --tail=100 web

logs-db: ## Логи бази даних
	docker compose logs -f --tail=100 db

shell: ## Bash у контейнері з PHP
	docker compose exec web bash

db-shell: ## Консоль MySQL
	@bash tools/db-shell.sh

# ===========================================================================
# Конфігурація OpenCart
# ===========================================================================
config: ## Перегенерувати локальні config.php і локалізувати .htaccess
	@bash tools/localize-htaccess.sh
	@bash tools/make-config.sh

localize-htaccess: ## Прибрати з src/.htaccess бойові правила (HTTPS-редирект на прод)
	@bash tools/localize-htaccess.sh

localize: ## Застосувати локалізацію до бази (пошта, платежі, SSL)
	@bash tools/localize-db.sh

localize-admin: ## Те саме + локальний пароль адміністратора
	@bash tools/localize-db.sh --admin

login-admin: ## Показати логін і пароль локального адміністратора
	@bash tools/show-admin.sh

# ===========================================================================
# База даних
# ===========================================================================
import: ## Імпортувати дамп із прода (найновіший у dumps/)
	@bash tools/import-db.sh

dump: ## Зняти дамп локальної бази в dumps/
	@bash tools/dump-db.sh

db-tables: ## Показати таблиці в локальній базі
	@bash tools/db-tables.sh

# ===========================================================================
# Файли й кеш
# ===========================================================================
clear-cache: ## Скинути кеш OpenCart (Twig + дані + прев'ю)
	@bash tools/clear-cache.sh

clear-cache-all: ## Скинути кеш + кеш OCMOD (потім обов'язково make refresh-mods!)
	@bash tools/clear-cache.sh --modifications --logs
	@printf '\n  Модифікації стерто. Повернути на місце:  make refresh-mods\n'

images-warm: ## 020: згенерувати WebP усіх розмірів теми для товарів і категорій (локально/staging)
	@bash tools/images-warm.sh

refresh-mods: ## Застосувати OCMOD-модифікації (те саме, що «Оновити» в адмінці)
	@bash tools/refresh-modifications.sh

# ===========================================================================
# Деплой на прод
# ===========================================================================
deploy: ## Показати, що поїде на прод (нічого не змінює; HTACCESS=1 — разом із .htaccess)
	@bash tools/deploy.sh $(if $(FILES),--files "$(FILES)") $(if $(SINCE),--since "$(SINCE)") $(if $(HTACCESS),--include-htaccess)

deploy-apply: ## Залити зміни на прод (з бекапом і підтвердженням; HTACCESS=1 — разом із .htaccess)
	@bash tools/deploy.sh --apply $(if $(FILES),--files "$(FILES)") $(if $(SINCE),--since "$(SINCE)") $(if $(CLEAR_CACHE),--clear-cache) $(if $(HTACCESS),--include-htaccess)

deploy-sql: ## Підготувати SQL-файл для phpMyAdmin: make deploy-sql SQL=tools/sql/x.sql
	@test -n "$(SQL)" || { echo "  Вкажіть файл: make deploy-sql SQL=tools/sql/02-mail-to-mailpit.sql"; exit 1; }
	@bash tools/deploy.sh --sql "$(SQL)"

deploy-rollback: ## Відкотити деплой: make deploy-rollback DIR=backups/2026-11-05-1200
	@test -n "$(DIR)" || { echo "  Вкажіть теку: make deploy-rollback DIR=backups/<дата>"; echo "  Наявні:"; ls -1t backups/ 2>/dev/null | head; exit 1; }
	@bash tools/deploy.sh --rollback "$(DIR)" --apply

package: ## Зібрати ZIP зі змінами для файлового менеджера панелі
	@bash tools/package-release.sh $(if $(FILES),--files "$(FILES)") $(if $(SINCE),--since "$(SINCE)")

# --- 017: безпека проду (за замовчуванням dry-run; APPLY=1 — виконати з підтвердженням YES) ---
sec-status: ## 017: стан проду — install/, архіви, адмінка, стара тека (лише читання)
	@bash tools/prod-security.sh status

sec-cleanup: ## 017: install/, index1.php, архіви з кореня сайту → ~/kristal-trash/ (APPLY=1)
	@bash tools/prod-security.sh cleanup $(if $(APPLY),--apply)

sec-rename-admin: ## 017: перейменувати адмінку на проді (APPLY=1 [NAME=kr-xxxx] [UNDO=1])
	@bash tools/prod-security.sh rename-admin $(if $(APPLY),--apply) $(if $(NAME),--name "$(NAME)") $(if $(UNDO),--undo)

sec-retire-online: ## 017: стару теку orendaposudu.online → ~/kristal-trash/ (APPLY=1)
	@bash tools/prod-security.sh retire-online $(if $(APPLY),--apply)

sec-restore: ## 017: повернути зі смітника: make sec-restore P=kristal-trash/<дата>/site/install APPLY=1
	@test -n "$(P)" || { echo "  Вкажіть шлях: make sec-restore P=kristal-trash/<дата>/site/<ім'я>"; exit 1; }
	@bash tools/prod-security.sh restore "$(P)" $(if $(APPLY),--apply)

backup-install: ## 017: залити скрипт бекапу на хостинг (~/kristal-backup/) і показати рядок cron
	@bash tools/backup.sh install

backup-status: ## 017: що є в бекапах на хостингу + журнал
	@bash tools/backup.sh status

backup-pull: ## 017: найновіший дамп бази з хостингу → dumps/ (FILES=1 — і архів файлів), далі make import
	@bash tools/backup.sh pull $(if $(FILES),--files)

backup-list: ## Показати наявні бекапи
	@ls -1t backups/ 2>/dev/null | head -20 || echo "  Бекапів немає."

# ===========================================================================
# Діагностика
# ===========================================================================
check: ## Перевірити, що середовище здорове
	@bash tools/check-env.sh

php-version: ## Показати версії PHP, MariaDB і розширень
	@docker compose exec -T web php -v | head -2
	@echo ""
	@docker compose exec -T db mariadb --version
	@docker compose exec -T web php -m | tr '\n' ' ' | fold -w 100 -s

url: ## Показати адреси локальних сервісів
	@printf '  Вітрина:   http://localhost:%s/\n' "$$(grep -E '^WEB_PORT=' .env | cut -d= -f2)"
	@printf '  Адмінка:   http://localhost:%s/admin/\n' "$$(grep -E '^WEB_PORT=' .env | cut -d= -f2)"
	@printf '  База:      http://localhost:%s/\n' "$$(grep -E '^ADMINER_PORT=' .env | cut -d= -f2)"
	@printf '  Пошта:     http://localhost:%s/\n' "$$(grep -E '^MAILPIT_UI_PORT=' .env | cut -d= -f2)"
	@printf '  Прод:      https://orendaposudu.com/\n'

include make/quality.mk
