#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                    Meowrch NixOS User Change Script                      ║
# ║                         Быстрая смена пользователя                       ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Функции логирования
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} $1"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Показать использование
show_usage() {
    echo -e "${CYAN}Usage:${NC}"
    echo "  $0 [options]"
    echo
    echo -e "${CYAN}Options:${NC}"
    echo "  -u, --username     New username"
    echo "  -n, --name         Full name"
    echo "  -e, --email        Email address"
    echo "  -g, --git-name     Git name"
    echo "  -d, --dry-run      Show what would be changed without making changes"
    echo "  -h, --help         Show this help"
    echo
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0 -u myuser -n \"My Name\" -e \"my@email.com\""
    echo "  $0 --username newuser --name \"New User\""
    echo "  $0 --dry-run  # See current configuration"
    echo "  $0  # Interactive mode"
    echo
}

# Валидация входных данных
validate_username() {
    local username="$1"
    if [[ ! "$username" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        log_error "Username must start with letter and contain only letters, numbers, hyphens, and underscores"
        return 1
    fi
    return 0
}

validate_email() {
    local email="$1"
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_error "Invalid email format"
        return 1
    fi
    return 0
}

validate_name() {
    local name="$1"
    if [[ -n "$name" && ! "$name" =~ ^[A-Za-zА-Яа-я[:space:]]+$ ]]; then
        log_error "Name must contain only letters and spaces"
        return 1
    fi
    return 0
}

# Интерактивный ввод
prompt_input() {
    local prompt="$1"
    local default="$2"
    local validation_func="$3"
    local result=""

    while true; do
        echo -ne "${CYAN}$prompt${NC}"
        if [[ -n "$default" ]]; then
            echo -ne " ${YELLOW}(current: $default)${NC}"
        fi
        echo -n ": "

        read -r result

        # Использовать default если ввод пустой
        if [[ -z "$result" && -n "$default" ]]; then
            result="$default"
        fi

        # Валидация только если есть функция валидации и результат не пустой
        if [[ -n "$validation_func" && -n "$result" ]]; then
            if "$validation_func" "$result"; then
                echo "$result"
                return 0
            fi
        else
            echo "$result"
            return 0
        fi
    done
}

# Поиск текущего пользователя в конфигурации
detect_current_user() {
    local current_user=""

    # Пытаемся найти пользователя в configuration.nix
    if [[ -f "configuration.nix" ]]; then
        current_user=$(grep -oP 'users\.\K[a-zA-Z][a-zA-Z0-9_-]*' configuration.nix | head -1 2>/dev/null || echo "")
    fi

    # Если не найден, пытаемся найти в home.nix
    if [[ -z "$current_user" && -f "home/home.nix" ]]; then
        current_user=$(grep -oP 'home\.username = "\K[^"]*' home/home.nix 2>/dev/null || echo "")
    fi

    # Если не найден, пытаемся найти в flake.nix
    if [[ -z "$current_user" && -f "flake.nix" ]]; then
        current_user=$(grep -oP 'home-manager\.users\.\K[a-zA-Z][a-zA-Z0-9_-]*' flake.nix | head -1 2>/dev/null || echo "")
    fi

    echo "$current_user"
}

# Поиск текущих данных пользователя
detect_current_data() {
    local current_name=""
    local current_email=""
    local current_git_name=""

    # Ищем description в configuration.nix
    if [[ -f "configuration.nix" ]]; then
        current_name=$(grep -oP 'description = "\K[^"]*' configuration.nix 2>/dev/null | head -1 || echo "")
    fi

    # Ищем git настройки в home.nix
    if [[ -f "home/home.nix" ]]; then
        current_email=$(grep -oP 'userEmail = "\K[^"]*' home/home.nix 2>/dev/null | head -1 || echo "")
        current_git_name=$(grep -oP 'userName = "\K[^"]*' home/home.nix 2>/dev/null | head -1 || echo "")
    fi

    # Выводим результат в одной строке
    printf "%s|%s|%s\n" "$current_name" "$current_email" "$current_git_name"
}

# Проверка существования файлов
check_files() {
    local missing_files=()

    if [[ ! -f "configuration.nix" ]]; then
        missing_files+=("configuration.nix")
    fi

    if [[ ! -f "flake.nix" ]]; then
        missing_files+=("flake.nix")
    fi

    if [[ ! -f "home/home.nix" ]]; then
        missing_files+=("home/home.nix")
    fi

    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_warning "The following files are missing:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        echo
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Operation cancelled"
            exit 0
        fi
    fi
}

# Создание резервной копии
create_backup() {
    local backup_dir="./backup-user-change-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    local files=(
        "configuration.nix"
        "flake.nix"
        "home/home.nix"
        "home/modules/waybar.nix"
        "modules/system/security.nix"
    )

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$backup_dir/"
            log_info "Backed up: $file"
        fi
    done

    log_success "Backup created in: $backup_dir"
}

# Замена пользователя в файлах
replace_user_in_files() {
    local old_user="$1"
    local new_user="$2"
    local new_name="$3"
    local new_email="$4"
    local new_git_name="$5"
    local dry_run="${6:-false}"

    if [[ "$dry_run" == "true" ]]; then
        log_header "Dry Run: Showing what would be changed"
    else
        log_header "Updating Configuration Files"
    fi

    local files=(
        "configuration.nix"
        "flake.nix"
        "home/home.nix"
        "home/modules/waybar.nix"
        "modules/system/security.nix"
    )

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            if [[ "$dry_run" == "true" ]]; then
                log_info "Would process: $file"
            else
                log_info "Processing: $file"
            fi

            # В режиме dry-run только показываем, что будет изменено
            if [[ "$dry_run" == "true" ]]; then
                case "$file" in
                    "configuration.nix")
                        if grep -q "users\.$old_user" "$file"; then
                            echo "  - Would change: users.$old_user -> users.$new_user"
                        fi
                        if [[ -n "$new_name" ]] && grep -q 'description = "' "$file"; then
                            echo "  - Would update description to: $new_name"
                        fi
                        ;;
                    "flake.nix")
                        if grep -q "home-manager\.users\.$old_user" "$file"; then
                            echo "  - Would change: home-manager.users.$old_user -> home-manager.users.$new_user"
                        fi
                        if grep -q "nixosConfigurations\.\"$old_user\"" "$file"; then
                            echo "  - Would change: nixosConfigurations.\"$old_user\" -> nixosConfigurations.\"$new_user\""
                        fi
                        ;;
                    "home/home.nix")
                        if grep -q "home\.username = \"$old_user\"" "$file"; then
                            echo "  - Would change: home.username = \"$old_user\" -> home.username = \"$new_user\""
                        fi
                        if grep -q "/home/$old_user" "$file"; then
                            echo "  - Would change: /home/$old_user -> /home/$new_user"
                        fi
                        if [[ -n "$new_email" ]] && grep -q 'userEmail = "' "$file"; then
                            echo "  - Would update git email to: $new_email"
                        fi
                        if [[ -n "$new_git_name" ]] && grep -q 'userName = "' "$file"; then
                            echo "  - Would update git name to: $new_git_name"
                        fi
                        ;;
                esac
                continue
            fi

            # Создаем временную копию для проверки
            local temp_file="${file}.tmp"
            cp "$file" "$temp_file"

            # Замены для configuration.nix
            if [[ "$file" == "configuration.nix" ]]; then
                # Замена пользователя
                if ! sed -i "s/users\.$old_user/users.$new_user/g" "$temp_file"; then
                    log_error "Failed to update username in $file"
                    rm -f "$temp_file"
                    return 1
                fi

                # Замена описания только если оно указано
                if [[ -n "$new_name" ]]; then
                    if ! sed -i "s/description = \"[^\"]*\"/description = \"$new_name\"/g" "$temp_file"; then
                        log_warning "Could not update description in $file"
                    fi
                fi
            fi

            # Замены для flake.nix
            if [[ "$file" == "flake.nix" ]]; then
                if ! sed -i "s/home-manager\.users\.$old_user/home-manager.users.$new_user/g" "$temp_file"; then
                    log_error "Failed to update home-manager.users in $file"
                    rm -f "$temp_file"
                    return 1
                fi

                if ! sed -i "s/nixosConfigurations\.\"$old_user\"/nixosConfigurations.\"$new_user\"/g" "$temp_file"; then
                    log_warning "Could not update nixosConfigurations in $file"
                fi

                if ! sed -i "s/\.#$old_user/.#$new_user/g" "$temp_file"; then
                    log_warning "Could not update flake reference in $file"
                fi
            fi

            # Замены для home/home.nix
            if [[ "$file" == "home/home.nix" ]]; then
                # Основные настройки
                if ! sed -i "s/home\.username = \"$old_user\"/home.username = \"$new_user\"/g" "$temp_file"; then
                    log_error "Failed to update home.username in $file"
                    rm -f "$temp_file"
                    return 1
                fi

                if ! sed -i "s|home\.homeDirectory = \"/home/$old_user\"|home.homeDirectory = \"/home/$new_user\"|g" "$temp_file"; then
                    log_error "Failed to update home.homeDirectory in $file"
                    rm -f "$temp_file"
                    return 1
                fi

                # Git настройки
                if [[ -n "$new_git_name" ]]; then
                    if ! sed -i "s/userName = \"[^\"]*\"/userName = \"$new_git_name\"/g" "$temp_file"; then
                        log_warning "Could not update git userName in $file"
                    fi
                fi

                if [[ -n "$new_email" ]]; then
                    if ! sed -i "s/userEmail = \"[^\"]*\"/userEmail = \"$new_email\"/g" "$temp_file"; then
                        log_warning "Could not update git userEmail in $file"
                    fi
                fi

                # Пути в алиасах и функциях
                if ! sed -i "s|/home/$old_user/|/home/$new_user/|g" "$temp_file"; then
                    log_warning "Could not update home paths in $file"
                fi

                if ! sed -i "s|\.#$old_user|.#$new_user|g" "$temp_file"; then
                    log_warning "Could not update flake references in $file"
                fi
            fi

            # Замены для home/modules/waybar.nix
            if [[ "$file" == "home/modules/waybar.nix" ]]; then
                if ! sed -i "s|/home/$old_user/|/home/$new_user/|g" "$temp_file"; then
                    log_warning "Could not update paths in $file"
                fi
            fi

            # Замены для modules/system/security.nix
            if [[ "$file" == "modules/system/security.nix" ]]; then
                if ! sed -i "s/users = \\[ \"$old_user\" \\]/users = [ \"$new_user\" ]/g" "$temp_file"; then
                    log_warning "Could not update security users array in $file"
                fi

                if ! sed -i "s/\"$old_user\"/\"$new_user\"/g" "$temp_file"; then
                    log_warning "Could not update user references in $file"
                fi
            fi

            # Проверяем, что файл не пуст после изменений
            if [[ ! -s "$temp_file" ]]; then
                log_error "File $file became empty after processing - skipping"
                rm -f "$temp_file"
                continue
            fi

            # Заменяем оригинальный файл
            if ! mv "$temp_file" "$file"; then
                log_error "Failed to save changes to $file"
                rm -f "$temp_file"
                return 1
            fi

            if [[ "$dry_run" == "true" ]]; then
                log_info "✓ Would update: $file"
            else
                log_success "✓ Updated: $file"
            fi
        else
            if [[ "$dry_run" == "true" ]]; then
                log_info "⚠ Not found: $file"
            else
                log_warning "⚠ Not found: $file"
            fi
        fi
    done
}

