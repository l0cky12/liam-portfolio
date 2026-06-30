# Liam Decareaux — Portfolio & Blog

A professional portfolio and blog website built with [Hugo](https://gohugo.io/), designed for a K‑12 system administrator.

## Local Development

### Prerequisites

- [Hugo Extended](https://gohugo.io/installation/) v0.112.0+
- Git

### Running the site locally

```bash
# Clone the repository
git clone https://github.com/fhlkfds/liam-portfolio.git
cd liam-portfolio

# Start the Hugo dev server (live reload)
hugo server -D

# Open http://localhost:1313 in your browser
```

### Building the site

```bash
# Generate static files in public/
hugo

# The output goes to public/ — this is what gets deployed
```

## Project Structure

```
liam-portfolio/
├── hugo.toml                  # Hugo configuration
├── archetypes/
│   └── default.md             # Template for new content
├── content/
│   ├── _index.md              # Homepage content
│   ├── about.md               # About page
│   ├── contact.md             # Contact page
│   └── blog/
│       ├── _index.md          # Blog listing page
│       ├── setting-up-a-home-lab.md
│       ├── linux-server-maintenance-tips.md
│       ├── microsoft-365-admin-lessons.md
│       └── fixing-common-desktop-support-issues.md
├── themes/
│   └── liam-theme/
│       ├── theme.toml
│       └── layouts/
│           ├── _default/
│           │   ├── baseof.html   # Base layout (head, header, footer)
│           │   ├── list.html      # Blog listing page
│           │   ├── single.html    # Individual blog post
│           │   └── page.html      # Static pages (about, contact)
│           ├── index.html         # Homepage layout
│           └── partials/
│               ├── header.html     # Site header + nav
│               ├── footer.html    # Site footer
│               ├── blog-card.html  # Reusable blog post card
│               └── css.html        # All site CSS
├── .github/
│   └── workflows/
│       └── hugo.yml            # GitHub Actions deployment workflow
└── .gitignore
```

## Deploying to GitHub Pages

This site is configured for automatic deployment via GitHub Actions. See `.github/workflows/hugo.yml` for the workflow file.

### How it works

1. Push changes to the `main` branch
2. GitHub Actions runs the Hugo build
3. The built `public/` folder is deployed to GitHub Pages
4. The site is live at `https://l0cky12.github.io/liam-portfolio/`

### One-time GitHub Pages setup

1. Go to the repository Settings → Pages
2. Under "Source", select **GitHub Actions**
3. Push to `main` — the workflow handles the rest

## License

MIT
