# 📘 CSS STYLESHEET USAGE GUIDE

## File: tutorial_styles.css (Complete Stylesheet)

This CSS file contains **ALL styles** for the Advanced Python tutorial system.

---

## 🎨 WHAT'S INCLUDED

### 23 Component Categories:

1. **Base Styles** - Reset, body, fonts
2. **Home Button** - Fixed top-left navigation
3. **Page Layout** - Flex wrapper
4. **Sidebar** - Fixed left navigation (300px)
5. **Mobile Toggle** - Hamburger menu
6. **Main Content** - Flexible width area
7. **Container & Header** - Page structure
8. **Content Sections** - Section/module titles
9. **Concept Box** - Main content wrapper
10. **Questions Grid** - 6-box framework
11. **Code Blocks** - Syntax highlighting
12. **Syntax Classes** - .kw, .fn, .str, etc.
13. **Media LEFT** - 45% image/video left
14. **Media RIGHT** - 45% image/video right
15. **Media CENTER** - 100% full width
16. **Mistake Box** - Red error warnings
17. **Checklist Box** - Purple checkmarks
18. **Exercise Box** - Cyan practice problems
19. **Use Case Box** - Blue real-world examples
20. **Key Point Box** - Purple highlights
21. **Tip Box** - Blue tips/advice
22. **Responsive** - Mobile breakpoints
23. **Color Palette** - Reference guide

---

## 🚀 HOW TO USE

### Method 1: Link External CSS (Recommended)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Tutorial Page</title>
    <link rel="stylesheet" href="tutorial_styles.css">
</head>
<body>
    <!-- Your content here -->
</body>
</html>
```

### Method 2: Inline Styles

Copy the entire CSS file and paste it between `<style>` tags in your HTML:

```html
<head>
    <style>
        /* Paste entire tutorial_styles.css content here */
    </style>
</head>
```

---

## 📋 COMPONENT QUICK REFERENCE

### 1. HOME BUTTON
```html
<a href="python_hub.html" class="home-button">Back to Hub</a>
```

### 2. PAGE LAYOUT
```html
<div class="page-wrapper">
    <nav class="sidebar">...</nav>
    <main class="main-content">...</main>
</div>
```

### 3. SIDEBAR
```html
<nav class="sidebar" id="sidebar">
    <div class="sidebar-title">📚 Title</div>
    
    <div class="search-box">
        <input type="text" class="search-input" placeholder="Search...">
        <span class="search-icon">🔍</span>
    </div>
    
    <div class="sidebar-section">
        <div class="sidebar-section-title">SECTION</div>
        <a href="#topic" class="sidebar-link">Link</a>
        <a href="#topic" class="sidebar-link active">Active Link</a>
    </div>
</nav>
```

### 4. HEADER
```html
<div class="header">
    <h1>🚀 Title</h1>
    <p>Subtitle text</p>
</div>
```

### 5. SECTION TITLE
```html
<h2 class="section-title">1. Topic Name</h2>
```

### 6. MODULE TITLE
```html
<h3 class="module-title">Subsection Name</h3>
```

### 7. CONCEPT BOX
```html
<div class="concept-box">
    <div class="concept-header">Concept Name</div>
    <p class="explanation">Explanation text...</p>
</div>
```

### 8. QUESTIONS GRID
```html
<div class="questions-grid">
    <div class="question-box">
        <strong>💡 What Is It?</strong>
        <p>Answer...</p>
    </div>
    <!-- Repeat for 6 boxes -->
</div>
```

### 9. CODE BLOCK
```html
<div class="code-block">
    <button class="copy-btn" onclick="copyCode(this)">Copy</button>
    <pre><span class="cmt"># Comment</span>
<span class="var">variable</span> = <span class="str">"string"</span>
<span class="fn">print</span>(<span class="var">variable</span>)</pre>
</div>
```

**Syntax Classes:**
- `.kw` - Keywords (def, class, if, for)
- `.fn` - Functions (print, len)
- `.str` - Strings
- `.num` - Numbers
- `.cmt` - Comments
- `.var` - Variables

### 10. OUTPUT BLOCK
```html
<div class="output-block">Program output here</div>
```

### 11. MEDIA - IMAGE LEFT
```html
<div class="media-left">
    <div class="media-content">
        <img src="image.jpg" alt="Description">
        <div class="media-caption">Caption text</div>
    </div>
    <div class="media-text">
        <h3>Heading</h3>
        <p>Text content...</p>
    </div>
