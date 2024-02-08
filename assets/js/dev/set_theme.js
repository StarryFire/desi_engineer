// On page load or when changing themes, best to add inline in `head` to avoid FOUC: https://en.wikipedia.org/wiki/Flash_of_unstyled_content
let theme = "";
if (
  localStorage.theme === "dark" ||
  (!("theme" in localStorage) &&
    window.matchMedia("(prefers-color-scheme: dark)").matches)
) {
  theme = "dark";
} else {
  theme = "light";
}
// support only dark theme for now
theme = "dark";

document.documentElement.setAttribute("data-theme", theme);

// so that theme-color on mobile devices matches the background color of the website
var themeColor = getComputedStyle(document.documentElement)
  .getPropertyValue("--c-neutral-bg")
  .trim();
var metaThemeColor = document.querySelector('meta[name="theme-color"]');
if (metaThemeColor) {
  metaThemeColor.setAttribute("content", themeColor);
}

// Whenever the user explicitly chooses light mode
// localStorage.theme = 'light'

// Whenever the user explicitly chooses dark mode
// localStorage.theme = 'dark'

// Whenever the user explicitly chooses to respect the OS preference
// localStorage.removeItem('theme')
