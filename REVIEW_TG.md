🚀 **NixOS-Meowrch: Большое обновление «Чистота и Сила»** 🚀

Мы закончили глобальную пересборку системы. Теперь это не просто конфиг, а вылизанный до блеска дистрибутив.

🎨 **Эстетика и UI:**
• **SDDM:** Полный порт на **Qt6**. Теперь тема подгружает цвета динамически, а аватарки не отваливаются.
• **Kitty:** Вернули «тот самый» вид с прозрачностью **0.8**. Никакого лишнего мусора в конфигах.
• **Starship:** Промпт стал максимально чистым: только путь, ветка и статус. Ничего лишнего.
• **Dark Mode:** Принудительный темный режим для GTK4/Libadwaita (HotkeyHub теперь выглядит как родной).

📟 **Mewline (Dynamic Island):**
• Теперь это **системный сервис**. Упал? Поднимется сам за секунду.
• Исправлены критические баги с иконками уведомлений и конфликтами при перезагрузке.
• Фикс для ПК: бар больше не ищет подсветку там, где её нет.

📂 **Архитектура (The Grand Refactor):**
• **Полный порядок:** Корень репозитория очищен. Всё разложено по папкам: `config/`, `assets/`, `scripts/`, `hosts/`.
• **Waybar RIP:** Попрощались с вейбаром. Mewline теперь единственная и полноправная панель.
• **UWSM:** Перешли на современный менеджер сессий. Hyprland теперь запускается стабильнее и быстрее.

⚡ **Фишки и Безопасность:**
• **Супер-алиас:** Команда `u` (или `г`) делает всё за тебя: pull + update hashes + flake update + rebuild.
• **Nvidia:** Пофикшена ошибка лицензии 134, драйверы теперь выбираются умнее.
• **ZRAM:** Включен по умолчанию для плавной работы.

---

🚀 **NixOS-Meowrch: "Purity & Power" Update** 🚀

The total system overhaul is complete. We’ve turned the configuration into a precision-engineered machine.

🎨 **Aesthetics & UI:**
• **SDDM:** Full **Qt6** port. Implemented dynamic theming and fixed user avatars.
• **Kitty:** Restored the iconic Meowrch look with **0.8 opacity**.
• **Starship:** New ultra-minimalist prompt. Clean, fast, and distraction-free.
• **Dark Mode:** Forced dark preference for GTK4/Libadwaita apps.

📟 **Mewline (Dynamic Island):**
• Now a robust **systemd service** with auto-restart.
• Fixed notification icon crashes and process conflicts.
• Desktop support: Smart brightness detection (no more crashes on PCs).

📂 **Architecture (The Grand Refactor):**
• **Pristine Root:** Everything is organized into `config/`, `assets/`, `scripts/`, and `hosts/`.
• **Waybar Removed:** Officially retired. Mewline is now the primary and only status bar.
• **UWSM:** Switched to Universal Wayland Session Manager for superior stability.

⚡ **Features & Security:**
• **One-Click Update:** New `u` (or Russian `г`) alias for a full update cycle.
• **Nvidia:** Resolved license error 134 and optimized driver selection.
• **ZRAM:** Enabled by default for better performance.

#NixOS #Meowrch #Hyprland #Update #Refactor
