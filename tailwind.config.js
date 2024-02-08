// baseline or grid height...same thing
// This was calculated using the fontSize of the smallest text in the design system
//  (i.e. the size of text-xs in mobile screen where 1rem=12px)
const gridHeight = 0.7; // 0.7rem

// This can be inferred using: https://uilearn.com/type-scale/
const scaleRatio = 1.125; // Major Second

// This will always be 1rem. Configure this by setting the font-size of the html/root element
const baseFontSize = 1; // 1rem

function round(num, upto) {
  const multiplier = 10 ** upto;
  return Math.round(num * multiplier) / multiplier;
}

function getFontSize(baseFontSize, scaleRatio, scale) {
  return `${round(baseFontSize * scaleRatio ** scale, 1)}rem`;
}

function getLineHeight(gridHeight, multiplier) {
  return `${round(multiplier * gridHeight, 1)}rem`;
}

function getSpacing(gridHeight, multiplier) {
  return `${round(gridHeight * multiplier, 1)}rem`;
}

const plugin = require("tailwindcss/plugin");

const get_utility_classes = (theme) => ({
  // Setting appropriate type scaling and baseline of typography
  // If you use these classes in the html templates directly, then its upto you to check the responsiveness of the text on different devices
  ".text-xs": {
    fontFamily: theme("fontFamily.text"),
    fontSize: getFontSize(baseFontSize, scaleRatio, -2),
    lineHeight: getLineHeight(gridHeight, 2),
  },
  ".text-sm": {
    fontFamily: theme("fontFamily.text"),
    fontSize: getFontSize(baseFontSize, scaleRatio, -1),
    lineHeight: getLineHeight(gridHeight, 3),
  },
  ".text-base": {
    fontFamily: theme("fontFamily.text"),
    fontSize: getFontSize(baseFontSize, scaleRatio, 0),
    lineHeight: getLineHeight(gridHeight, 3),
  },
  ".heading-xs": {
    fontFamily: theme("fontFamily.heading"),
    fontSize: getFontSize(baseFontSize, scaleRatio, 0),
    lineHeight: getLineHeight(gridHeight, 2),
  },
  ".heading-sm": {
    fontFamily: theme("fontFamily.heading"),
    fontSize: getFontSize(baseFontSize, scaleRatio, 1),
    lineHeight: getLineHeight(gridHeight, 3),
  },
  ".heading-base": {
    fontFamily: theme("fontFamily.heading"),
    fontSize: getFontSize(baseFontSize, scaleRatio, 2),
    lineHeight: getLineHeight(gridHeight, 3),
  },
  ".heading-md": {
    fontFamily: theme("fontFamily.heading"),
    fontSize: getFontSize(baseFontSize, scaleRatio, 3),
    lineHeight: getLineHeight(gridHeight, 4),
  },
  ".heading-lg": {
    fontFamily: theme("fontFamily.heading"),
    fontSize: getFontSize(baseFontSize, scaleRatio, 4),
    lineHeight: getLineHeight(gridHeight, 4),
  },
  ".heading-xl": {
    fontFamily: theme("fontFamily.heading"),
    fontSize: getFontSize(baseFontSize, scaleRatio, 5),
    lineHeight: getLineHeight(gridHeight, 4),
  },
});

module.exports = {
  content: ["**/*.templ"],

  darkMode: ["class", '[data-theme="dark"]'],
  plugins: [
    // require("@tailwindcss/forms"),
    // require("@tailwindcss/typography"),
    plugin(function ({ addBase, addComponents, addUtilities, theme }) {
      // addBase({});
      // addComponents({});
      addUtilities(get_utility_classes(theme));
    }),
  ],
  theme: {
    fontFamily: {
      // Define all your main font and fallback fonts here
      heading: ["'Press Start 2P'", "sans-serif"],
      text: ["'IBM Plex Mono'", "monospace"],
    },

    // Removing all default font sizes
    fontSize: {},

    spacing: {
      0: getSpacing(gridHeight, 0),
      1: getSpacing(gridHeight, 1),
      2: getSpacing(gridHeight, 2),
      3: getSpacing(gridHeight, 3),
      4: getSpacing(gridHeight, 4),
      5: getSpacing(gridHeight, 5),
      6: getSpacing(gridHeight, 6),
      7: getSpacing(gridHeight, 7),
      8: getSpacing(gridHeight, 8),
      9: getSpacing(gridHeight, 9),
      10: getSpacing(gridHeight, 10),
    },

    screens: {
      // breakpoints were calculated based on the classes applied to <html> element
      mobile: "0px",
      tablet: "800px",
      laptop: "1000px",
    },

    colors: {
      // all colors must be defined in css and then referenced here
      c: {
        // shades of gray used for text, backgrounds, panels, forms, disabled state, auxillary text, etc.
        neutral: {
          // charade
          50: "hsl(var(--c-neutral-50) / <alpha-value>)",
          100: "hsl(var(--c-neutral-100) / <alpha-value>)",
          200: "hsl(var(--c-neutral-200) / <alpha-value>)",
          300: "hsl(var(--c-neutral-300) / <alpha-value>)",
          400: "hsl(var(--c-neutral-400) / <alpha-value>)",
          500: "hsl(var(--c-neutral-500) / <alpha-value>)",
          600: "hsl(var(--c-neutral-600) / <alpha-value>)",
          700: "hsl(var(--c-neutral-700) / <alpha-value>)",
          800: "hsl(var(--c-neutral-800) / <alpha-value>)",
          900: "hsl(var(--c-neutral-900) / <alpha-value>)",
          950: "hsl(var(--c-neutral-950) / <alpha-value>)",
        },

        // used for buttons and most things, defines your brand
        primary: {
          // spring-green
          50: "hsl(var(--c-primary-50) / <alpha-value>)",
          100: "hsl(var(--c-primary-100) / <alpha-value>)",
          200: "hsl(var(--c-primary-200) / <alpha-value>)",
          300: "hsl(var(--c-primary-300) / <alpha-value>)",
          400: "hsl(var(--c-primary-400) / <alpha-value>)",
          500: "hsl(var(--c-primary-500) / <alpha-value>)",
          600: "hsl(var(--c-primary-600) / <alpha-value>)",
          700: "hsl(var(--c-primary-700) / <alpha-value>)",
          800: "hsl(var(--c-primary-800) / <alpha-value>)",
          900: "hsl(var(--c-primary-900) / <alpha-value>)",
          950: "hsl(var(--c-primary-950) / <alpha-value>)",
        },

        // used almost as often as primary, defines your brand
        // secondary: colors.gray,

        // define accent colors like error, success, highlight, etc.
        // accent colors are used very sparingly

        // semantic colors to that define specific things in your app
        "primary-text": "hsl(var(--c-primary-text) / <alpha-value>)",
        "neutral-text": "hsl(var(--c-neutral-text) / <alpha-value>)",
        "neutral-bg": "hsl(var(--c-neutral-bg) / <alpha-value>)",
        "primary-tag": "hsl(var(--c-primary-tag) / <alpha-value>)",
      },
    },
    // extend: {
    //   typography: (theme) => ({
    //     DEFAULT: {
    //       css: {
    //         h1: {
    //           ...get_utility_classes(theme)[".heading-lg"],
    //         },
    //       },
    //     },
    //   }),
    // },
  },
};