# Основная функция замены
change_user() {
    local new_username="$1"
    local new_name="$2"
    local new_email="$3"
    local new_git_name="$4"
    local dry_run="${5:-false}"

    # Определяем текущего пользователя
    local current_user
    current_user=$(detect_current_user)

    if [[ -z "$current_user" ]]; then
        log_error "Could not detect current username in configuration"
        exit 1
    fi

    log_info "Current username: $current_user"
    if [[ "$dry_run" == "false" ]]; then
        log_info "New username: $new_username"
    fi

    if [[ "$current_user" == "$new_username" && "$dry_run" == "false" ]]; then
        log_warning "Username is the same, updating other fields only"
    fi

    # Проверяем файлы
    if [[ "$dry_run" == "false" ]]; then
        check_files
    fi

    # Создаем резервную копию только если не dry-run
    if [[ "$dry_run" == "false" ]]; then
        create_backup
    fi

    # Выполняем замену или показываем что будет изменено
    if ! replace_user_in_files "$current_user" "$new_username" "$new_name" "$new_email" "$new_git_name" "$dry_run"; then
        if [[ "$dry_run" == "false" ]]; then
            log_error "Failed to update configuration files"
            exit 1
        fi
    fi

    if [[ "$dry_run" == "true" ]]; then
        log_success "Dry run completed - no files were modified"
        echo
        log_info "To apply these changes, run the same command without --dry-run"
    else
        log_success "User configuration updated successfully!"
        echo
        log_info "Next steps:"
        echo "  1. Review the changes in the configuration files"
        echo "  2. Run: ./validate-config.sh (to check for errors)"
        echo "  3. Run: sudo nixos-rebuild switch --flake .#$new_username"
        echo "  4. Run: home-manager switch --flake .#$new_username"
        echo "  5. Create/update the user account if needed"
    fi
}

