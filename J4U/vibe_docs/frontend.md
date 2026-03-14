# Justice4U: Frontend Design & Notes

## Design System: "10/10 INTELLIGENCE THEME"

The project utilizes a custom, high-end CSS design system injected into the `<head>` of core JSP files. Rather than relying entirely on Bootstrap classes, the UI uses distinct CSS variables to ensure brand consistency.

### Color Palette

- `--bg-ivory`: `#FAFAF8` (Base background)
- `--ink-primary`: `#121212` (Main typography)
- `--ink-secondary`: `#555555` (Subtitles/meta text)
- `--gold-main`: `#C6A75E` (Primary brand accent, buttons, icons)
- `--success-green`: `#059669` (Verified statuses, approval actions)
- `--alert-amber`: `#D97706` (Pending statuses, warnings)
- `--danger-red`: `#DC2626` (Rejections, destructive actions)

### Typography

The UI pairs three distinct Google Fonts (imported via CDN):

1. **`Inter`**: The workhorse font for all body text, dashboard tables, and cards. Provides clean legibility.
2. **`Playfair Display`**: System headers, page titles, and prominent brand messaging. Adds a layer of legal authority.
3. **`Space Grotesk`**: Used exclusively for technological data, numbers, timestamps, and metrics.

### Component Behaviors

- **Cards (`.panel`, `.lawyer-card`)**: Floating white surfaces with subtle borders (`--border-subtle`). On hover, they gently translate upward (`transform: translateY(-2px)`) and cast a slightly tinted gold shadow (`--shadow-hover`).
- **Buttons (`.btn-approve`, `.btn-reject`, `.btn-action`)**: Ghost/Outline style by default to reduce visual noise. On hover, they fill with their respective semantic color (Green/Red) and translate up.
- **Modals**: Used for inline document viewing (e.g., `viewlawyerdocuments.jsp`). PDF iframes and images are embedded inside Bootstrap `modal-xl` elements to prevent context-switching (opening new tabs).
- **Animations (`.smart-enter`)**: Dashboard elements utilize a staggered entrance animation (`enterUp`) to feel responsive and fast upon loading.

### Frameworks

- **Bootstrap 5.3.0**: Imported via CDN. Used purely for structural utility classes (e.g., `.modal`, `.fade`, `.d-flex`, `.row`), but visual styling is aggressively overridden by the custom theme.
- **Phosphor Icons**: Imported via `@phosphor-icons/web`. Replaces obsolete FontAwesome icons with modern, clean line icons (`<i class="ph ph-user"></i>`).