</div>
```

### 12. MEDIA - IMAGE RIGHT
```html
<div class="media-right">
    <div class="media-content">
        <img src="image.jpg" alt="Description">
        <div class="media-caption">Caption text</div>
    </div>
    <div class="media-text">
        <h3>Heading</h3>
        <p>Text content...</p>
    </div>
</div>
```

### 13. MEDIA - IMAGE CENTER (Full Width)
```html
<div class="media-center">
    <div class="media-content">
        <img src="image.jpg" alt="Description">
        <div class="media-caption">Caption text</div>
    </div>
</div>
```

### 14. MEDIA - VIDEO LEFT
```html
<div class="media-left">
    <div class="media-content">
        <iframe src="https://www.youtube-nocookie.com/embed/VIDEO_ID"
                title="Video title"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                referrerpolicy="strict-origin-when-cross-origin"
                allowfullscreen>
        </iframe>
        <div class="media-caption">Video caption</div>
    </div>
    <div class="media-text">
        <h3>Heading</h3>
        <p>Text content...</p>
    </div>
</div>
```

### 15. MEDIA - VIDEO RIGHT
```html
<div class="media-right">
    <div class="media-content">
        <iframe src="https://www.youtube-nocookie.com/embed/VIDEO_ID"
                title="Video title"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                referrerpolicy="strict-origin-when-cross-origin"
                allowfullscreen>
        </iframe>
        <div class="media-caption">Video caption</div>
    </div>
    <div class="media-text">
        <h3>Heading</h3>
        <p>Text content...</p>
    </div>
</div>
```

### 16. MEDIA - VIDEO CENTER (Full Width)
```html
<div class="media-center">
    <div class="media-content">
        <iframe src="https://www.youtube-nocookie.com/embed/VIDEO_ID"
                title="Video title"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                referrerpolicy="strict-origin-when-cross-origin"
                allowfullscreen>
        </iframe>
        <div class="media-caption">Video caption</div>
    </div>
</div>
```

### 17. MISTAKE BOX (Red)
```html
<div class="mistake-box">
    <h4>❌ Common Mistakes</h4>
    <p><strong>1. Mistake name:</strong></p>
    <p>Description and fix...</p>
</div>
```

### 18. CHECKLIST BOX (Purple)
```html
<div class="checklist">
    <h4>✅ Quick Revision Checklist</h4>
    <ul>
        <li>Item 1</li>
        <li>Item 2</li>
        <li>Item 3</li>
    </ul>
</div>
```

### 19. EXERCISE BOX (Cyan)
```html
<div class="exercise-box">
    <h4>💪 Practice Exercise</h4>
    <p>Exercise description...</p>
    <p><strong>Test:</strong> Example test case</p>
</div>
```

### 20. USE CASE BOX (Blue)
```html
<div class="use-case-box">
    <h4>🎯 Real-World Use Case</h4>
    <p>Description of practical application...</p>
</div>
```

### 21. KEY POINT BOX
```html
<div class="key-point">
    <strong>⚡ Key Point:</strong> Important information here.
</div>
```

### 22. TIP BOX
```html
<div class="tip-box">
    <strong>💡 Pro Tip:</strong> Helpful advice here.
