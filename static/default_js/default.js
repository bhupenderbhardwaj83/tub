/* Default Template JavaScript */

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

function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    if (sidebar) {
        sidebar.classList.toggle('open');
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    const searchInput = document.getElementById('sidebarSearch') || document.getElementById('searchInput');
    const sidebarLinks = document.querySelectorAll('.sidebar-link');
    const navSections = document.querySelectorAll('.nav-section');
    const sections = document.querySelectorAll('.section');
    const copyButtons = document.querySelectorAll('.copy-btn');

    // Copy button functionality
    copyButtons.forEach(btn => {
        btn.addEventListener('click', () => copyCode(btn));
    });

    // Search functionality
    const searchClear = document.getElementById('searchClear');

    if (searchInput) {
        // Function to perform search
        const performSearch = () => {
            const query = searchInput.value.toLowerCase().trim();

            // Toggle clear button
            if (searchClear) {
                searchClear.style.display = query.length > 0 ? 'block' : 'none';
            }

            navSections.forEach(section => {
                const titleElement = section.querySelector('.nav-section-title');
                const titleText = titleElement ? titleElement.textContent.toLowerCase() : '';
                const links = section.querySelectorAll('.sidebar-link');

                let hasVisibleLink = false;
                const sectionMatches = titleText.includes(query);

                links.forEach(link => {
                    const linkText = link.textContent.toLowerCase();
                    if (sectionMatches || linkText.includes(query)) {
                        link.classList.remove('hidden');
                        hasVisibleLink = true;
                    } else {
                        link.classList.add('hidden');
                    }
                });

                if (hasVisibleLink) {
                    section.classList.remove('hidden');
                } else {
                    section.classList.add('hidden');
                }
            });
        };

        searchInput.addEventListener('input', performSearch);

        // Clear button click
        if (searchClear) {
            searchClear.addEventListener('click', () => {
                searchInput.value = '';
                searchInput.focus();
                performSearch();
            });
        }

        // Keyboard navigation & Esc to clear
        searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                e.preventDefault();
                searchInput.value = '';
                performSearch();
                searchInput.blur(); // Optional: remove focus
            } else if (e.key === 'ArrowDown' || e.key === 'Enter') {
                e.preventDefault();
                const visibleLinks = Array.from(sidebarLinks).filter(link => !link.classList.contains('hidden'));
                if (visibleLinks.length > 0) {
                    visibleLinks[0].focus();
                    if (e.key === 'Enter') {
                        visibleLinks[0].click();
                    }
                }
            }
        });
    }

    // Keyboard navigation between links
    sidebarLinks.forEach(link => {
        link.addEventListener('keydown', (e) => {
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                const visibleLinks = Array.from(sidebarLinks).filter(l => !l.classList.contains('hidden'));
                const currentIndex = visibleLinks.indexOf(link);
                if (currentIndex < visibleLinks.length - 1) {
                    visibleLinks[currentIndex + 1].focus();
                }
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                const visibleLinks = Array.from(sidebarLinks).filter(l => !l.classList.contains('hidden'));
                const currentIndex = visibleLinks.indexOf(link);
                if (currentIndex > 0) {
                    visibleLinks[currentIndex - 1].focus();
                } else {
                    searchInput.focus();
                }
            }
        });
    });

    // Active link highlighting
    if (sections.length > 0) {
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
                if (link.getAttribute('href').slice(1) === current) {
                    link.classList.add('active');
                }
            });
        });
    }

    // Global Keyboard Shortcuts
    document.addEventListener('keydown', (e) => {
        // Avoid triggering when typing in inputs
        if (document.activeElement.tagName === 'INPUT' || document.activeElement.tagName === 'TEXTAREA') return;

        // Cmd+K (Mac) or Ctrl+K (Windows/Linux) or '/' to search
        if (((e.metaKey || e.ctrlKey) && e.key === 'k') || e.key === '/') {
            const searchInput = document.getElementById('sidebarSearch') || document.getElementById('searchInput');
            if (searchInput) {
                e.preventDefault();
                searchInput.focus();
            }
        }

        // Cmd+Shift+H (Mac) or Ctrl+Shift+H (Windows/Linux) to go Back to Hub
        // Note: Cmd+B is reserved by browsers (bookmarks bar) and cannot be overridden.
        if ((e.metaKey || e.ctrlKey) && e.shiftKey && e.key === 'H') {
            const homeButton = document.querySelector('.home-button');
            if (homeButton) {
                e.preventDefault();
                homeButton.click();
            }
        }
    });
});