# Интерактивный режим
interactive_mode() {
    log_header "Interactive User Configuration"

    # Определяем текущие данные
    local current_user
    current_user=$(detect_current_user)

    local current_data
    current_data=$(detect_current_data)
    local current_name current_email current_git_name
    # Используем временную переменную для надежного разбора
    local old_ifs="$IFS"
    IFS='|'
    read -r current_name current_email current_git_name <<< "$current_data"
    IFS="$old_ifs"

    if [[ -n "$current_user" ]]; then
        log_info "Current configuration detected:"
        echo "  Username: $current_user"
        echo "  Name: $current_name"
        echo "  Email: $current_email"
        echo "  Git Name: $current_git_name"
        echo
    fi

    # Ввод новых данных
    local new_username
    new_username=$(prompt_input "New username" "$current_user" "validate_username")

    local new_name
    new_name=$(prompt_input "Full name" "$current_name" "")

    local new_email
    new_email=$(prompt_input "Email address" "$current_email" "validate_email")

    local new_git_name
    new_git_name=$(prompt_input "Git name" "$current_git_name" "")

    echo
    log_info "Configuration summary:"
    echo "  Username: $new_username"
    echo "  Name: $new_name"
    echo "  Email: $new_email"
    echo "  Git Name: $new_git_name"
    echo

    read -p "Proceed with these changes? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled"
        exit 0
    fi

    change_user "$new_username" "$new_name" "$new_email" "$new_git_name" "false"
}