</div>
```

---

## 🎨 COLOR PALETTE

### Primary Colors
```css
--purple-primary: #6366f1
--purple-light: #a855f7
--purple-accent: #a78bfa
--purple-pale: #c4b5fd
--purple-very-light: #ddd6fe
```

### Background Colors
```css
--bg-darkest: #020817
--bg-very-dark: #0f172a
--bg-dark: #1e293b
--bg-medium: #334155
```

### Text Colors
```css
--text-light: #e2e8f0
--text-medium: #cbd5e1
--text-subtle: #94a3b8
--text-muted: #64748b
```

### Accent Colors
```css
--blue: #60a5fa
--green: #34d399
--success: #10b981
--pink: #f472b6
--yellow: #fbbf24
--red: #ef4444
--red-light: #fca5a5
```

---

## 📱 RESPONSIVE BREAKPOINTS

### Desktop (Default)
- Sidebar: Fixed 300px left
- Content: Full width (calc(100vw - 340px))

### Tablet (≤1024px)
```css
@media (max-width: 1024px) {
    /* Sidebar hides by default */
    /* Toggle button appears */
    /* Content takes full width */
    /* Media layouts stack vertically */
}
```

### Mobile (≤768px)
```css
@media (max-width: 768px) {
    /* Smaller header text */
    /* Questions grid: single column */
}
```

---

## 🔧 JAVASCRIPT REQUIRED

For full functionality, include this JavaScript:

```javascript
// Copy button functionality
function copyCode(button) {
    const codeBlock = button.nextElementSibling;
    const code = codeBlock.textContent;
    navigator.clipboard.writeText(code).then(() => {
        button.textContent = 'Copied!';
        button.classList.add('copied');
        setTimeout(() => {
            button.textContent = 'Copy';
            button.classList.remove('copied');
        }, 2000);
    });
}

// Sidebar toggle (mobile)
function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('open');
}

// Search functionality
const searchInput = document.getElementById('searchInput');
const sidebarLinks = document.querySelectorAll('.sidebar-link');

searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase();
    sidebarLinks.forEach(link => {
        const text = link.textContent.toLowerCase();
        if (text.includes(query)) {
            link.classList.remove('hidden');
        } else {
            link.classList.add('hidden');
        }
    });
});

// Active link highlighting on scroll
const sections = document.querySelectorAll('.section');

window.addEventListener('scroll', () => {
    let current = '';
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        if (window.pageYOffset >= sectionTop - 100) {
            current = section.getAttribute('id');
        }
    });
    
    sidebarLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === '#' + current) {
            link.classList.add('active');
        }
    });
});

// Close sidebar on link click (mobile)
sidebarLinks.forEach(link => {
    link.addEventListener('click', () => {
        if (window.innerWidth <= 1024) {
            document.getElementById('sidebar').classList.remove('open');
        }
    });
});
```

---

## ✅ COMPLETE TEMPLATE STRUCTURE

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tutorial Page</title>
    <link rel="stylesheet" href="tutorial_styles.css">
</head>
<body>
    <!-- Home Button -->
    <a href="python_hub.html" class="home-button">Back to Hub</a>
    
    <!-- Mobile Toggle -->
    <div class="sidebar-toggle" onclick="toggleSidebar()">☰</div>
    
    <div class="page-wrapper">
        <!-- Sidebar -->
        <nav class="sidebar" id="sidebar">
            <div class="sidebar-title">📚 Title</div>
            <div class="search-box">
                <input type="text" class="search-input" id="searchInput" placeholder="Search...">
                <span class="search-icon">🔍</span>
            </div>
            <!-- Sidebar sections and links -->
        </nav>
        
        <!-- Main Content -->
        <main class="main-content">
            <div class="container">
                <!-- Header -->
                <div class="header">
                    <h1>🚀 Title</h1>
                    <p>Subtitle</p>
                </div>
                
                <!-- Content -->
                <div class="content">
                    <div id="topic1" class="section">
                        <!-- Your content here -->
                    </div>
                </div>
            </div>
        </main>
    </div>
    
    <script>
        <!-- JavaScript code here -->
    </script>
</body>
</html>
```

---

## 📝 NOTES

- All measurements use responsive units (em, rem, %, vw, vh)
- Colors use hex values for consistency
- Transitions on hover effects (0.3s ease)
- Border-radius for rounded corners (8px, 12px, 20px)
- Box-shadow for depth effects
- Flexbox for layouts
- CSS Grid for questions grid
- Mobile-first approach with min-width breakpoints

---

## 🎯 READY TO USE

1. Save `tutorial_styles.css` in your project
2. Link it in your HTML pages
3. Use component classes from this guide
4. Add JavaScript for interactivity
5. Customize colors in CSS file if needed

**Everything is modular, reusable, and production-ready!**