# Основная функция
main() {
    # Проверяем, что мы в правильной директории
    if [[ ! -f "flake.nix" ]] || [[ ! -f "configuration.nix" ]]; then
        log_error "This script must be run from the Meowrch NixOS configuration directory"
        exit 1
    fi

    # Переменные для аргументов
    local username=""
    local name=""
    local email=""
    local git_name=""
    local dry_run="false"

    # Обработка аргументов
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--username)
                username="$2"
                shift 2
                ;;
            -n|--name)
                name="$2"
                shift 2
                ;;
            -e|--email)
                email="$2"
                shift 2
                ;;
            -g|--git-name)
                git_name="$2"
                shift 2
                ;;
            -d|--dry-run)
                dry_run="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Если только dry-run, показываем текущую конфигурацию
    if [[ "$dry_run" == "true" && -z "$username" && -z "$name" && -z "$email" && -z "$git_name" ]]; then
        log_header "Current Configuration"
        local current_user
        current_user=$(detect_current_user)
        local current_data
        current_data=$(detect_current_data)
        local current_name current_email current_git_name
        # Используем временную переменную для надежного разбора
        local old_ifs="$IFS"
        IFS='|'
        read -r current_name current_email current_git_name <<< "$current_data"
        IFS="$old_ifs"

        echo "  Username: ${current_user:-'Not detected'}"
        echo "  Name: ${current_name:-'Not detected'}"
        echo "  Email: ${current_email:-'Not detected'}"
        echo "  Git Name: ${current_git_name:-'Not detected'}"

        # Показываем какие файлы будут обработаны
        echo
        log_info "Configuration files found:"
        local files=(
            "configuration.nix"
            "flake.nix"
            "home/home.nix"
            "home/modules/waybar.nix"
            "modules/system/security.nix"
        )

        for file in "${files[@]}"; do
            if [[ -f "$file" ]]; then
                echo "  ✓ $file"
            else
                echo "  ✗ $file (not found)"
            fi
        done
        exit 0
    fi

    # Если аргументы не переданы, запускаем интерактивный режим
    if [[ -z "$username" && -z "$name" && -z "$email" && -z "$git_name" ]]; then
        interactive_mode
        return
    fi

    # Валидация обязательных параметров
    if [[ -z "$username" ]]; then
        log_error "Username is required when using non-interactive mode"
        show_usage
        exit 1
    fi

    # Валидация входных данных
    validate_username "$username"

    if [[ -n "$name" ]]; then
        validate_name "$name"
    fi

    if [[ -n "$email" ]]; then
        validate_email "$email"
    fi

    if [[ -n "$git_name" ]]; then
        validate_name "$git_name"
    fi

    # Выполняем замену
    change_user "$username" "$name" "$email" "$git_name" "$dry_run"
}

# Обработка сигналов
trap 'log_error "Operation interrupted"; exit 130' INT TERM

# Запуск
main "$@"
